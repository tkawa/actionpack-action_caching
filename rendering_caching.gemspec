Gem::Specification.new do |gem|
  gem.name          = "rendering_caching"
  gem.version       = "0.1.0"
  gem.authors       = ["David Heinemeier Hansson", "Toru KAWAMURA"]
  gem.email         = ["david@loudthinking.com", "tkawa@4bit.net"]
  gem.description   = "Rendering caching like traditional action caching"
  gem.summary       = "Rendering caching like traditional action caching"
  gem.homepage      = "https://github.com/tkawa/rendering_caching"

  gem.required_ruby_version = ">= 1.9.3"
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.license       = "MIT"

  gem.add_dependency "actionpack", ">= 4.0.0"

  gem.add_development_dependency "mocha"
  gem.add_development_dependency "activerecord", ">= 4.0.0"
end
