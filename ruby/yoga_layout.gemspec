# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "yoga_layout/version"

# Safe git_ls_files
def git_ls_files(path)
  operation = "git -C #{path} ls-files -z"
  files = `#{operation}`.split("\x0")
  raise "Failed optation #{operation.inspect}" unless $?.success?
  files
end

Gem::Specification.new do |spec|
  spec.name          = "yoga_layout"
  spec.version       = YogaLayout::VERSION
  spec.authors       = ["Jake Teton-Landis"]
  spec.email         = ["jake.tl@airbnb.com"]

  spec.summary       = %q{FFI-based wrapper of the cross-platform Yoga layout library}
  spec.homepage      = "https://github.com/justjake/yoga"

  spec.files         = [
    # All the files tracked in git, except for tests.
    *git_ls_files('.').reject { |f| f.match(%r{^(test|spec|features)/}) },

    # These files are copied by Rake inot ext/yoga_layout during build, but are
    # not tracked in Git.
    *Dir['ext/yoga_layout/*.{c,h}'],
  ]

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/yoga_layout/extconf.rb"]

  spec.add_dependency 'ffi'

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rake-compiler"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'drawille' # for a demo
end
