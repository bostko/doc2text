require 'spec_helper'

describe Doc2Text::Markdown::Document do
  before :all do
    @odt = Doc2Text::Odt.new ''
    def @odt.extract_path
      'spec/testdata'
    end
    output = File.open '/dev/null', 'w'
    @markdown = Doc2Text::Markdown::Document.new output
    @odt.parse @markdown
  end

  after :all do
    @markdown.close
  end

  it 'support xpath' do
    result = @markdown.xpath '/office:document-content/office:automatic-styles/style:style'
    result.length.should be 5
  end
end
