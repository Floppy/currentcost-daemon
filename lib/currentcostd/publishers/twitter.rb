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

require 'cgi'

module CurrentCostDaemon

  module Publishers

    class Twitter
    
      def self.config_section
        'twitter'
      end
    
      def initialize(config)
        @username = config['twitter']['username']
        @password = config['twitter']['password']
        @last_minute = Time.now.min - 1
      end

      def update(reading)
        # Tweet once a minute
        if Time.now.min != @last_minute
          # Store time
          @last_minute = Time.now.min
          message = "At the moment, I'm using #{reading.total_watts} watts"
          # Tweet
          puts "Tweeting..."
          req = Net::HTTP::Post.new("/statuses/update.json")
          req.basic_auth @username, @password
          req.set_form_data "status" => message
          http = Net::HTTP.new("twitter.com")
          http.start do
            response = http.request(req)
            raise response.body if (response.code[0] != "2")
          end
          puts "done"
        end
      rescue
        puts "Something went wrong (twitter)!"
        puts $!.inspect
        nil
      end
    
    end  

  end

end
