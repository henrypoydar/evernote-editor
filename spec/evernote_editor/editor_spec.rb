require 'spec_helper'

describe EvernoteEditor::Editor do

  context "#new" do

    it "creates a dotfile if one does not exist" do
      # Make sure the ~ path exists in our fakefs fake file system 
      FileUtils.mkpath(File.expand_path("~"))
      e = EvernoteEditor::Editor.new
      File.exist?(File.expand_path("~/.evn")).should eq true
    end

    it "prompts for a developer key if it does not exist"

    it "stores a developer key"

  end

  context "#set_text_editor" do

    it "sets the text editor path"

  end

  context "#create" do

    it "opens a new document in a text editor and saves it"

  end

  context "#edit" do

    it "presents a list of notes that match the title input"

    it "edits a note in a text editor and saves it"

  end

end
