# Evernote Editor

Simple gem that provides command line creation and editing of Evernote notes.
Uses your favorite editor and Markdown formatting.

## Installation

    gem install evernote-editor

## Usage

    evned [options] title tag1,tag2
      -s, --sandbox      Use the Evernote sandbox server
      -e, --edit         Search for and edit an existing note by title
      -h, --help         Display this screen <title> <tag>

## TODO

* Editing first by finding
* Tags on creation?
* Specs are pretty thin. Stubbing/expecting the thrift stuff is cumbersome.
* Better exception handling. With specs.
* Travis-ify
