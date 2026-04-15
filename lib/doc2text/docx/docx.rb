module Doc2Text
  module Docx
    class Document < XmlBasedDocument::DocumentFile

      def self.parse_and_save(input, output_filename)
        docx = new input
        begin
          docx.unpack
          styles_xml_root = docx.parse_styles
          output = File.open output_filename, 'w'
          markdown = Markdown::DocxParser.new output, styles_xml_root
          begin
            docx.parse markdown
          ensure
            markdown.close
          end
        ensure
          docx.clean
        end
      end

      def parse_styles
        styles_parser = Doc2Text::Odt::StylesParser.new
        xml = Nokogiri::XML::SAX::Parser.new(styles_parser)
        xml.parse open File.join('word', 'styles.xml')
        styles_parser.xml_root
      end

      def parse(markdown)
        parser = Nokogiri::XML::SAX::Parser.new(markdown)
        parser.parse open File.join('word', 'document.xml')
      end

      def contains_extracted_files?
        File.exist? File.join(extract_path, '[Content_Types].xml')
      end

      def extract_extension
        'unpacked_docx'
      end
    end
  end
end
