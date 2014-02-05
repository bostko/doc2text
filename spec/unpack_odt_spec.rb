require 'spec_helper'

describe 'odt' do
  before :all do
    @odt = Doc2Text::Odt.new File.join('testdata', 'text_styles.odt')
    @odt.unpack
  end

  after :all do
    @odt.clean
  end

  it 'can extract a whole document' do
    entries = Dir.glob("#{@odt.extract_path}/**/*")
    %w(manifest.rdf Configurations2 Configurations2/accelerator Configurations2/accelerator/current.xml Configurations2/images Configurations2/images/Bitmaps
       content.xml settings.xml styles.xml META-INF META-INF/manifest.xml meta.xml Thumbnails Thumbnails/thumbnail.png mimetype).map { |entry|
      File.join @odt.extract_path, entry }.should eq entries
  end

  it 'has a content file' do
    parser = Doc2Text::Odt2MdXpath.new @odt
    parser.parse_content
  end
end
