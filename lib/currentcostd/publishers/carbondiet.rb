# Copyright (c) 2008 James Smith (www.floppy.org.uk)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# http://www.opensource.org/licenses/mit-license.php

module CurrentCostDaemon

  module Publishers

    class CarbonDiet
    
      def self.config_section
        'carbondiet'
      end
    
      def initialize(config)
        @account = config['carbondiet']['account_id']
        @username = config['carbondiet']['username']
        @password = config['carbondiet']['password']
      end

      def update(reading)
        # Carbon Diet is daily, so we only want to do something if there is
        # history data, and only once a day, ideally. If it's 3am, upload history 
        # if we have it.
        # This is horribly hacky, it post every time there is day history during
        # this hour. Also the carbondiet code at the other end is hacky.
        # All this needs improving.
        puts reading.to_yaml
        puts "stuff"
        if !reading.history.nil? && reading.hour == 3
          puts "Storing in Carbon Diet..."
          # Create http post request
          post = Net::HTTP::Post.new("/data_entry/electricity/#{@account}/currentcost")
          post.basic_auth(@username, @password)
          # Add XML document
          xml = Builder::XmlMarkup.new
          xml.instruct!
          post.body = xml.data do
            reading.history[:days].each_index do |i|
              unless reading.history[:days][i].nil?
                xml.entry do
                  xml.date Date.today - i
                  xml.value reading.history[:days][i][0]
                end
              end
            end
          end
          # Send data
          http = Net::HTTP.new('www.carbondiet.org')
          http.start
          http.request(post)
          puts "done"
        end
      rescue
        puts "Something went wrong (carbondiet)!"
        puts $!.inspect
        nil
      end
    
    end  

  end

end
