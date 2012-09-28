#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

if ARGV.empty?
  @list.current.punchout if @list.current
elsif ARGV.size == 1 and ARGV.first =~ /\d+/
  task = @list[ARGV.first.to_i]
  @list.current.punchout if @list.current
  task.punchin if task
end
@list.save TODO
