#!/usr/bin/env ruby

require_relative "todo.rb"

if ARGV.empty? 
  finished = [@list.current]
else
  finished = ARGV.collect { |i| @list[i.to_i] }
end
@done = Array.read DONE
@list.current.punchout if @list.current and finished.include? @list.current
finished.each do |task|
  task[:finished] = Date.today
  @done << task
  @list.delete task
  print "Finished: "
  @done.print task
end
@list.save TODO
@done.save DONE
print_day Date.today
