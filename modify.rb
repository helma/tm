#!/usr/bin/env ruby

require_relative "todo.rb"
task = @list[ARGV.shift.to_i]
task.parse ARGV
@list.save TODO
@list.prioritize
print "Modified: "
@list.print task
#print_day Date.today
