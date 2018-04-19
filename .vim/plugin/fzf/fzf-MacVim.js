#!/usr/bin/env osascript -l JavaScript
// osacompile -l JavaScript -o fzf-MacVim.scpt fzf-MacVim.js

ObjC.import('stdlib')
function run(argv) {
  'use strict';
  const iTerm = Application('iTerm');
  const SystemEvents = Application('System Events');
  const frontmost = Application.currentApplication(); // MacVim

  iTerm.includeStandardAdditions = true;
  const verbose = true;

  var args = $.NSProcessInfo.processInfo.arguments                            
  var argv = []
  var argc = args.count
  for (var i = 4; i < argc; i++) {
    // skip 3-word run command at top and this file's name
    // console.log($(args.objectAtIndex(i)).js)                             
    argv.push(ObjC.unwrap(args.objectAtIndex(i)))                           
  }
  if (verbose) { console.log(argv); } // print arguments

  iTerm.activate();
  let win = iTerm.createWindowWithProfile('fzf');
  delay(0.2);
  let fzf_session = win.currentSession();
  SystemEvents.keystroke('l', {using: 'control down'}); // Clear screen from artefacts
  delay(0.2);
  let cmd1 = "cd " + argv[1]; // cd $PWD
  iTerm.write(fzf_session,{text: cmd1});
  delay(0.2);
  let cmd2 = argv[0] + "; exit"; // fzf command && exit
  iTerm.write(fzf_session,{text: cmd2});
  delay(0.2);
  while (fzf_session.isProcessing()) { // wait until fzf finished
    delay(0.2);
  }
  frontmost.activate(); // bring back MacVim
  // $.exit(0);
}
