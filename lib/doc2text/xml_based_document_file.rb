require 'zip'

module Doc2Text
  module XmlBasedDocument
    class DocumentFile
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

      def contains_extracted_files?
        false
      end

      def clean
        if File.exist?(extract_path) and contains_extracted_files?
          FileUtils.rm_r extract_path
        else
          puts 'Failed to clean temp files'
        end
      end

      # Open file from the current odt
      def open(filename)
        File.open File.join(extract_path, filename), 'r'
      end

      def extract_extension
        'unpacked'
      end

      def extract_path
        File.join File.dirname(@document_path), ".#{File.basename(@document_path)}_#{extract_extension}"
      end
    end
  end
end
