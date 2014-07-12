require 'spec_helper'

describe Doc2Text::Markdown::Document do
  before :all do
    @odt = Doc2Text::Odt::Document.new ''
    def @odt.extract_path
      'spec/testdata'
    end
    @output = StringIO.new
    @markdown = Doc2Text::Markdown::Document.new @output
    @odt.parse @markdown
  end

  after :all do
    @markdown.close
  end

  it 'support xpath' do
    result = @markdown.xpath '/office:document-content/office:automatic-styles/style:style'
    expect(result.length).to be 5
  end

  it 'parses simple bold and italic text' do
    expect(@output.string).to eq <<MD

Normal text

**Bold text**<br/>_Italic text_<br/>Underline text

_**Bold text & Italic text & Underline text**_
MD
  end
end
