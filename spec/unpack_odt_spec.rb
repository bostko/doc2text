require 'spec_helper'

describe 'odt' do
  before :all do
    @odt = Doc2Text::Odt::Document.new File.join 'spec', 'testdata', 'text_styles.odt'
    @odt.unpack
  end

  after :all do
    @odt.clean
  end

  it 'can extract a whole document' do
    entries = Dir.glob "#{@odt.extract_path}/**/*"
    file_list = %w(manifest.rdf Configurations2 Configurations2/accelerator Configurations2/accelerator/current.xml Configurations2/images Configurations2/images/Bitmaps
       content.xml settings.xml styles.xml META-INF META-INF/manifest.xml meta.xml Thumbnails Thumbnails/thumbnail.png mimetype).map { |entry|
      File.join @odt.extract_path, entry }
    expect(file_list).to eq entries
  end
end

describe 'simple parsing' do
  it 'simple integration test' do
  end
end
