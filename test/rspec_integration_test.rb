require 'test_helper'

def unindent(s)
  s.gsub(/^#{s.scan(/^[ \t]+(?=\S)/).min}/, '')
end

class RspecIntegrationTest < Minitest::Test
  include TestConstruct::Helpers

  def teardown
    Dir.chdir File.expand_path("../..", __FILE__)
    TestConstruct.destroy_all!
  end

  testing 'using the test_construct' do
    test 'using test_construct does not cause an error' do
      lib_path = File.realpath('lib')
      within_construct do |construct|
        spec_file_name = 'test_construct_spec.rb'
        construct.file(spec_file_name, unindent(<<-RSPEC))
          require 'test_construct/rspec_integration'
            
          describe 'test_construct', test_construct: true do
            it 'should execute a test that always passes' do
              expect(1).to eq(1)
            end
          end
        RSPEC
        output = `rspec -I '#{lib_path}' #{spec_file_name}`
        assert $CHILD_STATUS.success?, output
      end
    end
  end
end
