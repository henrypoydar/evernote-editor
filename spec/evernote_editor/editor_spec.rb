require 'spec_helper'

describe EvernoteEditor::Editor do

  before do
    # Make sure the necessary paths exist in our fakefs fake file system 
    FileUtils.mkpath(File.expand_path("~"))
    FileUtils.mkpath(File.expand_path("/tmp"))
    # Stub console entry
    EvernoteEditor::Editor.any_instance.stub(:open_editor)
    EvernoteEditor::Editor.any_instance.stub(:say)
    EvernoteEditor::Editor.any_instance.stub(:ask).with(/token/).and_return('0123456789')
    EvernoteEditor::Editor.any_instance.stub(:ask).with(/editor/).and_return('vim')
  end

  context "#new" do

    it "creates a dotfile if one does not exist" do
      e = EvernoteEditor::Editor.new({})
      File.exist?(File.expand_path("~/.evned")).should eq true
    end

    it "prompts for and stores a developer token" do
      e = EvernoteEditor::Editor.new({})
      YAML::load(File.open(File.expand_path("~/.evned")))[:token].should eq "0123456789"
    end

    it "prompts for and stores an editor command" do
      e = EvernoteEditor::Editor.new({})
      YAML::load(File.open(File.expand_path("~/.evned")))[:editor].should eq "vim"
    end

  end

  context "#create" do

    it "opens a new document in a text editor" do
      e = EvernoteEditor::Editor.new('title', 'tag1,tag2', {})
    end

  end

  context "#edit" do

    it "presents a list of notes that match the title input"

    it "edits a note in a text editor and saves it"

  end

end
