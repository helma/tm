#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
task = @list[ARGV.first.to_i]
dep = @list[ARGV.last.to_i]
task[:dependencies] ||= []
task[:dependencies] << dep[:description]
save
print "moved: "
task.print @list
