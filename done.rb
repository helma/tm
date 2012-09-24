#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

if ARGV.empty? 
  finished = [current]
else
  finished = ARGV.collect { |i| @list[i.to_i] }
end
@done = YAML.load_file DONE
current.punchout if current and finished.include? current
finished.each{|task| task[:finished] = Date.today}
@list -= finished
@done += finished
finished.each{|task| print "Finished: "; task.print @done}
save
