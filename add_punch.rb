#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
line = @list.size
task = {}
task.parse ARGV
@list << task
save
`punch.rb #{line}`
print "Added: "
task.print @list
