require 'English'

module TestConstruct

  module Helpers
    extend self

    def within_construct(opts = {})
      container = setup_construct(opts)
      yield(container)
    rescue Exception => error
      raise unless container
      teardown_construct(container, error, opts) do |container, error|
        raise error
      end
    else
      teardown_construct(container, nil, opts)
    end

    def create_construct(chdir_or_opts = true, opts={})
      opts = case chdir_or_opts
             when Hash then chdir_or_opts
             else opts.merge(chdir: chdir_or_opts)
             end
      chdir_default = opts.delete(:chdir) {true}
      base_path     = Pathname(opts.delete(:base_dir) { TestConstruct.tmpdir })
      name          = opts.delete(:name){""}
      slug          = name.downcase.tr_s("^a-z0-9", "-")[0..63]
      if opts.any?
        raise "[TestConstruct] Unrecognized options: #{opts.keys}"
      end
      dir = "#{CONTAINER_PREFIX}-#{$PROCESS_ID}-#{rand(1_000_000_000)}"
      dir << "-" << slug unless slug.empty?
      path = base_path + dir
      path.mkpath
      path.extend(PathnameExtensions)
      path.construct__chdir_default = chdir_default
      path
    end

    # THIS METHOD MAY HAVE EXTERNAL SIDE-EFFECTS, including:
    # - creating the container directory tree
    # - changing the current working directory
    #
    # It is intended to be paired with #teardown_construct
    def setup_construct(opts={})
      opts          = opts.dup
      chdir         = opts.fetch(:chdir, true)
      opts.delete(:keep_on_error) { false } # not used in setup
      container = create_construct(opts)
      container.maybe_change_dir(chdir)
      container
    end

    # THIS METHOD MAY HAVE EXTERNAL SIDE-EFFECTS, including:
    # - Removind the container directory tree
    # - changing the current working directory
    # - Modifying any exception passed as `error`
    #
    # It is intended to be paired with #setup_construct
    def teardown_construct(container, error=nil, opts={})
      if error && opts[:keep_on_error]
        container.keep
        container.annotate_exception!(error)
      end
      container.finalize
      yield(container, error) if block_given?
    end
  end

  extend Helpers
end
