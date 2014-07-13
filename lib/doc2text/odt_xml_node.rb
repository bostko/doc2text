module Doc2Text
  module Odt
    module XmlNodes
      module Node
        attr_reader :parent, :children, :attrs, :prefix, :name

        def self.create_node(prefix, name, parent = nil, attrs = [], markdown_odt_parser = nil)
          begin
            clazz = XmlNodes.const_get "#{titleize prefix}::#{titleize name}"
          rescue NameError => e
            Generic.new(parent, attrs, prefix, name, markdown_odt_parser)
          else
            clazz.new(parent, attrs, prefix, name, markdown_odt_parser)
          end
        end

        def self.titleize(tag)
          tag.split('-').map(&:capitalize).join
        end

        def initialize(parent = nil, attrs = [], prefix = nil, name = nil, markdown_odt_parser = nil)
          @parent, @attrs, @prefix, @name = parent, attrs, prefix, name
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

        def not_enclosing?
          !root? && parent.class.not_enclosing_tags && parent.class.not_enclosing_tags.find do |tag|
            @prefix == parent.prefix && @name == tag
          end
        end

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          attr_reader :not_enclosing_tags

          def not_enclosing(tag)
            @not_enclosing_tags ||= []
            @not_enclosing_tags << tag
          end
        end
      end
    end
  end
end
