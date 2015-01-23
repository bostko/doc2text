require 'spec_helper'

describe 'odt' do
  def rspec_extract_odt
    @odt = Doc2Text::XmlBasedDocument::Odt::Document.new File.join 'spec', 'fixtures', 'text_styles.odt'
    @odt.unpack

    entries = Dir.glob "#{@odt.extract_path}/**/*"
    mandatory_files = %w(manifest.rdf content.xml settings.xml styles.xml META-INF META-INF/manifest.xml meta.xml mimetype).map { |entry|
      File.join @odt.extract_path, entry }
    expect(entries.to_set.subset? mandatory_files.to_set)

    @odt.clean
  end

  it 'can extract a whole document' do
    rspec_extract_odt
    rspec_extract_odt
  end
end
