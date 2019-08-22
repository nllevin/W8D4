require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || name.foreign_key.to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.camelize
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || self_class_name.foreign_key.to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.singularize.camelize
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name.to_s, options)
    define_method(name) do
      val_of_foreign_key = send(options.foreign_key)
      options.model_class.where(id: val_of_foreign_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name.to_s, self.to_s, options)
    define_method(name) do
      foreign_key = options.foreign_key
      options.model_class.where(foreign_key => id)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
