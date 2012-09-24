#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

if ARGV.empty?
  `xterm -e vim #{TODO}`
elsif ARGV.first =~ /\d+/
  task = @list[ARGV.last.to_i]
  tmpfile = File.join(TODO_DIR,"tmp.txt")
  File.open(tmpfile, "w+"){|f| f.puts task.to_yaml}
  `xterm -e vim #{tmpfile}`
  @list[ARGV.last.to_i] = YAML.load_file tmpfile
  save
end
