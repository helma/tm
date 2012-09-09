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
  File.open(TODO,"w+"){|f| f.puts @list.to_yaml}
=begin
else # edit project
  tasks =  @list.select{ |t| t.projects.include? ARGV.first.strip }
  @list -= tasks
  tmpfile = File.join(Todo::TODO_DIR,"tmp.txt")
  File.open(tmpfile, "w+"){|f| f.puts tasks.collect{|t| t.orig}}
  `xterm -e vim #{tmpfile}`
  File.read(tmpfile).each_line{ |line| @list.push Todo::Task.new(line.chomp) }
  @list.save
=end
end
