#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

task = @list[ARGV.first.to_i]
if ARGV.size == 2 # add duration
  date = Date.today
elsif ARGV.size == 3 # add duration
  date = Date.today + ARGV.last.to_i
end
task[:offline] ||= {}
task[:offline][date] = ARGV[1].to_f*3600
@list.save TODO
