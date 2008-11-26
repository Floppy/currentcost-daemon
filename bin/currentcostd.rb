#!/usr/bin/env ruby

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

require 'rubygems'
require 'currentcost/meter'

# Load config
config  = nil
config_files = [
  "/etc/currentcostd.yml",
  File.join(File.dirname(__FILE__), '/../config/currentcostd.yml')
]
config_files.each do |c|
  if File.exists?(c)
    config = YAML.load_file(c)
    break
  end
end
if config.nil?
  puts "Couldn't load configuration from " + config_files.join(" or ")
  exit
end

# Create meter object
meter = CurrentCost::Meter.new config['currentcost']['port']

# Require all available publishers
Dir.glob(File.join(File.dirname(__FILE__), '/../lib/currentcostd/publishers/*.rb')).each { |f| require f }

# Register publishers with meter if their configuration sections are defined
CurrentCostDaemon::Publishers.constants.each do |publisher|
  pub_class = CurrentCostDaemon::Publishers.const_get(publisher)
  if config[pub_class.config_section] && config[pub_class.config_section]['enabled'] == true
    meter.add_observer(pub_class.new(config))
  end
end

# Now just let it run
while (true)
  sleep(30)
end
