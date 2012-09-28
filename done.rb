#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

if ARGV.empty? 
  finished = [@list.current]
else
  finished = ARGV.collect { |i| @list[i.to_i] }
end
@done = Array.read DONE
@list.current.punchout if @list.current and finished.include? @list.current
finished.each do |task|
  task[:finished] = Date.today
  print "Finished: "
  @list.print task
  @done << task
  @list.delete task
end
@list.save TODO
@done.save DONE
