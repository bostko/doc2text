require 'spec_helper'

describe Doc2Text::OdtXML do
  context 'SAX' do
    it 'is able to review docs' do
      # Create our parser
      parser = Nokogiri::XML::SAX::Parser.new(Doc2Text::OdtXML.new)
      # Send some XML to the parser

      parser.parse(File.open('testdata/text_styles_unzipped/content_beauty.xml'))
    end
  end
end
