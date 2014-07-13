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
    mandatory_files = %w(manifest.rdf content.xml settings.xml styles.xml META-INF META-INF/manifest.xml meta.xml mimetype).map { |entry|
      File.join @odt.extract_path, entry }
    expect(entries.to_set.subset? mandatory_files.to_set)
  end
end
