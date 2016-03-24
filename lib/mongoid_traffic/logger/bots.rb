require 'nokogiri'

# sourced from https://github.com/charlotte-ruby/impressionist/blob/master/lib/impressionist/bots.rb

module MongoidTraffic
  class Logger
    class Bots
      DATA_URL = 'http://www.user-agents.org/allagents.xml'.freeze
      FILE_PATH = 'vendor/mongoid_traffic/allagents.xml'.freeze

      class << self
        def list
          @list ||= begin
            response = File.open(FILE_PATH).read
            doc = Nokogiri::XML(response)
            doc.xpath('//user-agent').inject([]) do |res, agent|
              type = agent.xpath('Type').text
              res << agent.xpath('String').text.gsub('&lt;', '<') if %w(R S).include?(type)
              res
            end
          end
        end

        def is_a_bot?(referer)
          return false unless referer.present?
          list.include?(referer)
        end
      end
    end
  end
end
