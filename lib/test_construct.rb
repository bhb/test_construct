require "tmpdir"

require "test_construct/version"
require "test_construct/helpers"
require "test_construct/pathname_extensions"

module TestConstruct

  CONTAINER_PREFIX = 'construct_container'

  def self.tmpdir
    dir = nil
    Dir.chdir Dir.tmpdir do dir = Dir.pwd end # HACK FOR OS X
    dir
  end

  def self.destroy_all!
    Pathname.glob(File.join(tmpdir, CONTAINER_PREFIX + "*")) do |container|
      container.rmtree
    end
  end

end
