require File.expand_path("../lib/haproxy_manager/version.rb", __FILE__)

Gem::Specification.new do |s|
  s.name = "haproxy_manager"
  s.version = HAProxyManager::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Sreekanth(sreeix)", "Smita Bhat(sbhat)"]
  s.email = ["gabbar@activesphere.com", "sbhat@altheasystems.com"]
  s.homepage = "https://github.com/althea/haproxy-manager"
  s.summary = 'HAproxy manager for controlling haproxy'
  s.description = 'Manages haproxy farms and servers'

  s.rubyforge_project = "haproxy_manager"
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'bundler'
end
