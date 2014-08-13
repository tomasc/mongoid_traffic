require 'nokogiri'

# sourced from https://github.com/charlotte-ruby/impressionist/blob/master/lib/impressionist/bots.rb

module MongoidTraffic
  class Logger
    class Bots

      DATA_URL = "http://www.user-agents.org/allagents.xml"
      FILE_PATH = "vendor/mongoid_traffic/allagents.xml"
      
      class << self
        def list
          @list ||= begin
            response = File.open(FILE_PATH).read
            doc = Nokogiri::XML(response)
            list = []
            doc.xpath('//user-agent').each do |agent|
              type = agent.xpath("Type").text
              list << agent.xpath('String').text.gsub("&lt;","<") if %w(R S).include?(type)
            end
            list
          end
        end

        def is_a_bot? referer
          return false unless referer.present?
          list.include?(referer)
        end
      end

    end
  end
end