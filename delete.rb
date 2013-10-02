#!/usr/bin/env ruby
require_relative "todo.rb"

@deleted = Array.read DELETED

if ARGV.empty? 
  del = [@list.current]
else
  del = ARGV.collect { |i| @list[i.to_i] }
end

@list.current.punchout if @list.current and del.include? @list.current
del.each do |task|
  task[:deleted] = Date.today
  @deleted << task
  @list.delete task
  print "Deleted: "
  @deleted.print task
end
@list.save TODO
@deleted.save DELETED
#print_day Date.today

