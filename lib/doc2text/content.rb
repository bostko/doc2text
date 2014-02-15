module Doc2Text
  class Odt
    module Content
      class Document < ::Nokogiri::XML::SAX::Document
        def initialize(markdown_document)
          @markdown_document = markdown_document
        end

        def start_element_namespace(name ,attrs = [], prefix = nil, uri = nil, ns = [])
          @markdown_document.new_node prefix, name, attrs
        end

        def end_element_namespace(name, prefix = nil, uri = nil)
          @markdown_document.close_node prefix, name
        end

        def characters(string)
          unless string.strip.empty?
            @markdown_document << string
          end
        end
      end
    end
  end
end
