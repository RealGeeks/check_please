module CheckPlease
  RSpec.describe Path do
    let(:root) { Path.new }

    specify "a new Path describes itself as '/'" do
      expect( root.to_s ).to eq( "/" )
    end

    specify "a path plus a string is a new path with the string added as the last segment" do
      child = root + 'wibble'
      expect( child ).to_not be( root )
      expect( child.to_s ).to eq( "/wibble" )
    end

    specify "a root path has a depth of 1" do
      expect( root.depth ).to eq( 1 )
    end

    specify "a child of the root has a #depth of 2" do
      child = root + 'wibble'
      expect( child.depth ).to eq( 2 )
    end
  end
end
