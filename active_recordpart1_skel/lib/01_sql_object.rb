require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # this is so if columns is called again, we'd return the columns
    # we already queried rather than run the database search again
    return @return_array if @return_array

    col_array = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    @return_array = []
    col_array.first.each do |col|
      @return_array << col.to_sym
    end

    @return_array

  end

  def self.finalize!
    columns.each do |col|
      define_method(col) do
        attributes[col]
      end

      define_method("#{col}=") do |value|
        attributes[col] = value
      end
    end
  end

  def self.table_name=(table_name)
    # ...
  end

  def self.table_name
    self.to_s.downcase + "s"
  end

  def self.all
    # p self
    pall = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    parse_all(pall)
    # self.parse_all(pall)
  end

  def self.parse_all(results)
    results.map do |el|
       self.new(el)
    end
  end

  def self.find(id)
    blah = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL
    p blah
    blah

  end

  def initialize(params = {})
    col = self.class.columns

    params.each do |attr_name, v|
      raise "unknown attribute '#{attr_name}'" if !col.include?(attr_name.to_sym)
      self.send("#{attr_name}=", v)
      # we need to call this on the instance of this class so only self and not self.class
      # we need to call the attr_name setter method which we ALREADY created during the
      # finalize! method.
      # it wasn't completely clear, but finalize! is called before initialize
    end

    # send(attributes)


  end

  def attributes
    @attributes = Hash.new() if !@attributes
    @attributes
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
