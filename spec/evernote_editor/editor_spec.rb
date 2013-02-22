require 'spec_helper'

describe EvernoteEditor::Editor do

  before do
    # Make sure the necessary paths exist in our fakefs fake file system 
    FileUtils.mkpath(File.expand_path("~"))
    FileUtils.mkpath(File.expand_path("/tmp"))
    @mock_note_store = double("note_store",
      createNote: double("note", guid: "123"),
      findNotes:  double("notes", notes: [
        double("note", title: 'alpha', guid: "456"),
        double("note", title: 'bravo', guid: "789")]))
  end

  describe "#configure" do

    let(:enved) { EvernoteEditor::Editor.new('a note', {}) }

    before do
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

      before { write_fakefs_config }

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

      before do
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

    let(:enved) { EvernoteEditor::Editor.new('a note', {}) }

    before do
      write_fakefs_config
      EvernoteEditor::Editor.any_instance.stub(:say)
    end

    it "opens a new document in a text editor" do
      enved.should_receive(:open_editor).once
      EvernoteOAuth::Client.stub(:new).and_return(
        double("EvernoteOAuth::Client", note_store: @mock_note_store))
      enved.configure
      enved.create_note
    end

    it "saves the document to Evernote" do
      enved.stub!(:open_editor)
      EvernoteOAuth::Client.should_receive(:new).and_return(
        double("EvernoteOAuth::Client", note_store: @mock_note_store))
      enved.configure
      enved.create_note
    end

    context "when there is an Evernote Cloud API communication error" do

      it "prints your note to STDOUT so you don't lose it" do
        enved.stub!(:open_editor)
        EvernoteOAuth::Client.stub(:new).and_raise(Evernote::EDAM::Error::EDAMSystemException)
        enved.should_receive(:graceful_failure).once
        enved.configure
        enved.create_note
      end

    end

  end

  describe "#search_notes" do
    
    before { write_fakefs_config }
    let(:enved) { EvernoteEditor::Editor.new('a note', {}) }

    it "returns an array of hashes of notes" do
      enved.configure
      EvernoteOAuth::Client.stub(:new).and_return(
        double("EvernoteOAuth::Client", note_store: @mock_note_store))
      enved.search_notes.first.title.should eq 'alpha'
    end

    context "when there is an Evernote Cloud API communication error" do

      it "displays an error message" do
        enved.configure
        EvernoteOAuth::Client.stub(:new).and_raise(Evernote::EDAM::Error::EDAMSystemException)
        enved.should_receive(:say).with(/sorry/i).once
        enved.search_notes
      end
      
      it "returns false" do
        enved.configure
        EvernoteOAuth::Client.stub(:new).and_raise(Evernote::EDAM::Error::EDAMSystemException)
        enved.stub(:say)
        enved.search_notes.should eq false
      end

    end

  end

  describe "#edit_note" do
    
    before { write_fakefs_config }
    let(:enved) { EvernoteEditor::Editor.new('a note', {}) }

    it "presents a list of notes that match the title input" do

    end
    
    context "when there was an error searching notes" do

      it "does nothing" do
        enved.stub(:search_notes).and_return(false)
        enved.should_not_receive(:choose)
        enved.configure
        enved.edit_note
      end

    end

    context "when no search results are found" do

      it "does not present a list of notes" do
        enved.stub(:search_notes).and_return([])
        enved.should_receive(:say).with(/^No\ notes\ were\ found/)
        enved.should_not_receive(:choose)
        enved.configure
        enved.edit_note
      end

    end

    it "edits a note in a text editor"

    it "saves the document to Evernote"

    context "when there is an Evernote Cloud API communication error" do

      it "prints your note to STDOUT so you don't lose it"

    end

  end

  describe "#note_markup" do

    let(:enved) { EvernoteEditor::Editor.new('a note', {}) }

    it "converts markdown to XHTML" do
      enved.note_markup("This is *bongos*, indeed.").should =~
        /<p>This is <em>bongos<\/em>, indeed.<\/p>/
    end

    it "inserts XHTML into the ENML" do
      enved.note_markup("This is *bongos*, indeed.").should =~
        /<en-note>\s*<p>This is <em>bongos<\/em>, indeed.<\/p>\s*<\/en-note>/
    end

  end

end
