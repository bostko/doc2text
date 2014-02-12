module Doc2Text
  module Markdown
    class Document
      def initialize(output)
        @output = File.open output, 'w'
        @automatic_styles = {}
      end

      def new_node(prefix, name, attrs)
        unless @xml_root
          @xml_root = @current_node = Odt::XmlNodes::Node.create_node prefix, name, nil, attrs
        else
          new_node = Odt::XmlNodes::Node.create_node prefix, name, @current_node, attrs
          @current_node.children << new_node
          @current_node = new_node
          puts "created node in the markdown tree #{@current_node.xml_name}, generic: #{@current_node.generic?}"
          self << @current_node.open
        end
      end

      def close_node(prefix, name)
        if Odt::XmlNodes::Node.create_node(prefix, name).eql? @current_node
          remove_current_node!
        elsif Odt::XmlNodes::Node.create_node(prefix, name).eql? @current_node.parent
          remove_current_node!
          remove_current_node!
        else
          # TODO remove this redundant(tree build algorithm) checks
          raise Doc2Text::XmlError, "!Close node child #{prefix} #{name} IS NOT correct, CURRENT_ELEM #{@current_node}"
        end
      end

      def remove_current_node!
        return unless @current_node
        self << @current_node.close
        node_for_deletion = @current_node
        @current_node = @current_node.parent
        return unless @current_node
        @current_node.remove_last_child! node_for_deletion
      end

      def <<(string)
        @output << string
      end

      def close
        @output.close
      end

      def add_automatic_style(style)
      end
    end
  end
end
