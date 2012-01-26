require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Mysql2::ForeignKeyConstraints" do
  before(:each) do
    ActiveRecord::Base.establish_connection(
      YAML.load_file("#{File.dirname(__FILE__)}/database.yml")["test"]
    )
  end

  describe "Statement" do
    before(:each) do
      @migration = Class.new(ActiveRecord::Migration)
    end

    describe "#build_add_foreign_key_constraint_sql" do
      it "shoud_build_sql_with_full_arguments" do
        @migration.instance_eval{
          build_add_foreign_key_constraint_sql(:a, :b, :c, :d)
        }.should == "ALTER TABLE `a` ADD CONSTRAINT `fk_a_refs_c` FOREIGN KEY (`b`) REFERENCES `c` (`d`)"
      end
      it "shoud_build_sql_with_two_arguments" do
        sql = @migration.instance_eval{
          build_add_foreign_key_constraint_sql(:table, :reference_id)
        }.should == "ALTER TABLE `table` ADD CONSTRAINT `fk_table_refs_references` FOREIGN KEY (`reference_id`) REFERENCES `references` (`id`)"
      end
      it "shoud_build_sql_with_three_arguments" do
        @migration.instance_eval{
          build_add_foreign_key_constraint_sql(:a, :b, :c)
        }.should == "ALTER TABLE `a` ADD CONSTRAINT `fk_a_refs_c` FOREIGN KEY (`b`) REFERENCES `c` (`id`)"
      end
      it "shoud_build_sql_for_composite_keys_with_full_arguments" do
        @migration.instance_eval{
          build_add_foreign_key_constraint_sql(:a, [:b1, :b2], :c, [:d1, :d2])
        }.should == "ALTER TABLE `a` ADD CONSTRAINT `fk_a_refs_c` FOREIGN KEY (`b1`, `b2`) REFERENCES `c` (`d1`, `d2`)"
      end
      it "shoud_not_build_sql_for_composite_keys_with_two_arguments" do
        expect {
          @migration.instance_eval do
            build_add_foreign_key_constraint_sql(:table, [:first_reference_id, :second_reference_id])
          end
        }.to raise_error(Mysql2::ForeignKeyConstraints::Constraint::ArgumentError)
      end
      it "shoud_build_sql_for_composite_keys_with_three_arguments" do
        @migration.instance_eval{
          build_add_foreign_key_constraint_sql(:a, [:b1, :b2], :c)
        }.should == "ALTER TABLE `a` ADD CONSTRAINT `fk_a_refs_c` FOREIGN KEY (`b1`, `b2`) REFERENCES `c` (`b1`, `b2`)"
      end
    end
  end
end
