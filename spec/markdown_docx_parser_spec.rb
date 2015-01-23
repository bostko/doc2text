require 'spec_helper'

describe Doc2Text::Markdown::OdtParser do
  before do
    @output = StringIO.new
    @markdown_docx_parser = Doc2Text::Markdown::DocxParser.new @output
    @parser = Nokogiri::XML::SAX::Parser.new(@markdown_docx_parser)
  end

  it 'Parses paragraphs some text' do
    document_xml = File.read File.join %w(spec fixtures docx test_styles word document_formatted.xml)

    @parser.parse StringIO.new(document_xml)
    expect(@output.string.clone).to eq <<MARKDOWN

Bold text<br/>Italic text<br/>Underline text
MARKDOWN
  end

  after do
    @markdown_docx_parser.close
  end
end
