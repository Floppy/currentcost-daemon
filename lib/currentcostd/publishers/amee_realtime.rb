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

require 'net/http'

module CurrentCostDaemon

  module Publishers

    class AMEERealtimePublisher
    
      def self.config_section
        'amee_realtime'
      end
    
      def initialize(config)
        @profile_uid = config['amee_realtime']['profile_uid']
        @last_minute = Time.now.min - 1
        # Store AMEE connection details
        @server = config['amee_realtime']['server']
        @username = config['amee_realtime']['username']
        @password = config['amee_realtime']['password']
	# Get electricity UID for later
	req = Net::HTTP::Get.new("/data/test/andrew/realtimeelec/drill?type=normal")
	req.basic_auth @username, @password
	req['Accept'] = "application/xml"
	http = Net::HTTP.new(@server)
	http.start do
		response = http.request(req)
		raise response.body if (response.code != "200" && response.code != "201")
		@uid = response.body.match("<Choices><Name>uid</Name><Choices><Choice><Name>.*?</Name><Value>(.*?)</Value></Choice></Choices></Choices>")[1]
	end
      end

      def update(reading)
        return if reading.total_watts == 0
        # Let's put data into AMEE every 5 minutes.
        if (Time.now.min != @last_minute) && (Time.now.min % 5 == 1)
          # Store time
          @last_minute = Time.now.min
          # Estimate kwh figure from current power usage
          kwh = (reading.total_watts / 1000.0)
          # Create POST options
          raise "No Data Item UID found!" if @uid.nil?
          options = {
            :dataItemUid => @uid,
		        :startDate => Time.now.xmlschema,
		        :endDate => (Time.now + 300).xmlschema,
		        :energyUsed => kwh,
		        :energyUsedUnit => "kWh",
		        :energyUsedPerUnit => "h",
		        :name => "currentcost"
          }
          puts "Storing in AMEE (realtime)..."
          # Post data to AMEE
          req = Net::HTTP::Post.new("/profiles/#{@profile_uid}/test/andrew/realtimeelec")
          req.basic_auth @username, @password
          req['Accept'] = "application/xml"
          req.set_form_data(options)
          http = Net::HTTP.new(@server)
          http.start do
            response = http.request(req)
            raise response.body if (response.code != "200" && response.code != "201")
          end
          puts "done"
        end
      rescue
        puts "Something went wrong (AMEE)!"
        puts $!.inspect
      end
    
    end  

  end

end
