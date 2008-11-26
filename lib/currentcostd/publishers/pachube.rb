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
        @http = Net::HTTP.new('www.pachube.com')
        @http.start
      end
      
      def update(reading)
        # Add all channels to get real figure
        watts = 0 
        reading.channels.each { |c| watts += c[:watts] }
        # Create EEML document
        eeml = EEML::Environment.new
        # Create data object
        data = EEML::Data.new(0)
        data.unit = EEML::Unit.new("Watts", :symbol => 'W', :type => :derivedSI)
        eeml << data
        eeml[0].value = watts
        eeml.set_updated!
        # Post
        post = Net::HTTP::Put.new("/feeds/#{@feed}.xml")
        post.body = eeml.to_eeml
        post['X-PachubeApiKey'] = @api_key
        @http.request(post)
      end
    
    end  

  end

end
