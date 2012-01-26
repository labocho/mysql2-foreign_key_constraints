module Mysql2
  module ForeignKeyConstraints
    module SchemaDumper
      def foreign_key_constraints(stream)
        @connection.tables.sort.each do |tbl|
          next if ['schema_migrations', ignore_tables].flatten.any? do |ignored|
            case ignored
            when String; tbl == ignored
            when Regexp; tbl =~ ignored
            else
              raise StandardError, 'ActiveRecord::SchemaDumper.ignore_tables accepts an array of String and / or Regexp values.'
            end
          end
          foreign_key_constraints_of_table(tbl, stream)
        end
      end

      def foreign_key_constraints_of_table(table, stream)
        add_foreign_key_constraint_statements = @connection.foreign_key_constraints(table).map do |fk|
          parts = ["add_foreign_key " + fk.table.inspect]
          parts << fk.foreign_key.inspect
          parts << fk.reference_table.inspect
          parts << fk.reference_key.inspect
          parts << ":name => " + fk.name.inspect
          "  " + parts.join(", ")
        end

        unless add_foreign_key_constraint_statements.empty?
          stream.puts add_foreign_key_constraint_statements.sort.join("\n")
        end
      end
    end
  end
end
