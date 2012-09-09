#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

@list.select{|t| t.overdue?}.sort{|a,b| a.date_diff <=> b.date_diff}.each{|t| t.print @list}
@list.select{|t| t.today?}.sort{|a,b| a.date_diff <=> b.date_diff}.each{|t| t.print @list}
@list.select{|t| t.scheduled?}.sort{|a,b| a.date_diff <=> b.date_diff}.each{|t| t.print @list}
