# Run with:
#   rspec --format doc --order defined examples/test_construct_spec.rb

# We can't replace the usage of the instance variable with a let or method call,
# since the example isn't available then, so we disable the warning:
#   rubocop:disable RSpec/InstanceVariable

require "test_construct/rspec_integration"

RSpec.describe TestConstruct do
  before do
    stub_const("TEST_PATH", "alice/rabbithole")
    stub_const("TEST_FILE", "white_rabbit.txt")
    stub_const("TEST_CONTENTS", "I'm late!")
  end

  describe "when not enabled in describe block" do
    it "is disabled in examples" do |example|
      expect(example.metadata).not_to include(:construct)
    end

    it "can be enabled for example", test_construct: true do |example|
      expect(example.metadata).to include(:construct)
    end

    context "when enabled in context", test_construct: true do
      it "is enabled in examples" do |example|
        expect(example.metadata).to include(:construct)
      end
    end
  end

  describe "when enabled in describe block", test_construct: true do
    before { |example| @construct = example.metadata[:construct] }

    it "can be disabled for an example", test_construct: false do
      expect(@context).to be_nil
    end

    context "when disabled in context", test_construct: false do
      it "is disabled in examples" do |example|
        expect(example.metadata).not_to include(:construct)
      end
    end

    it "leaves file on error" do
      @construct.directory TEST_PATH do |path|
        path.file(TEST_FILE, TEST_CONTENTS)
        raise "Expected to fail"
      end
    end

    context "when keep_on_error is disabled for an example" do
      it "doesn't leave file", test_construct: { keep_on_error: false } do
        @construct.directory TEST_PATH do |path|
          path.file TEST_FILE, TEST_CONTENTS
          raise "Expected to fail"
        end
      end
    end

    describe ".directory" do
      it "creates directory" do
        @construct.directory("alice")
        expect(Dir.exist?("alice")).to be true
      end

      it "creates directory and sudirectories" do
        @construct.directory(TEST_PATH)
        expect(Dir.exist?(TEST_PATH)).to be true
      end

      it "runs block in directory" do
        @construct.directory TEST_PATH do |path|
          path.file TEST_FILE, TEST_CONTENTS
        end
        filename = File.join(TEST_PATH, TEST_FILE)
        expect(File.read(filename)).to eq(TEST_CONTENTS)
      end
    end

    describe ".file" do
      it "creates empty file" do
        @construct.file(TEST_FILE)
        expect(File.read(TEST_FILE)).to eq("")
      end

      it "creates file with content from optional argument" do
        @construct.file(TEST_FILE, TEST_CONTENTS)
        expect(File.read(TEST_FILE)).to eq(TEST_CONTENTS)
      end

      it "creates file with content from block" do
        @construct.file(TEST_FILE) { TEST_CONTENTS }
        expect(File.read(TEST_FILE)).to eq(TEST_CONTENTS)
      end

      it "creates file and provides block IO object" do
        @construct.file(TEST_FILE) { |file| file << TEST_CONTENTS }
        expect(File.read(TEST_FILE)).to eq(TEST_CONTENTS)
      end
    end
  end

  describe "when keep_on_error is disabled in describe block",
           test_construct: { keep_on_error: false } do
    it "doesn't leave file on error" do |example|
      example.metadata[:construct].directory TEST_PATH do |path|
        path.file TEST_FILE, TEST_CONTENTS
        raise "Expected to fail"
      end
    end
  end
end

# rubocop:enable RSpec/InstanceVariable
