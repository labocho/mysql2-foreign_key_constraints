module Mysql2
  module ForeignKeyConstraints
    class Constraint
      class ArgumentError < ::ArgumentError; end
      attr_reader :name, :table, :foreign_key, :reference_table, :reference_key

      # テーブル、外部キー、参照テーブル、参照キー、オプション でオブジェクトをつくる
      # 参照テーブル、参照キーを省略した場合、外部キーから推測される
      # 参照キーを省略した場合、外部キーから推測される
      def initialize(*args)
        opt = args.extract_options!
        table, foreign_key, reference_table, reference_key, = args

        raise ArgumentError("table and foreign_key cannot be null") unless table && foreign_key

        @table = table
        @foreign_key = [foreign_key].flatten
        @reference_table = reference_table || guess_reference_table(@foreign_key)
        @reference_key = [reference_key || guess_reference_key(@foreign_key)].flatten
        @name = opt[:name] || build_name(@table, @reference_table)

        raise ArgumentError("Key columns count must be equal") unless @foreign_key.size == @reference_key.size
      end

      # 名前以外の属性が文字列で一致したら true
      # 名前は一致してもしなくても関係ない
      def equal_without_name?(other)
        table.to_s == other.table.to_s &&
        foreign_key.map{|k| k.to_s} == other.foreign_key.map{|k| k.to_s} &&
        reference_table.to_s == other.reference_table.to_s &&
        reference_key.map{|k| k.to_s} == other.reference_key.map{|k| k.to_s}
      end

      private
      # 参照テーブル名を
      # 外部キー名から推測
      # 外部キーが複数ならエラー
      def guess_reference_table(foreign_key)
        raise ArgumentError, "Cannot omit reference_table when composite foreign_key passed" if foreign_key.size > 1
        foreign_key.first.to_s.gsub(/_id\z/, "").pluralize
      end

      # 参照テーブルのキーを外部キーから推測
      # 外部キーが1つなら id
      # 複数なら外部キーと同じ
      def guess_reference_key(foreign_key)
        if foreign_key.size > 1
          foreign_key
        else
          "id"
        end
      end

      # デフォルトの名前を生成する
      # fk_table_refs_reference_table
      def build_name(table, reference_table)
        (["fk",
          table, "refs",
          reference_table
        ].join("_"))
      end
    end
  end
end
