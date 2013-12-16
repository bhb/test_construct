# TestConstruct

> "This is the construct. It's our loading program. We can load anything, from clothing to equipment, weapons, and training simulations, anything we need" -- Morpheus

TestConstruct is a DSL for creating temporary files and directories during testing.

## SYNOPSIS

    class ExampleTest < Test::Unit::TestCase
      include TestConstruct::Helpers

      def test_example
        within_construct do |c|
          c.directory 'alice/rabbithole' do |d|
            d.file 'white_rabbit.txt', "I'm late!"

            assert_equal "I'm late!", File.read('white_rabbit.txt')
          end
        end
      end

    end

## Installation

Add this line to your application's Gemfile:

    gem 'test_construct'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install test_construct

## Usage

To use TestConstruct, you need to include the TestConstruct module in your class like so:

    include TestConstruct::Helpers

Using construct is as simple as calling `within_construct` and providing a block. All files and directories that are created within that block are created within a temporary directory. The temporary directory is always deleted before `within_construct` finishes.

There is nothing special about the files and directories created with TestConstruct, so you can use plain old Ruby IO methods to interact with them.

### Creating files

The most basic use of TestConstruct is creating an empty file with the:

    within_construct do |construct|
      construct.file('foo.txt')
    end

Note that the working directory is, by default, automatically changed to the temporary directory created by TestConstruct, so the following assertion will pass:

    within_construct do |construct|
      construct.file('foo.txt')
      assert File.exist?('foo.txt')
    end

You can also provide content for the file, either with an optional argument or using the return value of a supplied block:

    within_construct do |construct|
      construct.file('foo.txt', 'Here is some content')
      construct.file('bar.txt') do
        <<-EOS
        The block will return this string, which will be used as the content.
        EOS
      end
    end

If you provide block that accepts a parameter, construct will pass in the IO object. In this case, you are responsible for writing content to the file yourself - the return value of the block will not be used:

    within_construct do |construct|
      construct.file('foo.txt') do |file|
        file << "Some content\n"
        file << "Some more content"
      end
    end

Finally, you can provide the entire path to a file and the parent directories will be created automatically:

    within_construct do |construct|
      construct.file('foo/bar/baz.txt')
    end

### Creating directories

It is easy to create a directory:

    within_construct do |construct|
      construct.directory('foo')
    end

You can also provide a block. The object passed to the block can be used to create nested files and directories (it's just a [Pathname](http://www.ruby-doc.org/stdlib/libdoc/pathname/rdoc/index.html) instance with some extra functionality, so you can use it to get the path of the current directory).

Again, note that the working directory is automatically changed while in the block:

    within_construct do |construct|
      construct.directory('foo') do |dir|
        dir.file('bar.txt')
        assert File.exist?('bar.txt') # This assertion will pass
      end
    end

Again, you can provide paths and the necessary directories will be automatically created:


    within_construct do |construct|
      construct.directory('foo/bar/') do |dir|
        dir.directory('baz')
        dir.directory('bazz')
      end
    end

Please read test/construct_test.rb for more examples.

### Disabling chdir

In some cases, you may wish to disable the default behavior of automatically changing the current directory. For example, changing the current directory will prevent Ruby debuggers from displaying source code correctly.

If you disable, automatic chdir, note that your old assertions will not work:

```
within_construct(:chdir => false) do |construct|
  construct.file("foo.txt")
  # Fails. foo.txt was created in construct, but 
  # the current directory is not the construct!
  assert File.exists?("foo.txt")
end
```

To fix, simply use the `Pathname` passed to the block:

```
within_construct(:chdir => false) do |construct|
  construct.file("foo.txt")
  # Passes
  assert File.exists?(construct+"foo.txt")
end
```

### Keeping directories around

You may find it convenient to keep the created directory around after a test has completed, in order to manually inspect its contents.

```ruby
within_construct do |construct|
  # ...
  construct.keep
end
```

Most likely you only want the directory to stick around if something goes wrong. To do this, use the `:keep_on_error` option.

```ruby
within_construct(keep_on_error: true) do |construct|
  # ...
  raise "some error"
end
```

TestConstruct will also annotate the exception error message to tell you where the generated files can be found.

### Setting the base directory

By default, TestConstruct puts its temporary container directories in your system temp dir. You can change this with the `:base_dir` option:

```ruby
tmp_dir = File.expand_path("../../tmp", __FILE__)
within_construct(base_dir: tmp_dir) do |construct|
  construct.file("foo.txt")
  # Passes
  assert File.exists?(tmp_dir+"/foo.txt")
end
```

### Naming the created directories

Normally TestConstruct names the container directories it creates using a combination of a `test-construct-` prefix, the current process ID, and a random number. This ensures that the name is unlikely to clash with directories left over from previous runs. However, it isn't very meaningful. You can optionally make the directory names more recognizable by specifying a `:name` option. TestConstruct will take the string passed, turn it into a normalized "slug" without any funny characters, and append it to the end of the generated dirname.

```ruby
within_construct(name: "My best test ever!") do |construct|
  # will generate something like:
  # /tmp/construct-container-1234-5678-my-best-test-ever
end
```

### RSpec Integration

TestConstruct comes with RSpec integration. Just require the `test_construct/rspec_integration` file in your `spec_helper.rb` or in your spec file. Then tag the tests you want to execute in the context of a construct container with `test_construct: true` using RSpec metadata:

```ruby
require "test_construct/rspec_integration"

describe Foo, test_construct: true do
  # ...
end
```

By default the current working directory will be switched to the construct container within tests; the container name will be derived from the name of the current example; and if a test fails, the container will be kept around. Information about where to find it will be added to the test failure message.

You can tweak any TestConstruct options by passing a hash as the value of the `:test_construct` metadata key.

```ruby
require "test_construct/rspec_integration"

describe Foo, test_construct: {keep_on_error: false} do
  # ...
end
```

If you want access to the construct container, currently the only way to get it is to grab it from the example metadata:

```ruby
require "test_construct/rspec_integration"

describe Foo, test_construct: true do
  it "should do stuff" do |example|
    example[:construct].file "somefile"
    example[:construct].directory "somedir"
    # ...
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
