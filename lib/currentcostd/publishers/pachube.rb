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

require 'eeml'
require 'net/http'

module CurrentCostDaemon

  module Publishers

    class Pachube
      
      def self.config_section
        'pachube'
      end

      def initialize(config)
        @feed = config['pachube']['feed_id']
        @api_key = config['pachube']['api_key']
      end
      
      def update(reading)
        # Create EEML document
        eeml = EEML::Environment.new
        # Create data object
        data = EEML::Data.new(0)
        data.unit = EEML::Unit.new("Watts", :symbol => 'W', :type => :derivedSI)
        eeml << data
        eeml[0].value = reading.total_watts
        eeml.set_updated!
        # Put data
        puts "Storing in Pachube..."
        put = Net::HTTP::Put.new("/api/#{@feed}.xml")
        put.body = eeml.to_eeml
        put['X-PachubeApiKey'] = @api_key
        http = Net::HTTP.new('www.pachube.com')
        http.start
        response = http.request(put)
        raise response.code if response.code != "200"
        puts "done"
      rescue
        puts "Something went wrong (pachube)!"
        puts $!.inspect
      end
    
    end  

  end

end
