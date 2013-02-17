require 'spec_helper'

describe EvernoteEditor::Editor do

  before do
    # Make sure the ~ path exists in our fakefs fake file system 
    FileUtils.mkpath(File.expand_path("~"))
  end

  context "#new" do

    it "creates a dotfile if one does not exist" do
      STDIN.stub!(:gets).and_return("entry\n")
      e = EvernoteEditor::Editor.new('create')
      File.exist?(File.expand_path("~/.evned")).should eq true
    end

    it "prompts for and stores a developer token" do
      STDIN.stub!(:gets).and_return("entry\n")
      e = EvernoteEditor::Editor.new('create')
      YAML::load(File.open(File.expand_path("~/.evned")))[:token].should eq "entry"
    end

    it "prompts for and stores an editor command" do
      STDIN.stub!(:gets).and_return("entry\n")
      e = EvernoteEditor::Editor.new('create')
      YAML::load(File.open(File.expand_path("~/.evned")))[:editor].should eq "entry"
    end

  end

  context "#create" do

    it "opens a new document in a text editor and saves it" do
      STDIN.stub!(:gets).and_return("entry\n")
      e = EvernoteEditor::Editor.new('create', 'title', 'tag1,tag2')
    end

  end

  context "#edit" do

    it "presents a list of notes that match the title input"

    it "edits a note in a text editor and saves it"

  end

end
