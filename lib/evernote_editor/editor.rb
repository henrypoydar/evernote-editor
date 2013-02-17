require 'evernote_oauth'
require 'fileutils'

module EvernoteEditor
  
  class Editor

    CONFIGURATION_FILE = File.expand_path("~/.evned")

    def initialize(directive, *args)
      configure
      @title = args[0] || "Untitled note - #{Time.now}"
      case directive
      when 'create'
        create_file 
        @tags = (args[1] || []).split(',')
      when 'edit'
        edit_file
      end
    end

  private

    def create_file

    end

    def edit_file

    end

    def configure
      FileUtils.touch(CONFIGURATION_FILE) unless File.exist?(CONFIGURATION_FILE)
      @configuration = YAML::load(File.open(CONFIGURATION_FILE)) || {}
      store_key unless @configuration[:token]
      store_editor unless @configuration[:editor]
    end

    def store_key
      puts "You will need a developer token to use this editor."
      puts "More information: http://dev.evernote.com/start/core/authentication.php#devtoken"
      puts "Please enter your developer token: "
      token = STDIN.gets.chomp()
      @configuration[:token] = token
      write_configuration
    end

    def store_editor
      puts "Please enter the editor command you would like to use:"
      editor_command = STDIN.gets.chomp()
      @configuration[:editor] = editor_command
      write_configuration
    end


    def write_configuration
      File.open(CONFIGURATION_FILE, "w") do |file|
        file.write @configuration.to_yaml
      end
    end

    #"S=s1:U=b73d:E=144369d53e9:C=13cdeec27e9:P=1cd:A=en-devtoken:H=cae2b3fa91691e351744620de8ec0418"
  end

end

