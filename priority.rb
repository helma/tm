#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
task = @list.delete_at ARGV.first.to_i
@list.insert ARGV.last.to_i, task
@list.save TODO
print "moved: "
@list.print task
