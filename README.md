# Evernote Editor

Simple gem that provides command line creation and editing of Evernote notes.
Uses your favorite editor and Markdown formatting.

## Installation

    gem install evernote-editor

## Usage

You'll need a developer token (http://dev.evernote.com/start/core/authentication.php#devtoken)
to use this tool. The first time you run it you will be prompted for it.
You will also be prompted for the path to your editor.
You can modify both values later by editing `~/.enved`

    evned [options] title tag1,tag2
      -s, --sandbox      Use the Evernote sandbox server
      -e, --edit         Search for and edit an existing note by title
      -h, --help         Display this screen

## TODO

* Store tags on creation
