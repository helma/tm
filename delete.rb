#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
@deleted = YAML.load_file DELETED
to_delete = ARGV.collect { |i| @list[i.to_i] }
to_delete.each{|task| task[:deleted] = Date.today}
@list -= to_delete
@deleted += to_delete
to_delete.each{|task| print "Deleted: "; task.print @deleted}
save
