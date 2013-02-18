require 'spec_helper'

describe EvernoteEditor::Editor do

  before do
    # Make sure the necessary paths exist in our fakefs fake file system 
    FileUtils.mkpath(File.expand_path("~"))
    FileUtils.mkpath(File.expand_path("/tmp"))
  end

  describe "#configure" do

    let(:enved) { EvernoteEditor::Editor.new('a note', {}) }

    before :each do
      # Silence the spec output
      EvernoteEditor::Editor.any_instance.stub(:say)
    end

    context "when a configuration dot file does not exist" do

      it "prompts for a developer token" do
        enved.should_receive(:ask).with(/token/).and_return('123')
        enved.stub(:ask).with(/editor/).and_return('vim')
        enved.configure
      end

      it "prompts for a editor path" do
        enved.stub(:ask).with(/token/).and_return('123')
        enved.should_receive(:ask).with(/editor/).and_return('vim')
        enved.configure
      end

      it "stores the developer token" do
        enved.stub(:ask).with(/token/).and_return('123')
        enved.stub(:ask).with(/editor/).and_return('vim')
        enved.configure
        YAML::load(File.open(File.expand_path("~/.evned")))[:token].should eq "123"
      end

      it "stores the editor path" do
        enved.stub(:ask).with(/token/).and_return('123')
        enved.stub(:ask).with(/editor/).and_return('vim')
        enved.configure
        YAML::load(File.open(File.expand_path("~/.evned")))[:editor].should eq "vim"
      end

    end

    context "when a configuration dot file exists" do

      before :each do
        File.open(File.expand_path("~/.evned"), 'w') do |f|
          f.write( { token: '123', editor: 'vim' }.to_yaml )
        end
      end

      it "does not prompt for a developer token" do
        enved.should_not_receive(:ask).with(/token/)
        enved.configure
      end

      it "does not prompt for an editor path" do
        enved.should_not_receive(:ask).with(/editor/)
        enved.configure
      end

    end

    context "when a configuration dot file is incomplete/invalid" do

      before :each do
        File.open(File.expand_path("~/.evned"), 'w') do |f|
          f.write( { foo: '123', editor: 'vim' }.to_yaml )
        end
      end

      it "prompts for missing information" do
        enved.should_receive(:ask).with(/token/).and_return('123')
        enved.should_not_receive(:ask).with(/editor/)
        enved.configure
      end

      it "rewrites the configuration file" do
        enved.should_receive(:ask).with(/token/).and_return('123')
        enved.configure
        YAML::load(File.open(File.expand_path("~/.evned")))[:token].should eq "123"
      end

    end

  end

  describe "#create_note" do

    it "opens a new document in a text editor"

    it "saves the document to Evernote"

    context "when there is an Evernote Cloud API communication error" do

      it "prints your note to STDOUT so you don't lose it"

    end

  end

  describe "#edit_note" do

    it "presents a list of notes that match the title input"

    it "edits a note in a text editor"

    it "saves the document to Evernote"

    context "when there is an Evernote Cloud API communication error" do

      it "prints your note to STDOUT so you don't lose it"

    end

  end

  describe "#note_markup" do

    it "converts markdown to XHTML"

    it "inserts XHTML into the ENML"

  end

end
