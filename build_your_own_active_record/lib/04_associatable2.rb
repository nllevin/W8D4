require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_options = self.assoc_options[through_name] 
    through_class = through_options.model_class
    
    source_options = through_class.assoc_options[source_name]

    define_method(name) do
      val_of_through_foreign_key = send(through_options.foreign_key)
      through_instance = through_class.find(val_of_through_foreign_key)
      
      val_of_source_foreign_key = through_instance.send(source_options.foreign_key)
      source_options.model_class.find(val_of_source_foreign_key)
    end
  end
end
