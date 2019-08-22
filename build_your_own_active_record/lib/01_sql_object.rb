require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT
        *
      FROM
        #{ table_name }
      LIMIT
        0
    SQL
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) { attributes[column] }
      define_method("#{ column }=") { |val| attributes[column] = val }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || to_s.tableize
  end

  def self.all
    parse_all (
      DBConnection.execute(<<-SQL)
        SELECT
          *
        FROM
          #{ table_name }
      SQL
    )
  end

  def self.parse_all(results)
    results.map { |params| send(:new, params) }
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{ table_name }
      WHERE
        id = ?
    SQL

    result.empty? ? nil : send(:new, result.first)
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name.to_sym)
      send("#{ attr_name }=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |column| send(column) }
  end

  def insert
    insert_cols = self.class.columns.drop(1)
    col_names = insert_cols.join(", ")
    question_marks = (["?"] * insert_cols.length).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{ self.class.table_name } (#{ col_names })
      VALUES
        (#{ question_marks })
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns.drop(1).map do |attr_name|
      "#{ attr_name } = ?"
    end.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1), id)
      UPDATE
        #{ self.class.table_name }
      SET
        #{ set_line }
      WHERE
        id = ?
    SQL
  end

  def save
    if id.nil?
      insert
    else
      update
    end
  end
end
