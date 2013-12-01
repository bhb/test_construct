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

    test 'exists' do
      num = rand(1_000_000_000)
      self.stubs(:rand).returns(num)
      within_construct do |construct|
        assert File.directory?(File.join(TestConstruct.tmpdir, "construct_container-#{$PROCESS_ID}-#{num}"))
      end
    end

    test 'yields to its block' do
      sensor = 'no yield'
      within_construct do
        sensor = 'yielded'
      end
      assert_equal 'yielded', sensor
    end

    test 'block argument is container directory Pathname' do
      num = rand(1_000_000_000)
      self.stubs(:rand).returns(num)
      within_construct do |container_path|
        expected_path = (Pathname(TestConstruct.tmpdir) +
          "construct_container-#{$PROCESS_ID}-#{num}")
        assert_equal(expected_path, container_path)
      end
    end

    test 'does not exist afterwards' do
      path = nil
      within_construct do |container_path|
        path = container_path
      end
      assert !path.exist?
    end

    test 'removes entire tree afterwards' do
      path = nil
      within_construct do |container_path|
        path = container_path
        (container_path + 'foo').mkdir
      end
      assert !path.exist?
    end

    test 'removes dir if block raises exception' do
      path = nil
      begin
        within_construct do |container_path|
          path = container_path
          raise 'something bad happens here'
        end
      rescue
      end
      assert !path.exist?
    end

    test 'does not capture exceptions raised in block' do
      err = RuntimeError.new('an error')
      begin
        within_construct do
          raise err
        end
      rescue RuntimeError => e
        assert_same err, e
      end
    end

  end

end
