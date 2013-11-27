require 'spec_helper'

describe "TestConstruct" do

  describe "using within_construct explicitly" do

    it "creates construct" do
      num = rand(1_000_000_000)
      TestConstruct.stubs(:rand).returns(num)
      TestConstruct::within_construct do |construct|
        File.directory?(File.join(TestConstruct.tmpdir, "construct_container-#{$PROCESS_ID}-#{num}")).must_equal true
      end
    end
  end
end
