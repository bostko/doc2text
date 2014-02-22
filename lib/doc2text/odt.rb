require 'zip'

module Doc2Text
  module Odt
    class Document
      EXTRACT_EXTENSION = 'unpacked_odt'

      def self.parse_and_save(input, output)
        odt = new input
        begin
          odt.unpack
          markdown = Markdown::Document.new output
          begin
            odt.parse markdown
          ensure
            markdown.close
          end
        ensure
          odt.clean
        end
      end

      def parse(markdown)
        content = ::Doc2Text::Odt::Content::Document.new markdown
        parser = Nokogiri::XML::SAX::Parser.new(content) # { |config| config.strict}
        parser.parse open 'content.xml'
      end

      def initialize(document_path)
        @document_path = document_path
      end

      def unpack
        Zip::File.open(@document_path) {
            |zip_file|
          Dir.mkdir(extract_path)
          zip_file.each do |entry|
            zipped_file_extract_path = File.join extract_path, entry.name
            FileUtils.mkdir_p File.dirname(zipped_file_extract_path)
            zip_file.extract entry, zipped_file_extract_path
          end
        }
      end

      def clean
        if [extract_path, File.join(extract_path, 'content.xml'), File.join(extract_path, 'mimetype')].all? { |file| File.exist?(file) }
          FileUtils.rm_r extract_path
        end
      end

      # Open file from the current odt
      def open(filename)
        File.open File.join(extract_path, filename), 'r'
      end

      # Parse xml file from the current odt
      def xml_file(filename, rood_node_name)
        Nokogiri::XML::Document.parse(open(filename)) { |config| config.strict }
        root_node = doc.root
        if root_node.name != rood_node_name or root_node.namespace.prefix != 'office'
          raise XmlError, 'Document does not have correct root element'
        else
          open(filename)
        end
      end

      def extract_path
        File.join File.dirname(@document_path), ".#{File.basename(@document_path)}_#{EXTRACT_EXTENSION}"
      end
    end
  end
end
