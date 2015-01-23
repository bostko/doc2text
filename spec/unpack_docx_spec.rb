require 'spec_helper'

describe 'docx' do
  def rspec_extract_docx
    @odt = Doc2Text::XmlBasedDocument::Docx::Document.new File.join 'spec', 'fixtures', 'text_styles.docx'
    @odt.unpack

    entries = Dir.glob "#{@odt.extract_path}/**/*"
    mandatory_files = %w([Content_Types].xml).map { |entry|
      File.join @odt.extract_path, entry }
    expect(entries.to_set.subset? mandatory_files.to_set)

    @odt.clean
  end

  it 'can extract a whole document' do
    rspec_extract_docx
    rspec_extract_docx
  end
end
