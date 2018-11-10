require 'spec_helper'

describe Doc2Text::Markdown::OdtParser do
  before do
    @odt = Doc2Text::Odt::Document.new ''
    @output = StringIO.new
    @markdown_odt_parser = Doc2Text::Markdown::OdtParser.new @output
    @parser = Nokogiri::XML::SAX::Parser.new(@markdown_odt_parser)
  end

  it 'Parses headers' do
    paragraphs = <<XML
      <office:text>
        <text:h text:outline-level="1">Title 1</text:h>
        <text:h text:outline-level="2">Title 1.1</text:h>
        <text:h text:outline-level="1">Title 2</text:h>
      </office:text>
XML

    @parser.parse StringIO.new(paragraphs)
    expect(@output.string.clone).to eq <<MARKDOWN

# Title 1


## Title 1.1


# Title 2

MARKDOWN
  end

  it 'Parses paragraphs' do
    paragraphs = <<XML
      <office:text>
        <text:p>Paragraph 1<text:line-break/><text:span>new line</text:span></text:p>
        <text:p>Paragraph 2</text:p>
        <text:p>Paragraph 3</text:p>
      </office:text>
XML

    @parser.parse StringIO.new(paragraphs)
    expect(@output.string.clone).to eq <<MARKDOWN

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

    @parser.parse StringIO.new(odt_list)

    expect(@output.string).to eq <<MARKDOWN

* World
* Hello
MARKDOWN
  end

  it 'supports tables' do
    odt_table = <<XML
      <office:text>
        <table:table table:name="Table1" table:style-name="Table1">
          <table:table-column table:style-name="Table1.A" table:number-columns-repeated="2"/>
          <table:table-row>
            <table:table-cell table:style-name="Table1.A1" office:value-type="string">
              <text:p text:style-name="P6">A1</text:p>
            </table:table-cell>
            <table:table-cell table:style-name="Table1.B1" office:value-type="string">
              <text:p text:style-name="P6">A2</text:p>
            </table:table-cell>
          </table:table-row>
          <table:table-row>
            <table:table-cell table:style-name="Table1.A2" office:value-type="string">
              <text:p text:style-name="P6">B1</text:p>
            </table:table-cell>
            <table:table-cell table:style-name="Table1.B2" office:value-type="string">
              <text:p text:style-name="P6">B2</text:p>
            </table:table-cell>
          </table:table-row>
        </table:table>
      </office:text>
XML
    parser = Nokogiri::XML::SAX::Parser.new(@markdown_odt_parser)
    parser.parse StringIO.new(odt_table)

    expect(@output.string).to eq '
| A1 | A2 |
|---|---|
| B1 | B2 |'
  end

  it 'Leading and trailing paragraphs' do
    content_xml = <<XML
    <office:text>
      <text:sequence-decls>
        <text:sequence-decl text:display-outline-level="0" text:name="Illustration"/>
        <text:sequence-decl text:display-outline-level="0" text:name="Table"/>
        <text:sequence-decl text:display-outline-level="0" text:name="Text"/>
        <text:sequence-decl text:display-outline-level="0" text:name="Drawing"/>
      </text:sequence-decls>
      <text:p>Leading</text:p>
      <text:p>Middle</text:p>
      <text:p>Trailing</text:p>
    </office:text>
XML

    @parser.parse StringIO.new(content_xml)

    expect(@output.string).to eq <<MARKDOWN

Leading

Middle

Trailing
MARKDOWN

  end

  it 'List with leading and trailing paragraphs' do
    content_xml = <<XML
    <office:text>
      <text:sequence-decls>
        <text:sequence-decl text:display-outline-level="0" text:name="Illustration"/>
        <text:sequence-decl text:display-outline-level="0" text:name="Table"/>
        <text:sequence-decl text:display-outline-level="0" text:name="Text"/>
        <text:sequence-decl text:display-outline-level="0" text:name="Drawing"/>
      </text:sequence-decls>
      <text:p text:style-name="P5">Leading</text:p>
      <text:list xml:id="list3312205574515194347" text:style-name="L1">
        <text:list-item>
          <text:p text:style-name="P1">World</text:p>
        </text:list-item>
        <text:list-item>
          <text:p text:style-name="P4">Hello</text:p>
        </text:list-item>
        <text:list-item>
          <text:p text:style-name="P2">sadasd</text:p>
        </text:list-item>
      </text:list>
      <text:p text:style-name="P3">Trailing</text:p>
    </office:text>
XML
    @parser.parse StringIO.new(content_xml)

    expect(@output.string).to eq <<MARKDOWN

Leading

* World
* Hello
* sadasd

Trailing
MARKDOWN

  end

  it 'supports xpath' do
    expect(@odt).to receive(:extract_path).and_return('spec/fixtures/bold_and_italic')
    @odt.parse @markdown_odt_parser
    result = @markdown_odt_parser.xpath '/office:document-content/office:automatic-styles/style:style'
    expect(result.length).to be 5
  end

  it 'parses simple bold and italic text' do
    expect(@odt).to receive(:extract_path).and_return('spec/fixtures/bold_and_italic')
    @odt.parse @markdown_odt_parser

    expect(@output.string.clone).to eq <<MARKDOWN

Normal text

**Bold text**<br/>_Italic text_<br/>Underline text

_**Bold text & Italic text & Underline text**_
MARKDOWN
  end

  after do
    @markdown_odt_parser.close
  end
end
