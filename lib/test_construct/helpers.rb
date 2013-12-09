require 'English'

module TestConstruct

  module Helpers
    extend self

    def within_construct(opts = {})
      chdir         = opts.fetch(:chdir, true)
      keep_on_error = opts.fetch(:keep_on_error, false)
      container = create_construct(chdir)
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

    def create_construct(chdir = true)
      path = (Pathname(TestConstruct.tmpdir) +
        "#{CONTAINER_PREFIX}-#{$PROCESS_ID}-#{rand(1_000_000_000)}")
      path.mkpath
      path.extend(PathnameExtensions)
      path.construct__chdir_default = chdir
      path
    end

  end

  extend Helpers
end
