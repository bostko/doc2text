module Doc2Text
  class OdtXML < Nokogiri::XML::SAX::Document
    def start_element name, attrs = []
      # 3.4 <office:text> # link_to html url
      if name == 'office:text'
        #puts "TEXT #{name} started!"
      else
        #puts "#{name} started!"
      end
    end

    def end_element name
      #puts "#{name} ended"
    end
  end
end
