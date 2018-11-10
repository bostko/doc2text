require 'logger'

module Doc2Text
  module Markdown
    class DocxParser < Nokogiri::XML::SAX::Document
      def initialize(output, styles_xml_root = nil)
        @styles_xml_root = styles_xml_root
        @output = output
        @automatic_styles = {}
      end

      def start_element_namespace(name ,attrs = [], prefix = nil, uri = nil, ns = [])
        unless @xml_root
          @xml_root = @current_node = Docx::XmlNodes::Node.create_node prefix, name, nil, attrs, self
        else
          new_node = Docx::XmlNodes::Node.create_node prefix, name, @current_node, attrs, self
          @current_node.children << new_node
          @current_node = new_node
        end
      end

      def end_element_namespace(name, prefix = nil, uri = nil)
        if @current_node.parent and @current_node.parent.body?
          @output << @current_node.expand
          @current_node.delete
        end
        @current_node = @current_node.parent
      end

      def characters(string)
        unless string.strip.empty?
          plain_text = Docx::XmlNodes::PlainText.new(string)
          @current_node.children << plain_text
        end
      end

      def close
        @output.close
      end

      def print_tree(node)
        puts node
        node.children.each do |child|
          print_tree child
        end
      end

      # Select nodes xpath style
      # - supports selecting from the root node
      def xpath(string)
        patterns = string.split '|'
        raise Doc2Text::XmlError, 'it does not support this xpath syntax' if patterns.length == 0
        result = []
        patterns.each do |pattern|
          if /^(\/[\w:\-]+)+$/ =~ pattern
            path = pattern.scan /[\w:\-]+/
            result += xpath_search_nodes(path, @xml_root)
            result += xpath_search_nodes(path, @styles_xml_root) if @styles_xml_root
          else
            raise Doc2Text::XmlError, 'it does not support this xpath syntax'
          end
        end
        result
      end

      def xpath_search_nodes(path, xml_root)
        seek_nodes = [xml_root]
        path.each_with_index do |xml_name, index|
          seek_nodes.select! { |node| node.xml_name == xml_name }
          seek_nodes = seek_nodes.map(&:children).flatten unless index == path.length - 1
          break if seek_nodes.empty?
        end
        seek_nodes
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end
    end
  end
end
