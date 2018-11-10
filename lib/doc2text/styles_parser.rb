module Doc2Text
  module Odt
    class StylesParser < Nokogiri::XML::SAX::Document
      attr_reader :xml_root

      def start_element_namespace(name ,attrs = [], prefix = nil, uri = nil, ns = [])
        unless @xml_root
          @xml_root = @current_node = Doc2Text::Odt::XmlNodes::Node.create_node prefix, name, nil, attrs, self
        else
          new_node = Doc2Text::Odt::XmlNodes::Node.create_node prefix, name, @current_node, attrs, self
          @current_node.children << new_node
          @current_node = new_node
        end
      end

      def end_element_namespace(name, prefix = nil, uri = nil)
        @current_node = @current_node.parent
      end

      def characters(_)
      end

      def xpath(_)
        []
      end
    end
  end
end
