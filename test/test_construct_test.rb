require 'test_helper'

class TestConstructTest < Minitest::Test
  include TestConstruct::Helpers

  def teardown
    TestConstruct.destroy_all!
  end

  testing 'using within_construct explicitly' do

    test 'creates construct' do
      num = rand(1_000_000_000)
      TestConstruct.stubs(:rand).returns(num)
      TestConstruct::within_construct do |construct|
        assert File.directory?(File.join(TestConstruct.tmpdir, "construct_container-#{$PROCESS_ID}-#{num}"))
      end
    end

  end

  testing 'creating a construct container' do

    test 'should exist' do
      num = rand(1_000_000_000)
      self.stubs(:rand).returns(num)
      within_construct do |construct|
        assert File.directory?(File.join(TestConstruct.tmpdir, "construct_container-#{$PROCESS_ID}-#{num}"))
      end
    end

  end

end
