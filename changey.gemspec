require File.expand_path('../lib/changey/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = "changey"
  s.description   = %q{An Active Record extension to provide state callbacks}
  s.summary       = s.description
  s.homepage      = "https://github.com/adamcooke/changey"
  s.version       = Changey::VERSION
  s.files         = Dir.glob("{lib}/**/*")
  s.require_paths = ["lib"]
  s.authors       = ["Adam Cooke"]
  s.email         = ["me@adamcooke.io"]
  s.licenses      = ['MIT']
  s.add_dependency "activerecord", ">= 4.2", "< 6"
end
