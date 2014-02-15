module Doc2Text
  module Markdown
    class Document
      def initialize(output)
        @output = File.open output, 'w'
        @automatic_styles = {}
      end

      def new_node(prefix, name, attrs)
        puts "NEW_NODE: #{prefix} #{name}"
        unless @xml_root
          @xml_root = @current_node = Odt::XmlNodes::Node.create_node prefix, name, nil, attrs
        else
          new_node = Odt::XmlNodes::Node.create_node prefix, name, @current_node, attrs
          @current_node.children << new_node
          @current_node = new_node
          self << @current_node.open
        end
      end

      # Select nodes xpath style
      # - supports selecting from the root node
      def xpath(string)
        mach_data = /^(\/\w+)+$/.match string
        if mach_data

        else
          raise Doc2Text::XmlError, "it does not support this xpath syntax"
        end
      end

      def close_node(prefix, name)
        puts "CLOSE_NODE: #{prefix} #{name}"
        if @current_node.root?
          print_tree @current_node
          puts "Tree printed #{@current_node.root?}"
        end
        #if !@current_node.delete_on_close?
        if Odt::XmlNodes::Node.create_node(prefix, name).eql? @current_node
          if @current_node.delete_on_close?
            remove_current_node!
          else
            remove_current_node! false
          end
        elsif Odt::XmlNodes::Node.create_node(prefix, name).eql? @current_node.parent
          if @current_node.parent.delete_on_close?
            remove_current_node!
            remove_current_node!
          else
            remove_current_node! false
            remove_current_node! false
          end
        else
          # TODO remove this redundant(tree build algorithm) checks
          raise Doc2Text::XmlError, "!Close node child #{prefix} #{name} IS NOT correct, CURRENT_ELEM #{@current_node}"
        end
      end

      def remove_current_node!(remove = true)
        return if !@current_node
        self << @current_node.close
        node_for_deletion = @current_node
        @current_node = @current_node.parent
        return unless @current_node
        if remove
          @current_node.remove_last_child! node_for_deletion
        end
      end

      def <<(string)
        @output << string
      end

      def close
        @output.close
      end

      def add_automatic_style(style)
      end

      def print_tree(node)
        puts node.to_s
        node.children.each do |child|
          print_tree child
        end
      end
    end
  end
end
