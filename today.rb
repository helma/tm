#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

@list.overdue.each{|t| t.print}
@list.today.each{|t| t.print}
@list.scheduled.each do |t|
  print "#{(t.date - Date.today).to_i.to_s.rjust(3)} days: "
  t.print
end
