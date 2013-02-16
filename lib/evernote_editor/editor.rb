require 'evernote_oauth'
require 'fileutils'

module EvernoteEditor
  
  class Editor

    CONFIGURATION_FILE = File.expand_path("~/.evn")

    def initialize
      read_configuration()
    end

  private

    def read_configuration
      FileUtils.touch(CONFIGURATION_FILE) unless File.exist?(CONFIGURATION_FILE)
      @configuration = YAML::load(File.open(CONFIGURATION_FILE))
    end


      #"S=s1:U=b73d:E=144369d53e9:C=13cdeec27e9:P=1cd:A=en-devtoken:H=cae2b3fa91691e351744620de8ec0418"
  end

end

