# frozen_string_literal: true

class Api::V1::PropertiesController < ApplicationController
  include ParameterHelpers
  include Cacheable

  before_action :initialize_dependencies
  before_action :set_property, only: %i[update destroy delete_photo]

  def index
    filter_dto = ::Properties::Dto::PropertyFilterDto.new(params.to_unsafe_h.symbolize_keys)
    result = list_properties_use_case.execute(filter_dto)

    properties_dto = result[:properties].map { |entity| ::Mappers::PropertyMapper.to_dto(entity) }
    render json: properties_dto,
           each_serializer: PropertySerializer,
           meta: result[:meta]
  end

  def show
    property = cached_property(params[:id])
    # cached_property já lança RecordNotFound se property for nil, mas vamos garantir
    raise ActiveRecord::RecordNotFound, "Property not found" unless property
    
    property_dto = ::Mappers::PropertyMapper.to_dto(property)
    # Se to_dto retornar nil, também lança RecordNotFound
    raise ActiveRecord::RecordNotFound, "Property not found" unless property_dto
    
    render json: property_dto, serializer: PropertySerializer
  end

  def create
    dto = ::Properties::Dto::PropertyCreateDto.new(normalized_base_params)
    address_params = normalized_address_params
    photos = permitted_photos

    property = create_property_use_case.execute(dto, address_params, photos)

    ProcessPropertyPhotosJob.perform_later(property.id) if property.photos.present?
    log_admin_action("create", property.id, property.name)

    property_dto = ::Mappers::PropertyMapper.to_dto(property)
    render json: property_dto, serializer: PropertySerializer, status: :created
  rescue ArgumentError => e
    render json: { error: "validation_error", details: [ e.message ] }, status: :unprocessable_entity
  end

  def update
    dto = ::Properties::Dto::PropertyCreateDto.new(normalized_base_params)
    address_params = normalized_address_params
    photos = permitted_photos

    property = update_property_use_case.execute(@property.id, dto, address_params, photos)

    ProcessPropertyPhotosJob.perform_later(property.id) if property.photos.present?
    log_admin_action("update", property.id, property.name)
    invalidate_property_cache(property.id)

    property_dto = ::Mappers::PropertyMapper.to_dto(property)
    render json: property_dto, serializer: PropertySerializer
  rescue ArgumentError => e
    render json: { error: "validation_error", details: [ e.message ] }, status: :unprocessable_entity
  end

  def destroy
    property_id = @property.id
    property_name = @property.name

    delete_property_use_case.execute(property_id)

    log_admin_action("destroy", property_id, property_name)
    invalidate_property_cache(property_id)

    head :no_content
  end

  def delete_photo
    signed_id = params[:signed_id]
    return render json: { error: "signed_id é obrigatório" }, status: :bad_request unless signed_id.present?

    delete_property_photo_use_case.execute(@property.id, signed_id)
    invalidate_property_cache(@property.id)

    head :no_content
  rescue ArgumentError => e
    render json: { error: "validation_error", details: [ e.message ] }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Foto não encontrada" }, status: :not_found
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render json: { error: "ID de foto inválido" }, status: :bad_request
  end

  private

  def initialize_dependencies
    @property_repository = ::Persistence::ActiveRecord::PropertyRepositoryImpl.new
    @property_photo_service = ::Properties::Services::PropertyPhotoService
    @filter_service = ::Properties::Services::PropertyFilterService
    @category_repository = ::Persistence::ActiveRecord::CategoryRepositoryImpl.new

    @list_properties_use_case = ::Properties::UseCases::ListProperties.new(@property_repository, @filter_service)
    @show_property_use_case = ::Properties::UseCases::ShowProperty.new(@property_repository)
    @create_property_use_case = ::Properties::UseCases::CreateProperty.new(@property_repository, @property_photo_service)
    @update_property_use_case = ::Properties::UseCases::UpdateProperty.new(@property_repository, @property_photo_service)
    @delete_property_use_case = ::Properties::UseCases::DeleteProperty.new(@property_repository)
    @delete_property_photo_use_case = ::Properties::UseCases::DeletePropertyPhoto.new(@property_repository, @property_photo_service)
    @categories_use_case = ::Categories::UseCases::ListCategories.new(@category_repository)
  end

  def set_property
    @property = @show_property_use_case.execute(params[:id])
    # Se property for nil, lança RecordNotFound
    raise ActiveRecord::RecordNotFound, "Property not found" unless @property
  end

  def list_properties_use_case
    @list_properties_use_case
  end

  def show_property_use_case
    @show_property_use_case
  end

  def create_property_use_case
    @create_property_use_case
  end

  def update_property_use_case
    @update_property_use_case
  end

  def delete_property_use_case
    @delete_property_use_case
  end

  def delete_property_photo_use_case
    @delete_property_photo_use_case
  end

  def categories_use_case
    @categories_use_case
  end

  def permitted_base
    params.require(:property).permit(
      :name, :status, :category_id, :contract_type,
      :rooms, :bathrooms, :area, :parking_slots,
      :furnished,
      :description, :price, :promotional_price, :available_from,
      apartment_amenities: [],
      building_characteristics: [],
      rooms_list: %i[name type description]
    )
  end

  def permitted_address
    return nil unless params[:property].is_a?(ActionController::Parameters)

    addr = params[:property][:address]
    return nil unless addr.present?

    addr.permit(:street, :neighborhood, :city, :state, :country, :zipcode, :latitude, :longitude)
  end

  def permitted_photos
    return [] unless params[:property].is_a?(ActionController::Parameters)

    files = params[:property][:photos]
    return [] if files.blank?

    if files.is_a?(Hash)
      files.values.select { |f| f.is_a?(ActionDispatch::Http::UploadedFile) }
    else
      Array(files).select { |f| f.is_a?(ActionDispatch::Http::UploadedFile) }
    end
  end

  def normalized_base_params
    base = permitted_base.to_h
    if base["rooms_list"].is_a?(Array)
      base["rooms_list"] = base["rooms_list"].reject do |room|
        room.values.all? { |value| value.respond_to?(:blank?) ? value.blank? : value.nil? }
      end
    end
    base.symbolize_keys
  end

  def normalized_address_params
    permitted_address&.to_h&.symbolize_keys
  end

  def log_admin_action(action, property_id, property_name)
    return unless @current_admin

    Rails.logger.info(
      "[AUDIT] Admin #{@current_admin.id} (#{@current_admin.email}) " \
      "#{action}d property ##{property_id} (#{property_name}) at #{Time.current}"
    )
  end
end
