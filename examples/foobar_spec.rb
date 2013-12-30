# Run with:
# rspec -Ilib examples/foobar_spec.rb

require 'rspec'
require 'test_construct/rspec_integration'

describe "Foobar", test_construct: true do

  it "creates file" do
    example.metadata[:construct].directory "alice/rabbithole" do |d|
      d.file "white_rabbit.txt", "I'm late!"
      File.read("white_rabbit.txt").should == "I'm late!"
    end
  end

  it "leaves file on error" do
    example.metadata[:construct].directory "alice/rabbithole" do |d|
      d.file "white_rabbit.txt", "I'm late!"
      raise "Whoops"
    end
  end

end

describe "Foobar", test_construct: { keep_on_error: false} do

  it "doesn't leave file on error" do
    example.metadata[:construct].directory "alice/rabbithole" do |d|
      d.file "white_rabbit.txt", "I'm late!"
      raise "Whoops"
    end
  end

end
