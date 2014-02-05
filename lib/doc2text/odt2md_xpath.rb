require 'pry'
module Doc2Text
  class Odt2MdXpath
    def initialize(odt)
      @odt = odt
    end

    def parse_content
      nokogiri_doc = @odt.xml_file 'content.xml', 'document-content'
    end
  end
end
