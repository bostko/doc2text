require 'zip'
require 'tmpdir'

module Doc2Text
  module XmlBasedDocument
    class DocumentFile
      def initialize(document_path)
        @document_path = document_path
      end

      def unpack
        destination_root = Pathname.new(extract_path).realpath

        Zip::File.open(@document_path) {
            |zip_file|
          zip_file.each do |entry|
            entry_path = Pathname.new(entry.name)

            next if entry_path.absolute?
            destination_path = destination_root.join(entry.name).cleanpath

            unless destination_path.to_s.start_with?(destination_root.to_s + File::SEPARATOR)
              raise "Unsafe zip entry: #{entry.name}"
            end

            FileUtils.mkdir_p(destination_path.dirname)
            zip_file.extract entry, entry.name, destination_directory: extract_path
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
        @extract_path ||= Dir.mktmpdir(".#{File.basename(@document_path)}_#{extract_extension}")
      end
    end
  end
end
