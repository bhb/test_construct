require "test_construct"
require "rspec"
module TestConstruct
  module RSpecIntegration
    module_function

    # the :test_construct metadata key can be either:
    # - true (for all defaults)
    # - a Hash of options
    # - false/missing (disable the construct for this test)
    def test_construct_options(example)
      options = test_construct_default_options
      options[:name] = example.full_description
      metadata_options = example.metadata[:test_construct]
      if metadata_options.is_a?(Hash)
        options.merge!(metadata_options)
      end
      options
    end

    def test_construct_enabled?(example)
      !!example.metadata[:test_construct]
    end

    def test_construct_default_options
      {
        base_dir:       TestConstruct.tmpdir,
        chdir:          true,
        keep_on_error:  true,
      }
    end
  end
end

RSpec.configure do |config|
  config.include TestConstruct::Helpers
  config.include TestConstruct::RSpecIntegration

  config.before :each do
    next unless test_construct_enabled?(example)
    options = test_construct_options(example)
    example.metadata[:construct] = setup_construct(options)
  end

  config.after :each do
    next unless test_construct_enabled?(example)
    options = test_construct_options(example)
    teardown_construct(
      example.metadata[:construct],
      example.exception,
      options)
  end
end
