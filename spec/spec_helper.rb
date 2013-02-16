require 'rubygems'
require 'bundler/setup'
require 'fakefs/spec_helpers'

require 'evernote_editor'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers
end
