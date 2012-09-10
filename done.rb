#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

if ARGV.first =~ /\d+/
  task = @list[ARGV.first.to_i]
elsif ARGV.empty? 
  task = current
end
@done = YAML.load_file DONE
task.punchout if current and task == current
task[:finished] = Date.today
@done << task
@list.delete task
save
print "Finished: "
task.print @done
