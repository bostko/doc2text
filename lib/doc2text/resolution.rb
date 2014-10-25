module Doc2Text
  class Resolution
    def self.parse_and_save(source, output)
      case File.extname source
        when '.doc', '.docx'
          mid_name = File.join(File.dirname(output),
                               File.basename(source, File.extname(source)) + '.odt')
          system "soffice --headless --convert-to odt #{source}"
          source = mid_name
          Doc2Text::Odt::Document.parse_and_save source, output
          File.delete(mid_name)
        else
          Doc2Text::Odt::Document.parse_and_save source, output
      end
    end
  end
end
