module Doc2Text
  class Odt
    module XmlNodes

      # TODO make it automatically inherited in the classes inside Office, Style
      class Node
        attr_reader :parent
        attr_accessor :children, :attrs

        def self.create_node(prefix, name, parent = nil, attrs = [])
          begin
            clazz = XmlNodes.const_get "#{titleize prefix}::#{titleize name}"
          rescue NameError => e
            new(parent, attrs, prefix, name)
          else
            clazz.new(parent, attrs, prefix, name)
          end
        end

        def self.titleize(tag)
          tag.split('-').map(&:capitalize).join
        end

        def initialize(parent = nil, attrs = [], prefix = nil, name = nil)
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

        def visit
          #puts "TAG: #{name} ATTRS: #{attrs}"
        end

        def to_s
          "#{xml_name} : #{attrs}"
        end
      end

      # These are the namespaces available in the open document format
      # http://docs.oasis-open.org/office/v1.2/os/OpenDocument-v1.2-os.html
      module Office
        class AutomaticStyles < Node
          def visit
            :automatic_styles
          end

          def delete_on_close?
            false
          end
        end

        class DocumentContent < Node
          def delete_on_close?
            false # required for testing purposes. After a document has been parsed, some tests could be run against the tree built
          end
        end
      end

      module Animation; end
      module Chart; end
      module Config; end
      module Database; end
      module Dr3d; end
      module Drawing; end
      module Form; end
      module Manifest; end
      module Meta; end
      module DataStyle; end
      module Presentation; end
      module Script; end
      module Table; end
      module Style
        class Style < Node
          def delete_on_close?
            false
          end
        end

        class TextProperties < Node
          def delete_on_close?
            false
          end
        end
      end
      module XslFoCompatible; end
      module SvgCompatible; end
      module SmilCompatible; end
      module Of; end

      module Text
        class P < Node
          def open
            "\n"
          end

          def close
            "\n"
          end
        end

        class LineBreak < Node
          def open
            '<br/>'
          end
        end

        class Span < Node

        end
      end
    end
  end
end
