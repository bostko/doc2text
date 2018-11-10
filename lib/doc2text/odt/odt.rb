module Doc2Text
  module Odt
    class Document < XmlBasedDocument::DocumentFile

      def extract_extension
        'unpacked_odt'
      end

      def self.parse_and_save(input, output_filename)
        odt = new input
        begin
          odt.unpack
          styles_xml_root = odt.parse_styles
          output = File.open output_filename, 'w'
          markdown = Markdown::OdtParser.new output, styles_xml_root
          begin
            odt.parse markdown
          ensure
            markdown.close
          end
        ensure
          odt.clean
        end
      end

      def parse_styles
        styles_parser = Doc2Text::Odt::StylesParser.new
        xml = Nokogiri::XML::SAX::Parser.new(styles_parser)
        xml.parse open 'styles.xml'
        styles_parser.xml_root
      end

      def parse(markdown)
        parser = Nokogiri::XML::SAX::Parser.new(markdown) # { |config| config.strict}
        parser.parse open 'content.xml'
      end

      def contains_extracted_files?
        [File.join(extract_path, 'content.xml'), File.join(extract_path, 'mimetype')].all? { |file| File.exist?(file) }
      end
    end
  end
end
