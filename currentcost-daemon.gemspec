Gem::Specification.new do |s|
  s.name = "currentcostd"
  s.version = "1.1"
  s.date = "2008-11-26"
  s.summary = "A system daemon for monitoring and publishing currentcost data"
  s.email = "james@floppy.org.uk"
  s.homepage = "http://github.com/Floppy/currentcost-daemon"
  s.has_rdoc = false
  s.authors = ["James Smith"]
  s.files = ["README", "COPYING"]
  s.files += ["lib/currentcostd/publishers/debug.rb", "lib/currentcostd/publishers/pachube.rb", "lib/currentcostd/publishers/http.rb"]
  s.files += ["config/currentcostd.example.yml"]
  s.files += ["bin/currentcostd"]
  s.executables = ['currentcostd']
  s.add_dependency('Floppy-currentcost', [">= 0.2.3"])
  s.add_dependency('Floppy-eeml', [">= 0.1.0"])
  s.add_dependency('daemons', [">= 1.0.10"])
  s.add_dependency('builder', [">= 2.1.2"])
end
