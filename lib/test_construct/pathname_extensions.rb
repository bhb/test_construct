module TestConstruct
  module PathnameExtensions

    attr_accessor :construct__chdir_default, :construct__root, :construct__orig_dir
    def directory(path, opts = {})
      chdir = opts.fetch(:chdir, construct__chdir_default)
      subdir = (self + path)
      subdir.mkpath
      subdir.extend(PathnameExtensions)
      subdir.construct__root = construct__root || self
      subdir.maybe_change_dir(chdir) do
        yield(subdir) if block_given?
      end
      subdir
    end

    def file(filepath, contents = nil, &block)
      path = (self+filepath)
      path.dirname.mkpath
      mode = RUBY_PLATFORM =~ /mingw|mswin/ ? 'wb:UTF-8' : 'w'
      File.open(path, mode) do |f|
        if(block)
          if(block.arity==1)
            block.call(f)
          else
            f << block.call
          end
        else
          f << contents
        end
      end
      path
    end

    def maybe_change_dir(chdir, &block)
      if(chdir)
        self.construct__orig_dir ||= Pathname.pwd
        self.chdir(&block)
      else
        block.call if block
      end
    end

    def revert_cwd
      if construct__orig_dir
        Dir.chdir(construct__orig_dir)
      end
    end

    # Note: Pathname implements #chdir directly, but it is deprecated in favor
    # of Dir.chdir
    def chdir(&block)
      Dir.chdir(self, &block)
    end

    def destroy!
      rmtree
    end

    def finalize
      revert_cwd
      destroy! unless keep?
    end

    def keep
      if construct__root
        construct__root.keep
      else
        @keep = true
      end
    end

    def keep?
      defined?(@keep) && @keep
    end

    def annotate_exception!(error)
      error.message << exception_message_annotation
      error
    end

    def exception_message_annotation
      "\nTestConstruct files kept at: #{self}"
    end
  end
end
