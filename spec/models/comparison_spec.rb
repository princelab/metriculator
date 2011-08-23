require 'spec_helper'

describe Comparison do

  before(:all) do
    Comparison.class_variable_set(:@@ROOT_COMPARISON_DIRECTORY,
                                  (File.join("spec", "tfiles", "comparison_test_files")))
    @comparison = Comparison.create
    Dir.mkdir(@comparison.location_of_graphs.parent)
    Dir.mkdir(@comparison.location_of_graphs)

    @temp_dir_names = %w[stuff sundry welp stuff/beans].map do |p|
      File.join(@comparison.location_of_graphs, p)
    end
    @temp_file_names = %w[stuff/foo.txt sundry/foo.txt welp/foo.txt stuff/beans/foo.txt].map do |f|
      File.join(@comparison.location_of_graphs, f)
    end

    @temp_dir_names.each do |path|
      Dir.mkdir(path)
    end

    @temp_file_names.each do |f|
      File.open(f, "w") do |file|
        file.puts "YO"
      end
    end
  end

  after(:all) do
    # Delete our temp dirs and files
    @temp_file_names.each do |temp_file|
      File.delete(temp_file)
    end
    delete_children_and_then_self(@comparison.location_of_graphs.parent)
  end

  def delete_children_and_then_self(dir)
    Dir.entries(dir).reject {|d| d == "." or d == ".." }.each do |d|
      delete_children_and_then_self(File.join(dir, d))
    end
    Dir.delete(dir)
  end

  it "should set its graph location automatically once saved" do
    @comparison.location_of_graphs.to_s.should == File.join(Comparison.class_variable_get(:@@ROOT_COMPARISON_DIRECTORY), @comparison.id.to_s)
  end

  it "should return nil if the path doesn't exist inside its comparison directory" do
    @comparison.get_files_for_relative_path("hurp/durp/durp").should be_nil
  end

  it "should return nil when asking for files in something that isn't a dir" do
    @comparison.get_files_for_relative_path("stuff/foo.txt").should be_nil
  end


  it "should list full paths of all files in a directory inside its comparison directory" do
    @comparison.get_files_for_relative_path("stuff").should == [File.join(@comparison.location_of_graphs, "stuff/foo.txt")]
  end

  it "should list all directories inside its comparison directory" do
    @comparison.get_directories_for_relative_path("stuff").should == [File.join(@comparison.location_of_graphs, "stuff/beans")]
  end

end
