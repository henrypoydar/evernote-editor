# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'evernote_editor/version'

Gem::Specification.new do |gem|
  gem.name          = "evernote-editor"
  gem.version       = EvernoteEditor::VERSION
  gem.authors       = ["Henry Poydar"]
  gem.email         = ["henry@poydar.com"]
  gem.description   = %q{Command line creation and editing of Evernote notes}
  gem.summary       = %q{Simple command line creation and editing of Evernote notes in Markdown format with your favorite editor via a gem installed binary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
