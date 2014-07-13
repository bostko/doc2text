require 'spec_helper'

describe Doc2Text::Markdown::OdtParser do
  before :each do
    @odt = Doc2Text::Odt::Document.new ''
    @output = StringIO.new
    @markdown = Doc2Text::Markdown::OdtParser.new @output
  end

  after :each do
    @markdown.close
  end

  it 'Parses paragraphs' do
    paragraphs = <<XML
<office:text>
  <text:p>Paragraph 1<text:line-break/><text:span>new line</text:span></text:p>
  <text:p>Paragraph 2</text:p>
  <text:p>Paragraph 3</text:p>
</office:text>
XML

    content = ::Doc2Text::Odt::Content::Document.new @markdown
    parser = Nokogiri::XML::SAX::Parser.new(content)
    parser.parse StringIO.new(paragraphs)

    expect(@output.string).to eq <<MARKDOWN

Paragraph 1<br/>new line

Paragraph 2

Paragraph 3
MARKDOWN
  end

  it 'supports lists' do
    odt_list = <<XML
<office:text>
  <text:list xml:id="list61294269356111307" text:style-name="L1">
    <text:list-item>
      <text:p text:style-name="P4">World</text:p>
    </text:list-item>
    <text:list-item>
      <text:p text:style-name="P3">Hello</text:p>
    </text:list-item>
  </text:list>
</office:text>
XML

    content = ::Doc2Text::Odt::Content::Document.new @markdown
    parser = Nokogiri::XML::SAX::Parser.new(content)
    parser.parse StringIO.new(odt_list)

    expect(@output.string).to eq <<MARKDOWN
* World
* Hello
MARKDOWN
  end

  it 'supports xpath' do
    allow(@odt).to receive(:extract_path).and_return('spec/testdata/bold_and_italic')
    @odt.parse @markdown
    result = @markdown.xpath '/office:document-content/office:automatic-styles/style:style'
    expect(result.length).to be 5
  end

  it 'parses simple bold and italic text' do
    allow(@odt).to receive(:extract_path).and_return('spec/testdata/bold_and_italic')
    @odt.parse @markdown

    expect(@output.string).to eq <<MARKDOWN

Normal text

**Bold text**<br/>_Italic text_<br/>Underline text

_**Bold text & Italic text & Underline text**_
MARKDOWN
  end
end
