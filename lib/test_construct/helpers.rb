require 'English'

module TestConstruct

  module Helpers
    extend self

    def within_construct(opts = {})
      chdir         = opts.fetch(:chdir, true)
      keep_on_error = opts.delete(:keep_on_error) { false }
      container = create_construct(opts)
      container.maybe_change_dir(chdir) do
        yield(container)
      end
    rescue Exception => error
      if keep_on_error
        container.keep
        raise error, "#{error.message}\nTestConstruct files kept at: #{container}"
      else
        raise
      end
    ensure
      container.finalize if container.respond_to?(:finalize)
    end

    def create_construct(chdir_or_opts = true, opts={})
      opts = case chdir_or_opts
             when Hash then chdir_or_opts
             else opts.merge(chdir: chdir_or_opts)
             end
      base_path = Pathname(opts.fetch(:base_dir) { TestConstruct.tmpdir })
      path = base_path + "#{CONTAINER_PREFIX}-#{$PROCESS_ID}-#{rand(1_000_000_000)}"
      path.mkpath
      path.extend(PathnameExtensions)
      path.construct__chdir_default = opts.fetch(:chdir, true)
      path
    end

  end

  extend Helpers
end
