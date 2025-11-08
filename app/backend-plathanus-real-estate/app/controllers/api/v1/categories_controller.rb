class Api::V1::CategoriesController < ApplicationController
  include Cacheable

  before_action :initialize_dependencies

  def index
    categories = cached_categories
    render json: categories, each_serializer: CategorySerializer
  end

  private

  def initialize_dependencies
    @category_repository = ::Persistence::ActiveRecord::CategoryRepositoryImpl.new
    @categories_use_case = ::Categories::UseCases::ListCategories.new(@category_repository)
  end

  def categories_use_case
    @categories_use_case
  end

  def show_property_use_case
    raise NotImplementedError, "CategoriesController não utiliza cached_property"
  end
end
