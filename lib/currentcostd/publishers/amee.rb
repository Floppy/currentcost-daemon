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

    class AMEEPublisher
    
      def self.config_section
        'amee'
      end
    
      def initialize(config)
        @profile_uid = config['amee']['profile_uid']
        @last_minute = Time.now.min - 1
        # Open AMEE connection
        @server = config['amee']['server']
        @username = config['amee']['username']
        @password = config['amee']['password']
      end

      def update(reading)
        # Let's put data into AMEE every minute.
        if Time.now.min != @last_minute
          # Store time
          @last_minute = Time.now.min
          # Estimate kwh figure from current power usage
          kwh = (reading.total_watts / 1000.0)
          # Create POST options
          options = {
            :dataItemUid => "CDC2A0BA8DF3",
			      :startDate => Time.now.xmlschema,
			      :endDate => (Time.now + 60).xmlschema,
			      :energyConsumption => kwh,
			      :energyConsumptionUnit => "kWh",
			      :energyConsumptionPerUnit => "h",
			      :name => "currentcost"
          }
          puts "Storing in AMEE..."
          # Post data to AMEE
          req = Net::HTTP::Post.new("/profiles/#{@profile_uid}/home/energy/quantity")
          req.basic_auth @username, @password
          req['Accept'] = "application/xml"
          req.set_form_data(options)
          http = Net::HTTP.new(@server)
          http.start do
            response = http.request(req)
            raise response.body if response.code != "200"
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
