require_relative '03_associatable'
require 'byebug'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_options = self.assoc_options[through_name] 

    through_class = through_options.model_class
    through_table = through_options.table_name
    through_primary_key = through_options.primary_key
    through_foreign_key = through_options.foreign_key
    
    
    define_method(name) do
      source_options = through_class.assoc_options[source_name]

      source_table = source_options.table_name
      source_primary_key = source_options.primary_key
      source_foreign_key = source_options.foreign_key
      source_class = source_options.model_class
      
      results = DBConnection.execute(<<-SQL, send(through_foreign_key))
        SELECT
          #{source_table }.*
        FROM
          #{ source_table }
        JOIN
          #{ through_table }
        ON 
          #{ source_table }.#{ source_primary_key } = #{ through_table }.#{ source_foreign_key }
        WHERE
          #{ through_table }.#{ through_primary_key } = ?
      SQL

      source_class.parse_all(results).first
    end
  end
end
