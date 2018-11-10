module Doc2Text
  module Odt
    module XmlNodes
      class Node < XmlBasedDocument::XmlNodes::Node
        def self.create_node(prefix, name, parent = nil, attrs = [], markdown_odt_parser = nil)
          begin
            clazz = XmlNodes.const_get "#{titleize prefix}::#{titleize name}"
          rescue NameError => e
            # markdown_odt_parser.logger.warn "No such <#{prefix}:#{name}> found"
            Generic.new(parent, attrs, prefix, name, markdown_odt_parser)
          else
            clazz.new(parent, attrs, prefix, name, markdown_odt_parser)
          end
        end

        def office_text?
          false
        end
      end

      class PlainText < XmlBasedDocument::XmlNodes::PlainText
      end

      class Generic < Node
      end
      #
      # These are the namespaces available in the open document format
      # http://docs.oasis-open.org/office/v1.2/os/OpenDocument-v1.2-os.html
      #
      module Office
        class AutomaticStyles < Node
        end

        class DocumentContent < Node
        end

        class Text < Node

          def office_text?
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
        class TableRow < Node

          def expand
            header_delimiter = parent.children.count >= 2 && parent.children[1] == self ? "\n|---|---|" : ''
            result = "\n#{@children.map(&:expand).join.strip.gsub "\n", ''} |#{header_delimiter}"
            delete
            result
          end
        end

        class TableCell < Node

          def open
            ' | '
          end
        end
      end
      module Style
        class Style < Node
        end

        class TextProperties < Node
        end
      end
      module XslFoCompatible; end
      module SvgCompatible; end
      module SmilCompatible; end
      module Of; end

      module Text
          def initialize(parent = nil, attrs = [], prefix = nil, name = nil, markdown_odt_parser = nil)
            super parent, attrs, prefix, name
            @xml_parser = markdown_odt_parser
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
            styles = @xml_parser.xpath '/office:document-content/office:automatic-styles/style:style'
            styles.find { |style| style.attrs.index { |attr| attr.prefix == 'style' && attr.localname == 'family' } &&
                style.attrs.index { |attr| attr.prefix == 'style' && attr.localname == 'name' && attr.value == style_name } }
          end

        # http://docs.oasis-open.org/office/v1.2/os/OpenDocument-v1.2-os-part1.html#__RefHeading__1419212_253892949
        class H < Node
          include Text
          def initialize(parent = nil, attrs = [], prefix = nil, name = nil, markdown_odt_parser = nil)
            super parent, attrs, prefix, name, markdown_odt_parser
            outline_level_index = attrs.index { |attr| attr.prefix == 'text' && attr.localname == 'outline-level' }
            if outline_level_index and fetch_style?
              @elem_outline_level = attrs[outline_level_index].value.to_i
            else
              @elem_outline_level = 0
            end

          end

          def self.style_family
            'paragraph'
          end

          def open
            "\n#{'#' * @elem_outline_level} "
          end

          def close
            "\n\n"
          end
        end

        # http://docs.oasis-open.org/office/v1.2/os/OpenDocument-v1.2-os-part1.html#__RefHeading__1419256_253892949
        class P < Node
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

          def expand
            expanded = "#{open}#{@children.map(&:expand).join}#{close}"
            delete
            expanded.clone
          end
        end

        # http://docs.oasis-open.org/office/v1.2/os/OpenDocument-v1.2-os-part1.html#__RefHeading__1415154_253892949
        class ListItem < Node
          include Text
          def expand
            result = "* #{@children.map(&:expand).join.strip.gsub /\n{2,}/, "\n"}\n"
            delete
            result.clone
          end

          def fetch_style?
            false
          end
        end

        class List < Node
          include Text

          def open
            "\n"
          end

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
        end
      end
    end
  end
end
