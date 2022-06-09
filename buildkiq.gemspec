# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "buildkiq/version"

Gem::Specification.new do |spec|
  spec.name    = "buildkiq"
  spec.version = Buildkiq::VERSION
  spec.authors = ["Akira Kusumoto"]
  spec.email   = ["akirakusumo10@gmail.com"]

  spec.summary     = "AWS CodeBuild container launcher"
  spec.description = "AWS CodeBuild container launcher"
  spec.homepage    = "https://github.com/bluerabbit/buildkiq"
  spec.license     = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "aws-sdk", ">= 3.0.1"
  spec.add_runtime_dependency "rubyzip"
  spec.add_runtime_dependency "thor"

  spec.add_development_dependency "bundler", "~> 2.2.33"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
end
