module Doc2Text
  module Odt
    module XmlNodes
      module Node
        attr_reader :parent, :children, :attrs

        def self.create_node(prefix, name, parent = nil, attrs = [], markdown_document = nil)
          begin
            clazz = XmlNodes.const_get "#{titleize prefix}::#{titleize name}"
          rescue NameError => e
            Generic.new(parent, attrs, prefix, name, markdown_document)
          else
            clazz.new(parent, attrs, prefix, name, markdown_document)
          end
        end

        def self.titleize(tag)
          tag.split('-').map(&:capitalize).join
        end

        def initialize(parent = nil, attrs = [], prefix = nil, name = nil, markdown_document = nil)
          @parent, @attrs, @prefix, @name = parent, attrs, prefix, name
          @children = []
        end

        def root?
          !@parent
        end

        def open
          ''
        end

        def close
          ''
        end

        def <<(child)
          @children << child
        end

        def delete_on_close?
          true
        end

        def eql?(object)
          return false unless object.is_a? Node
          object.xml_name == xml_name
        end

        def generic?
          instance_of? Node
        end

        def remove_last_child!(child)
          unless child === @children.last
            # TODO remove this redundant(tree build algorithm) checks
            raise Doc2Text::XmlError, "!The child #{child} IS NOT among the children of #{self}"
          else
            @children.pop
          end
        end

        def xml_name
          "#{@prefix}:#{@name}"
        end

        def to_s
          "#{xml_name} : #{attrs}"
        end

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          def child_options(options)
            @child_options = options
          end
        end
      end
    end
  end
end
