module Mysql2
  module ForeignKeyConstraints
    module Statement
      # 接続している DB の外部キーの配列を返す
      # 引数で、テーブルを限定できる
      def foreign_key_constraints(table = nil)
        target = case table
        when String
          [table]
        when Array
          table
        else
          tables
        end

        constraints = []

        target.each do |t|
          # "SHOW CREATE TABLE site_monitorings"
          create_table = execute("SHOW CREATE TABLE `#{t}`").to_a[0][1]
          # "CONSTRAINT `site_monitorings_ibfk_1` FOREIGN KEY (`site_id`) REFERENCES `sites` (`id`)"
          create_table.lines.grep(/\A\s*CONSTRAINT `(.*?)` FOREIGN KEY \((.*?)\) REFERENCES `(.*?)` \((.*?)\),?\s*\z/) do
            matches = $~.dup
            name = matches[1]
            foreign_key = matches[2].split(", ").map{|k| k[1..-2]}
            reference_table = matches[3]
            reference_key = matches[4].split(", ").map{|k| k[1..-2]}

            constraints.push Constraint.new(t, foreign_key, reference_table, reference_key, :name => name)
          end
        end

        constraints
      end

      def add_foreign_key_constraint(*args)
        execute build_add_foreign_key_constraint_sql(*args)
      end
      alias_method :add_foreign_key, :add_foreign_key_constraint

      def remove_foreign_key_constraint(*args)
        execute build_remove_foreign_key_constraint_sql(*args)
      end
      alias_method :remove_foreign_key, :remove_foreign_key_constraint

      private
      # target に一致する外部キーオブジェクトを探して返す
      # 名前は無視する
      # なければ nil
      def find_foreign_key_constraint_without_name(target)
        foreign_key_constraints.find{|fk| fk.equal_without_name?(target)}
      end

      # 名前が name の外部キーオブジェクトを探して返す
      # なければ nil
      def find_foreign_key_constraint_by_name(name)
        name = name.to_s
        foreign_key_constraints.find{|fk| fk.name == name}
      end

      # テーブル、外部キー、参照テーブル、参照キー
      def build_add_foreign_key_constraint_sql(*args)
        constraint = Constraint.new(*args)

        # エスケープ
        quoted_name = quote_column_name(constraint.name)
        quoted_table = quote_table_name(constraint.table)
        quoted_reference_table = quote_table_name(constraint.reference_table)
        quoted_foreign_key = constraint.foreign_key.map{|c| quote_column_name(c)}.join(", ")
        quoted_reference_key = constraint.reference_key.map{|c| quote_column_name(c)}.join(", ")

         "ALTER TABLE #{quoted_table} ADD CONSTRAINT #{quoted_name} FOREIGN KEY (#{quoted_foreign_key}) REFERENCES #{quoted_reference_table} (#{quoted_reference_key})"
      end

      # 第一引数は table、:name 指定があればその名前の外部キーを探して、削除するSQLを返す
      # :name 指定がなければ、add_foreign_key と同じ引数で外部キーを探して、削除するSQLを返す
      def build_remove_foreign_key_constraint_sql(*args)
        constraint = nil
        if name = args.dup.extract_options![:name]
          constraint = find_foreign_key_constraint_by_name(name)
          raise "Could not find constraint named '#{name}'" unless constraint
        else
          q = Constraint.new(*args)
          constraint = find_foreign_key_constraint_without_name(q)
          raise "Could not find constraint for #{q.inspect}" unless constraint
        end

        # エスケープ
        quoted_name = quote_column_name(constraint.name)
        quoted_table = quote_table_name(constraint.table)

        "ALTER TABLE #{quoted_table} DROP FOREIGN KEY #{quoted_name}"
      end
    end
  end
end
