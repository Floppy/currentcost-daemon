require 'rake'
require 'rubygems/specification'
require 'rake/gempackagetask'

task :default => [:gem]

# Gem build task - load gemspec from file
gemspec = File.read('currentcost-daemon.gemspec')
spec = nil
# Eval gemspec in SAFE=3 mode to emulate github build environment
Thread.new { spec = eval("$SAFE = 3\n#{gemspec}") }.join
Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
end