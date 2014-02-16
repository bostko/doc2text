module Doc2Text
  class Odt
    module XmlNodes

      # TODO make it automatically inherited in the classes inside Office, Style
      class Node
        attr_reader :parent, :children, :attrs

        def self.create_node(prefix, name, parent = nil, attrs = [], markdown_document = nil)
          begin
            clazz = XmlNodes.const_get "#{titleize prefix}::#{titleize name}"
          rescue NameError => e
            new(parent, attrs, prefix, name, markdown_document)
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
        def initialize(parent = nil, attrs = [], prefix = nil, name = nil, markdown_document = nil)
          super parent, attrs, prefix, name, markdown_document
          @markdown_document = markdown_document
          style_index = attrs.index { |attr| attr.prefix == 'text' && attr.localname == 'style-name' }
          @enclosing_style = []
          if style_index
            fetch_style attrs[style_index].value
          end
        end

        def fetch_common_style(style)
          if style
            style.children.select { |style_property| style_property.xml_name == 'style:text-properties' }.each { |text_property|
              text_property.attrs.each { |attr|
                if attr.prefix == 'style'
                  if attr.localname == 'font-style-complex' && attr.value == 'italic'
                    @enclosing_style << '_'
                  elsif attr.localname == 'font-weight-complex' && attr.value == 'bold'
                    @enclosing_style << '**'
                  end
                end
              }
            }
          end
        end

        def fetch_style(style_name)
          styles = @markdown_document.xpath '/office:document-content/office:automatic-styles/style:style'
          style = styles.find { |style| style.attrs.index { |attr| attr.prefix == 'style' && attr.localname == 'family' && attr.value == self.class.style_family } &&
              style.attrs.index { |attr| attr.prefix == 'style' && attr.localname == 'name' && attr.value == style_name } }
          fetch_common_style style
        end

        # http://docs.oasis-open.org/office/v1.2/os/OpenDocument-v1.2-os-part1.html#__RefHeading__1419256_253892949
        class P < Node
          include Text

          def self.style_family
            'paragraph'
          end

          def open
            "\n#{@enclosing_style.join}"
          end

          def close
            "#{@enclosing_style.reverse.join}\n"
          end
        end

        class LineBreak < Node
          def open
            '<br/>'
          end
        end

        # http://docs.oasis-open.org/office/v1.2/os/OpenDocument-v1.2-os-part1.html#__RefHeading__1419264_253892949
        class Span < Node
          include Text

          def self.style_family
            'text'
          end

          def open
            @enclosing_style.join
          end

          def close
            @enclosing_style.reverse.join
          end
        end
      end
    end
  end
end
