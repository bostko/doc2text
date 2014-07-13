module Doc2Text
  module Odt
    module Content
      class Document < ::Nokogiri::XML::SAX::Document
        def initialize(markdown_odt_parser)
          @markdown_odt_parser = markdown_odt_parser
        end

        def start_element_namespace(name ,attrs = [], prefix = nil, uri = nil, ns = [])
          @markdown_odt_parser.new_node prefix, name, attrs
        end

        def end_element_namespace(name, prefix = nil, uri = nil)
          @markdown_odt_parser.close_node prefix, name
        end

        def characters(string)
          unless string.strip.empty?
            @markdown_odt_parser << string
          end
        end
      end
    end
  end
end
