require 'minitest'
require "minitest/autorun"

require 'mocha/minitest'
require 'test_construct'

class Minitest::Test

  def self.testing(name)
    @group = name
    yield
    @group = nil
  end

  def self.test(name, &block)
    name = name.strip.gsub(/\s\s+/, " ")
    group = "#{@group}: " if defined? @group
    test_name = "test_: #{group}#{name}".to_sym
    defined = instance_methods.include? test_name
    raise "#{test_name} is already defined in #{self}" if defined
    define_method(test_name, &block)
  end

end
