require 'spec_helper'

describe Doc2Text::UnpackOdt do
  it 'can extract a whole document' do
    unpack_odt = Doc2Text::UnpackOdt.new File.join('testdata', 'text_styles.odt')
    unpack_odt.unpack

    begin
      entries = Dir.glob("#{Doc2Text::UnpackOdt::EXTRACT_PATH}/**/*")
      %w(manifest.rdf Configurations2 Configurations2/accelerator Configurations2/accelerator/current.xml Configurations2/images Configurations2/images/Bitmaps
         content.xml settings.xml styles.xml META-INF META-INF/manifest.xml meta.xml Thumbnails Thumbnails/thumbnail.png mimetype).map { |entry|
        File.join Doc2Text::UnpackOdt::EXTRACT_PATH, entry }.should eq entries
    ensure
      unpack_odt.clean
    end
  end
end
