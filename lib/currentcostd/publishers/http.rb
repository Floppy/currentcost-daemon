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

require 'webrick'

module CurrentCostDaemon

  module Publishers

    class Http
    
      def self.config_section
        'http'
      end
    
      class Servlet < WEBrick::HTTPServlet::AbstractServlet
        def do_GET(request, response)
          if request.query['format'].nil? || request.query['format'] == "html"
            response.status = 200
            response['Content-Type'] = "text/html"
            response.body = "
<html>
  <body>
    <div style='float:right'>
      <a title='EEML' href='/?format=eeml'><span style='border:1px solid;border-color:#9C9 #030 #030 #696;padding:0 3px;font:bold 10px verdana,sans-serif;color:#FFF;background:#090;text-decoration:none;margin:0;'>EEML</span></a>
      <a title='XML' href='/?format=xml'><span style='border:1px solid;border-color:#FC9 #630 #330 #F96;padding:0 3px;font:bold 10px verdana,sans-serif;color:#FFF;background:#F60;text-decoration:none;margin:0;'>XML</span></a>
    </div>
    <h1>Current Total</h1>
    <p>#{@@total} Watts</p>
    <h1>History</h1>
    <h2>Hourly</h2>
    <img src='http://chart.apis.google.com/chart?cht=lc&chs=400x125&chd=t:#{@@history[:hours].reverse.delete_if{|x|x.nil?}.join(',')}&chds=0,#{@@history[:hours].delete_if{|x|x.nil?}.max}'/>
    <h2>Daily</h2>
    <img src='http://chart.apis.google.com/chart?cht=lc&chs=400x125&chd=t:#{@@history[:days].reverse.map{|x| x.nil? ? 0 : x}.join(',')}&chds=0,#{@@history[:days].delete_if{|x|x.nil?}.max}'/>
    <h2>Monthly</h2>
    <img src='http://chart.apis.google.com/chart?cht=lc&chs=400x125&chd=t:#{@@history[:months].reverse.map{|x| x.nil? ? 0 : x}.join(',')}&chds=0,#{@@history[:months].delete_if{|x|x.nil?}.max}'/>
    <h2>Yearly</h2>
    <img src='http://chart.apis.google.com/chart?cht=lc&chs=400x125&chd=t:#{@@history[:years].reverse.map{|x| x.nil? ? 0 : x}.join(',')}&chds=0,#{@@history[:years].delete_if{|x|x.nil?}.max}'/>
  </body>
</html>"
          elsif request.query['format'] == "eeml"
            # Create EEML document
            eeml = EEML::Environment.new
            # Create data object
            data = EEML::Data.new(0)
            data.unit = EEML::Unit.new("Watts", :symbol => 'W', :type => :derivedSI)
            eeml << data
            eeml[0].value = @@total
            eeml.updated_at = @@updated_at
            response.status = 200
            response['Content-Type'] = "text/xml"
            response.body = eeml.to_eeml
          elsif request.query['format'] == "xml"
            response.status = 200
            response['Content-Type'] = "text/xml"
            # Create XML
            xml = Builder::XmlMarkup.new
            xml.instruct!
            response.body = xml.currentcost { xml.watts @@total }
          else
            response.status = 400
          end
        end
        def self.update(reading)
          @@reading = reading
          @@updated_at = Time.now
          # Add all channels to get real total
          @@total = 0
          @@reading.channels.each { |c| @@total += c[:watts] }
          # Store history if available
          @@history = @@reading.history if @@reading.history
        end
      end

      def initialize(config)
        # Initialise storage
        @watts = 0
        # Create WEBrick server
        @server = WEBrick::HTTPServer.new(:Port => config['http']['port'] )
        # Create a simple webrick servlet for HTML output
        @server.mount("/", Servlet)
        trap("INT") {@server.shutdown}
        Thread.new{@server.start}
      end

      def update(reading)
        Servlet.update(reading)
      end
    
    end  

  end

end
