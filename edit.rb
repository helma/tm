#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

if ARGV.empty?
  `xterm -e vim #{Todo::TODO}`
elsif ARGV.first =~ /\d+/
  task = @list[ARGV.last.to_i-1]
  tmpfile = File.join(Todo::TODO_DIR,"tmp.txt")
  File.open(tmpfile, "w+"){|f| f.puts task.orig}
  `xterm -e vim #{tmpfile}`
  @list[ARGV.last.to_i-1] = Todo::Task.new File.new(tmpfile).read
  @list.save
else # edit project
  tasks =  @list.select{ |t| t.projects.include? ARGV.first.strip }
  @list -= tasks
  tmpfile = File.join(Todo::TODO_DIR,"tmp.txt")
  File.open(tmpfile, "w+"){|f| f.puts tasks.collect{|t| t.orig}}
  `xterm -e vim #{tmpfile}`
  File.read(tmpfile).each_line{ |line| @list.push Todo::Task.new(line.chomp) }
  @list.save
end
