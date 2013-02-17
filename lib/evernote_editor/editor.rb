require 'evernote_oauth'
require 'fileutils'
require 'tempfile'
require "highline/import"

module EvernoteEditor
  
  class Editor

    CONFIGURATION_FILE = File.expand_path("~/.evned")

    def initialize(*args, opts)
      configure
      @title   = args[0] || "Untitled note - #{Time.now}"
      @tags    = (args[1] || '').split(',')
      @sandbox = opts[:sandbox]
      #opts[:edit] ? edit_file : create_file
    end

  private
    
    def create_file
      markdown = invoke_editor
      evn_client = EvernoteOAuth::Client.new(token: @token, sandbox: @sandbox)
      note = Evernote::EDAM::Type::Note.new
      note.content = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note>
<p>Lorem ipsum</p>
</en-note>
EOF
      created_note = evn_client.note_store.createNote(@token, note)

      puts "Successfully created a new note with GUID: #{created_note.guid}"
      puts markdown
    end

    def edit_file

    end

    def invoke_editor(initial_content = "")
      file = Tempfile.new(['evned', '.markdown'])
      file.puts(initial_content)
      file.flush
      file.close(false)
      open_editor(file.path)
      content = File.read(file.path)
      file.unlink
      content
    end

    def open_editor(file_path)
      cmd = [@configuration[:editor], blocking_flag, file_path].join(' ')
      Kernel.system(cmd) or raise SystemCallError, "`#{cmd}` gave exit status: #{$?.exitstatus}"
    end

    # Patterned from Pry
    def blocking_flag
      case File.basename(@configuration[:editor])
      when /^[gm]vim/
        '--nofork'
      when /^jedit/
        '-wait'
      when /^mate/, /^subl/
        '-w'
      end
    end

    def configure
      FileUtils.touch(CONFIGURATION_FILE) unless File.exist?(CONFIGURATION_FILE)
      @configuration = YAML::load(File.open(CONFIGURATION_FILE)) || {}
      store_key unless @configuration[:token]
      store_editor unless @configuration[:editor]
    end

    def store_key
      say "You will need a developer token to use this editor."
      say "More information: http://dev.evernote.com/start/core/authentication.php#devtoken"
      token = ask("Please enter your developer token: ") { |q| q.default = "none" }
      @configuration[:token] = token
      write_configuration
    end

    def store_editor
      editor_command = ask("Please enter the editor command you would like to use: ") { |q| q.default = `which vim`.strip.chomp }
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

