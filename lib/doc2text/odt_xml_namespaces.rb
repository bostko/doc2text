module Doc2Text
  module Odt
    module XmlNodes
      class PlainText
        include Node

        attr_accessor :text

        alias_method :expand, :text

        def initialize(text)
          @text = text
        end
      end

      class Generic
        include Node
      end

      #
      # These are the namespaces available in the open document format
      # http://docs.oasis-open.org/office/v1.2/os/OpenDocument-v1.2-os.html
      #
      module Office
        class AutomaticStyles
          include Node

          def visit
            :automatic_styles
          end

          def delete_on_close?
            false
          end
        end

        class DocumentContent
          include Node

          def delete_on_close?
            true
          end
        end

        class Text
          include Node

          def delete_on_close?
            true
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
      module Table
        class TableRow
          include Node

          def expand
            "\n#{@children.map(&:expand).join.strip.gsub "\n", ''} |"
          end
        end

        class TableCell
          include Node

          def open
            ' | '
          end
        end
      end
      module Style
        class Style
          include Node

          def delete_on_close?
            false
          end
        end

        class TextProperties
          include Node

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
        def initialize(parent = nil, attrs = [], prefix = nil, name = nil, markdown_odt_parser = nil)
          super parent, attrs, prefix, name
          @markdown_odt_parser = markdown_odt_parser
          style_index = attrs.index { |attr| attr.prefix == 'text' && attr.localname == 'style-name' }
          @enclosing_style = []
          if style_index and fetch_style?
            elem_style = find_style attrs[style_index].value
            fetch_style elem_style
          end
        end

        def fetch_style?
          true
        end

        def fetch_style(elem_style)
          if elem_style
            elem_style.children.select { |style_property| style_property.xml_name == 'style:text-properties' }.each { |text_property|
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

        def find_style(style_name)
          styles = @markdown_odt_parser.xpath '/office:document-content/office:automatic-styles/style:style'
          style = styles.find { |style| style.attrs.index { |attr| attr.prefix == 'style' && attr.localname == 'family' && attr.value == self.class.style_family } &&
              style.attrs.index { |attr| attr.prefix == 'style' && attr.localname == 'name' && attr.value == style_name } }
        end

        # http://docs.oasis-open.org/office/v1.2/os/OpenDocument-v1.2-os-part1.html#__RefHeading__1419256_253892949
        class P
          include Node
          include Text

          def initialize(parent = nil, attrs = [], prefix = nil, name = nil, markdown_odt_parser = nil)
            super parent, attrs, prefix, name, markdown_odt_parser
          end

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

        class LineBreak
          include Node

          def open
            '<br/>'
          end
        end

        # http://docs.oasis-open.org/office/v1.2/os/OpenDocument-v1.2-os-part1.html#__RefHeading__1419264_253892949
        class Span
          include Node
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

        # http://docs.oasis-open.org/office/v1.2/os/OpenDocument-v1.2-os-part1.html#__RefHeading__1415154_253892949
        class ListItem
          include Node
          include Text

          def expand
            "* #{@children.map(&:expand).join.strip.gsub /\n{2,}/, "\n"}\n"
          end

          def fetch_style?
            false
          end

          def delete_on_close?
            false
          end
        end

        class List
          include Node
          include Text

          def fetch_style(elem_style)
            if elem_style
              elem_style.children.select { |style_property| style_property.xml_name == 'style:text-properties' }.each { |text_property|
                text_property.attrs.each { |attr|
                  if attr.prefix == 'style'
                    if attr.localname == 'list-level-style-number' && attr.value == 'Numbering_20_Symbols'
                      @enclosing_style << '_'
                    end
                  end
                }
              }
            end
          end

          def delete_on_close?
            true
          end
        end
      end
    end
  end
end
