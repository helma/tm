#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

task = Task.new ARGV
@list << task
@list.save TODO
print "Added: "
@list.print task
