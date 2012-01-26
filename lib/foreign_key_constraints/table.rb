# change_table :foo do |t|
#   t.foreign_key :bar_id
# end
module Mysql2
  module ForeignKeyConstraints
    module Table
      def foreign_key(*args)
        args = args.dup.unshift(@table_name)
        @base.add_foreign_key(*args)
      end

      def remove_foreign_key(*args)
        args = args.dup.unshift(@table_name)
        @base.remove_foreign_key(*args)
      end
    end
  end
end
