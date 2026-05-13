require 'spec_helper'
require 'tempfile'

describe 'odt' do
  def rspec_extract_odt
    @odt = Doc2Text::Odt::Document.new File.join 'spec', 'fixtures', 'text_styles.odt'
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

  context "when the odt is a temporary file" do
    it "runs from a temp file" do
      tempfile = Tempfile.new('text_styles.odt')
      tempfile.write File.read(File.join 'spec', 'fixtures', 'text_styles.odt')
      tempfile.rewind
      tempfile.close

      @odt = Doc2Text::Odt::Document.new tempfile
      @odt.unpack

      entries = Dir.glob "#{@odt.extract_path}/**/*"
      mandatory_files = %w(manifest.rdf content.xml settings.xml styles.xml META-INF META-INF/manifest.xml meta.xml mimetype).map { |entry|
        File.join @odt.extract_path, entry }
      expect(mandatory_files.to_set).to be_subset(entries.to_set)

      tempfile.unlink
      @odt.clean
    end
  end
end
