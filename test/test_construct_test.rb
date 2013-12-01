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

    test 'should yield to its block' do
      sensor = 'no yield'
      within_construct do
        sensor = 'yielded'
      end
      assert_equal 'yielded', sensor
    end

    test 'block argument should be container directory Pathname' do
      num = rand(1_000_000_000)
      self.stubs(:rand).returns(num)
      within_construct do |container_path|
        expected_path = (Pathname(TestConstruct.tmpdir) +
          "construct_container-#{$PROCESS_ID}-#{num}")
        assert_equal(expected_path, container_path)
      end
    end

    test 'should not exist afterwards' do
      path = nil
      within_construct do |container_path|
        path = container_path
      end
      assert !path.exist?
    end

  end

end
