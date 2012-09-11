#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
task = @list[ARGV.shift.to_i]
task.parse ARGV
save
print "Modified: "
task.print @list
