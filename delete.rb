#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
@deleted = Array.read DELETED
ARGV.each do |i|
  task = @list[i.to_i]
  task[:deleted] = Date.today
  print "Deleted: "
  @list.print task
  @deleted << task
end
(@list & @deleted).each{|t| @list.delete t}
@list.save TODO
@deleted.save DELETED
