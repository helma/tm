#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

@done = Array.read DONE
undo = ARGV.collect { |i| @done[i.to_i] }
undo.each do |task|
  task.delete :finished
  @list << task
  @done.delete task
  print "Undo: "
  @list.print task
end
@list.save TODO
@done.save DONE
