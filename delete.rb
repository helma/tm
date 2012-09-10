#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
@deleted = YAML.load_file DELETED

task = @list.delete_at ARGV.first.to_i 
task[:deleted] = Date.today
@deleted << task
save
print "Deleted: "
task.print @deleted
