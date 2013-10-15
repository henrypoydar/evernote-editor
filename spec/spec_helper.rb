require 'rubygems'
require 'bundler/setup'
require 'fakefs/spec_helpers'

require 'evernote_editor'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers

  def write_fakefs_config
    File.open(File.expand_path("~/.evned"), 'w') do |f|
      f.write( { token: '123', editor: 'vim' }.to_json )
    end
  end
end

