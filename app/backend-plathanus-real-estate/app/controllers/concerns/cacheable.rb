# frozen_string_literal: true

module Cacheable
  extend ActiveSupport::Concern

  private

  def cached_categories
    Rails.cache.fetch("categories/all", expires_in: 1.hour) do
      categories_use_case.execute
    end
  end

  def cached_property(property_id)
    # Rails.cache.fetch propaga exceções normalmente, mas vamos garantir que
    # se retornar nil, também lançamos RecordNotFound
    property = Rails.cache.fetch("property/#{property_id}", expires_in: 15.minutes) do
      show_property_use_case.execute(property_id)
    end
    
    # Se property for nil, lança RecordNotFound
    raise ActiveRecord::RecordNotFound, "Property not found" unless property
    
    property
  end

  def invalidate_property_cache(property_id)
    Rails.cache.delete("property/#{property_id}")
  end

  def categories_use_case
    raise NotImplementedError, "Controller deve definir categories_use_case"
  end

  def show_property_use_case
    raise NotImplementedError, "Controller deve definir show_property_use_case"
  end
end

