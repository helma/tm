#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
task = @list[ARGV.shift.to_i]
task.parse ARGV
@list.save TODO
print "Modified: "
@list.print task
