#!/usr/bin/env ruby

require_relative "todo.rb"

ARGV += ["+INBOX"] if ARGV.grep(/^[sd]:/)
task = Task.new ARGV
@list << task
@list.save TODO
@list.prioritize
print "Added: "
@list.print task
print_day Date.today
