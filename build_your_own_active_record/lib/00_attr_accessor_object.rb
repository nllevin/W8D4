require 'byebug'

class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      attr_str = "@#{ name }"
      define_method(name) { instance_variable_get(attr_str) }
      define_method(name.to_s + "=") { |val| instance_variable_set(attr_str, val) }
    end
  end
end
