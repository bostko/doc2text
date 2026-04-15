require 'spec_helper'

describe 'docx' do
  def rspec_extract_docx
    @odt = Doc2Text::Docx::Document.new File.join 'spec', 'fixtures', 'text_styles.docx'
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

  it 'parses styles from word/styles.xml' do
    docx = Doc2Text::Docx::Document.new File.join 'spec', 'fixtures', 'text_styles.docx'
    docx.unpack
    begin
      styles_root = docx.parse_styles
      expect(styles_root).not_to be_nil
      expect(styles_root.xml_name).to eq 'w:styles'
    ensure
      docx.clean
    end
  end

  it 'can parse and save a docx document' do
    output_file = File.join 'spec', 'fixtures', 'output.md'
    begin
      Doc2Text::Docx::Document.parse_and_save(
        File.join('spec', 'fixtures', 'text_styles.docx'),
        output_file
      )
      expect(File.exist?(output_file)).to be true
    ensure
      File.delete(output_file) if File.exist?(output_file)
    end
  end
end
