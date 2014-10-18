require 'logger'

module Doc2Text
  module Markdown
    class OdtParser
      def initialize(output)
        @output = output
        @automatic_styles = {}
      end

      def new_node(prefix, name, attrs)
        unless @xml_root
          @xml_root = @current_node = Odt::XmlNodes::Node.create_node prefix, name, nil, attrs, self
        else
          new_node = Odt::XmlNodes::Node.create_node prefix, name, @current_node, attrs, self
          @current_node.children << new_node
          @current_node = new_node
        end
      end

      def close_node(prefix, name)
        # if Odt::XmlNodes::Node.create_node(prefix, name, nil, [], self).eql? @current_node
          if @current_node.parent and @current_node.parent.office_text?
            @output << @current_node.expand
            @current_node.delete
          end
          @current_node = @current_node.parent
        # else
        #   # TODO remove this redundant(tree build algorithm) checks
        #   raise Doc2Text::XmlError, "!Close node child #{prefix} #{name} IS NOT correct, CURRENT_ELEM #{@current_node}"
        # end
      end

      def text(string)
        plain_text = Odt::XmlNodes::PlainText.new(string)
        @current_node.children << plain_text
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
        if /^(\/[\w:\-]+)+$/ =~ string
          path = string.scan /[\w:\-]+/
          seek_nodes = [@xml_root]
          path.each_with_index do |xml_name, index|
            seek_nodes.select! { |node| node.xml_name == xml_name }
            seek_nodes = seek_nodes.map(&:children).flatten unless index == path.length - 1
            break if seek_nodes.empty?
          end
          seek_nodes
        else
          raise Doc2Text::XmlError, 'it does not support this xpath syntax'
        end
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end
    end
  end
end
