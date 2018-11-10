module Doc2Text
  module Docx
    module XmlNodes
      class Node < XmlBasedDocument::XmlNodes::Node
        def self.create_node(prefix, name, parent = nil, attrs = [], markdown_odt_parser = nil)
          begin
            clazz = XmlNodes.const_get "#{prefix.capitalize}::W#{name}"
          rescue NameError => e
            # markdown_odt_parser.logger.warn "No such <#{prefix}:#{name}> found"
            Generic.new(parent, attrs, prefix, name, markdown_odt_parser)
          else
            clazz.new(parent, attrs, prefix, name, markdown_odt_parser)
          end
        end

        def body?
          false
        end
      end

      class PlainText < XmlBasedDocument::XmlNodes::PlainText
        def body?
          false
        end
      end

      class Generic < Node
      end

      module W
        class Wbody < Node
          def body?
            true
          end
        end

        class Wbr < Node
          def open
            '<br/>'
          end
        end

        class Wp < Node
          def open
            "\n"
          end

          def close
            "\n"
          end
        end
      end
    end
  end
end
