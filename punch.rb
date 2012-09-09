#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

if ARGV.empty?
  current.punchout if current
elsif ARGV.size == 1 and ARGV.first =~ /\d+/
  task = @list[ARGV.first.to_i]
  current.punchout if current
  task.punchin if task
elsif ARGV.size == 2 # add duration
  task = @list[ARGV.first.to_i]
  task[:offline] ||= []
  task[:offline] << ARGV.last.to_f
  File.open(TODO,"w+"){|f| f.puts @list.to_yaml}
end
