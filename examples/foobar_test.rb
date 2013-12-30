# Run with:
# ruby -Ilib examples/foobar_test.rb

require 'test_construct'
require 'test/unit'

class FoobarTest < Test::Unit::TestCase
  include TestConstruct::Helpers

  def test_directory_and_files
    within_construct do |c|
      c.directory 'alice/rabbithole' do |d|
        d.file 'white_rabbit.txt', "I'm late!"

        assert_equal "I'm late!", File.read('white_rabbit.txt')
      end
    end
  end

  def test_keeping_directory_on_error
    within_construct(keep_on_error: true) do |c|
      c.directory 'd' do |d|
        d.file 'doughnut.txt'
        raise "whoops"
      end
    end
  end

  def test_deleting_directory_on_error
    within_construct(keep_on_error: false) do |c|
      c.directory 'd' do |d|
        d.file 'doughnut.txt'
        raise "whoops"
      end
    end
  end

end
