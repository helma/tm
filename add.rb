#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
task = {}
task.parse ARGV
@list << task
save
print "Added: "
task.print @list
