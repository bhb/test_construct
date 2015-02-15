require 'test_helper'

class RspecIntegrationTest < Minitest::Test
  include TestConstruct::Helpers

  test 'rspec integration' do
    lib_path = File.realpath('lib')
    within_construct do |construct|
      spec_file_name = 'rspec_spec.rb'
      construct.file(spec_file_name, <<-RSPEC)
require 'test_construct/rspec_integration'

describe 'test_construct', test_construct: true do
  it 'accesses metadata' do |example|
    f = example.metadata[:construct].file "somefile", "abcd"
    expect(f.size).to eq 4
  end
end
      RSPEC
      output = `rspec -I '#{lib_path}' #{spec_file_name}`
      assert $CHILD_STATUS.success?, output
    end
  end
end
