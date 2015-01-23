module Doc2Text
  module XmlBasedDocument
    module Docx
      class Document < DocumentFile

        def self.parse_and_save(input, output_filename)
          odt = new input
          begin
            odt.unpack
            styles_xml_root = odt.parse_styles
            output = File.open output_filename, 'w'
            markdown = Markdown::DocxParser.new output, styles_xml_root
            begin
              odt.parse markdown
            ensure
              markdown.close
            end
          ensure
            odt.clean
          end
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
end
