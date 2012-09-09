#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
@deleted = YAML.load_file DELETED

task = @list.delete_at ARGV.first.to_i 
task[:deleted] = Date.today
@deleted << task
File.open(DELETED,"a+"){|f| f.puts @deleted.to_yaml}
File.open(TODO,"w+"){|f| f.puts @list.to_yaml}

print "Deleted: "
task.print @deleted
