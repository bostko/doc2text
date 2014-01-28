module Doc2Text
  class UnpackOdt
    EXTRACT_PATH = 'unpacked_odt'

    def initialize(document_path)
      @document_path = document_path
    end

    def unpack
      Zip::File.open(@document_path) {
          |zip_file|
        Dir.mkdir(EXTRACT_PATH)
        zip_file.each do |entry|
          zipped_file_extract_path = File.join EXTRACT_PATH, entry.name
          FileUtils.mkdir_p File.dirname(zipped_file_extract_path)
          zip_file.extract entry, zipped_file_extract_path
        end
      }
    end

    def clean
      system("rm -rf #{EXTRACT_PATH}")
    end
  end
end
