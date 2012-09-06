#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

def done n
  task = @list.delete_at n.to_i - 1
  File.open(Todo::DONE,"a+"){|f| f.puts "x #{Date.today} #{task.orig}"}
  @list.save
end

if ARGV.first =~ /\d+/
  ARGV = [] if ARGV.size == 1 and @list.current and @list.current.line == ARGV.first # no arguments for punch
  run "punch"
  done ARGV.first
elsif ARGV.empty? and @list.current
  run "punch"
  done @list.current.line
end
