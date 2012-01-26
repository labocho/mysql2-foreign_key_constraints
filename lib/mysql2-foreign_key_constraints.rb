require "active_record"
require "active_record/connection_adapters/mysql2_adapter" # mysql2

module Mysql2
  module ForeignKeyConstraints
    dir = File.expand_path(File.join(File.dirname(__FILE__), "foreign_key_constraints"))
    autoload :Constraint, "#{dir}/constraint"
    autoload :Table, "#{dir}/table"
    autoload :SchemaDumper, "#{dir}/schema_dumper"
    autoload :Statement, "#{dir}/statement"
  end
end

class ::ActiveRecord::ConnectionAdapters::Mysql2Adapter
  include ::Mysql2::ForeignKeyConstraints::Statement
end

class ::ActiveRecord::ConnectionAdapters::Table
  include ::Mysql2::ForeignKeyConstraints::Table
end

class ::ActiveRecord::SchemaDumper
  include ::Mysql2::ForeignKeyConstraints::SchemaDumper
  def tables_with_foreign_key_constraints(stream)
    tables_without_foreign_key_constraints(stream)
    foreign_key_constraints(stream)
  end
  alias_method_chain :tables, :foreign_key_constraints
end

