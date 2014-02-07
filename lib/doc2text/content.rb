module Doc2Text
  class Odt
    module Content
      class Document < Nokogiri::XML::SAX::Document
        def initialize(markdown_document)
          @markdown_document = markdown_document
        end

        def start_element_namespace(name ,attrs = [], prefix = nil, uri = nil, ns = [])
          puts "BEGIN NAMESPACE NAME: #{name},  PREFIX: #{prefix}, URI: #{uri}, NS: #{ns}"
          if ['text',].include?(prefix)
            clazz = Content.const_get prefix.capitalize
            @markdown_document << clazz.instance.send(name)
          end
        end

        def end_element_namespace(name, prefix = nil, uri = nil)
          if ['text',].include?(prefix)
            clazz = Content.const_get prefix.capitalize
            @markdown_document << clazz.instance.send(name)
          end
        end

        def characters(string)
          unless string.strip.empty?
            @markdown_document << string
          end
        end
      end

      class Text
        include ::Singleton

        def p
          "\n"
        end

        def method_missing(name, *args, &block)
          puts "!No such tag #{name}"
        end
      end
    end
  end

  module Markdown
    class Document
      def initialize(output)
        @output = File.open output, 'w'
      end

      def <<(string)
        @output << string
      end

      def close
        @output.close
      end
    end
  end
end
