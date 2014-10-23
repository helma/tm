#!/usr/bin/env ruby

require_relative "todo.rb"

args = ARGV
args += ["+INBOX"] if ARGV.grep(/^[sd]:/)
task = Task.new args
@list << task
@list.save TODO
@list.prioritize
print "Added: "
@list.print task
#print_day Date.today
