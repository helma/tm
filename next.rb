#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

puts yellow("next")
@list.select{|t| t.next?}.sort{|a,b| a.date_diff <=> b.date_diff}.each{|t| t.print @list}
