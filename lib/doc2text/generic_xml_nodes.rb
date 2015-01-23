module Doc2Text
  module XmlBasedDocument
    module XmlNodes
      class Node
        attr_reader :parent, :children, :attrs, :prefix, :name
        attr_accessor :text

        def self.inherited(subclass)
          def subclass.titleize(tag)
            tag.split('-').map(&:capitalize).join
          end
        end

        def initialize(parent = nil, attrs = [], prefix = nil, name = nil, markdown_odt_parser = nil)
          @parent, @attrs, @prefix, @name, @xml_parser = parent, attrs, prefix, name, markdown_odt_parser
          @children = []
          @has_text = false
        end

        def root?
          !@parent
        end

        def has_text?
          @has_text
        end

        def open
          ''
        end

        def close
          ''
        end

        def delete
          return true unless @children
          @children.each { |child| child.delete }
          @children = []
        end

        def eql?(object)
          return false unless object.is_a? Node
          object.xml_name == xml_name
        end

        def generic?
          instance_of? Node
        end

        def xml_name
          "#{@prefix}:#{@name}"
        end

        def to_s
          "#{xml_name} : #{attrs}"
        end

        def expand
          expanded = "#{open}#{@children.map(&:expand).join}#{close}"
          delete
          expanded.clone
        end
      end

      class PlainText < Node

        attr_accessor :text

        alias_method :expand, :text

        def initialize(text)
          @text = text
        end
      end
    end
  end
end
