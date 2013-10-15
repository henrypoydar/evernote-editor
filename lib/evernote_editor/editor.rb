require 'evernote_oauth'
require 'fileutils'
require 'tempfile'
require "highline/import"
require "json"
require "redcarpet"
require "reverse_markdown"

module EvernoteEditor

  class Editor

    CONFIGURATION_FILE = File.expand_path("~/.evned")
    attr_accessor :configuration

    def initialize(*args, opts)
      @title   = args.flatten[0] || ""
      @tags    = (args.flatten[1] || '').split(',')
      @options = opts
      @sandbox = opts[:sandbox]
      @mkdout  = Redcarpet::Markdown.new(Redcarpet::Render::XHTML,
        autolink: true, space_after_headers: true, no_intra_emphasis: true)
    end

    def run
      configure
      @options[:edit] ? edit_note : create_note
    end

    def configure
      FileUtils.touch(CONFIGURATION_FILE) unless File.exist?(CONFIGURATION_FILE)
      #@configuration = YAML::load(File.open(CONFIGURATION_FILE)) || {}
      @configuration = JSON::load(File.open(CONFIGURATION_FILE)) || {}
      #@configuration = JSON.parse( IO.read(CONFIGURATION_FILE) || {} )
      store_key unless @configuration['token']
      store_editor unless @configuration['editor']
    end

    def create_note
      markdown = invoke_editor
      begin
        evn_client = EvernoteOAuth::Client.new(token: @configuration['token'], sandbox: @sandbox)
        note_store = evn_client.note_store
        note = Evernote::EDAM::Type::Note.new
        note.title = @title.empty? ? "Untitled note" : @title
        note.tagNames = @tags unless @tags.empty?
        note.content = note_markup(markdown)
        created_note = note_store.createNote(@configuration['token'], note)
        say "Successfully created new note '#{created_note.title}'"
      rescue Evernote::EDAM::Error::EDAMSystemException,
             Evernote::EDAM::Error::EDAMUserException,
             Evernote::EDAM::Error::EDAMNotFoundException => e
        say "Sorry, an error occurred saving the note to Evernote (#{e.message})"
        graceful_failure(markdown)
      end
    end

    def graceful_failure(markdown)
      say "Here's the markdown you were trying to save:"
      say ""
      say "--BEGIN--"
      say markdown
      say "--END--"
      say ""
    end

    def edit_note

      found_notes = search_notes(@title)
      return unless found_notes
      if found_notes.empty?
        say "No notes were found matching '#{@title}'"
        return
      end

      choice = choose do |menu|
        menu.prompt = "Which note would you like to edit:"
        found_notes.each do |n|
          menu.choice("#{Time.at(n.updated/1000).strftime('%Y-%m-%d %H:%M')} #{n.title}") do
            n.guid
          end
        end
        menu.choice("None") { nil }
      end
      return if choice.nil?

      begin
        evn_client = EvernoteOAuth::Client.new(token: @configuration['token'], sandbox: @sandbox)
        note_store = evn_client.note_store
        note = note_store.getNote(@configuration['token'], choice, true, true, false, false)
      rescue Evernote::EDAM::Error::EDAMSystemException,
             Evernote::EDAM::Error::EDAMUserException,
             Evernote::EDAM::Error::EDAMNotFoundException => e
        say "Sorry, an error occurred communicating with Evernote (#{e.message})"
        return
      end

      markdown = invoke_editor(note_markdown(note.content))
      note.content = note_markup(markdown)
      note.updated = Time.now.to_i * 1000

      begin
        note_store.updateNote(@configuration['token'], note)
        say "Successfully updated note '#{note.title}'"
      rescue Evernote::EDAM::Error::EDAMSystemException,
             Evernote::EDAM::Error::EDAMUserException,
             Evernote::EDAM::Error::EDAMNotFoundException => e
        say "Sorry, an error occurred saving the note to Evernote (#{e.message})"
        graceful_failure(markdown)
      end

    end

    def search_notes(term = '')
      begin
        evn_client = EvernoteOAuth::Client.new(token: @configuration['token'], sandbox: @sandbox)
        note_store = evn_client.note_store
        note_filter = Evernote::EDAM::NoteStore::NoteFilter.new
        note_filter.words = term
        results = note_store.findNotes(@configuration['token'], note_filter, 0, 10).notes
      rescue Evernote::EDAM::Error::EDAMSystemException,
             Evernote::EDAM::Error::EDAMUserException,
             Evernote::EDAM::Error::EDAMNotFoundException => e
        say "Sorry, an error occurred communicating with Evernote (#{e.inspect})"
        false
      end

    end

    def note_markup(markdown)
      "<?xml version='1.0' encoding='UTF-8'?><!DOCTYPE en-note SYSTEM 'http://xml.evernote.com/pub/enml2.dtd'><en-note>#{@mkdout.render(markdown)}</en-note>"
    end

    def note_markdown(markup)
      ReverseMarkdown.parse markup
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
      cmd = [@configuration['editor'], blocking_flag, file_path].join(' ')
      system(cmd) or raise SystemCallError, "`#{cmd}` gave exit status: #{$?.exitstatus}"
    end

    # Patterned from Pry
    def blocking_flag
      case File.basename(@configuration['editor'])
      when /^[gm]vim/
        '--nofork'
      when /^jedit/
        '-wait'
      when /^mate/, /^subl/
        '-w'
      end
    end


    def store_key
      say "You will need a developer token to use this editor."
      say "More information: http://dev.evernote.com/start/core/authentication.php#devtoken"
      token = ask("Please enter your developer token: ") { |q| q.default = "none" }
      @configuration['token'] = token
      write_configuration
    end

    def store_editor
      editor_command = ask("Please enter the editor command you would like to use: ") { |q| q.default = `which vim`.strip.chomp }
      @configuration['editor'] = editor_command
      write_configuration
    end

    def write_configuration
      File.open(CONFIGURATION_FILE, "w") do |file|
        file.write @configuration.to_json
      end
    end

  end

end
