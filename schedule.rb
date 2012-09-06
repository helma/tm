#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

line = ARGV.shift.to_i-1
method = ARGV.shift
if method.chomp =~ /^[\+-]$/
  ARGV.empty? ? days = 1 : days = ARGV.first.to_i
  date = Date.today.send method, days
  @list[line].orig.sub!(/t:\d{4}-\d{2}-\d{2}/,"t:#{date}")
  puts @list[line].orig
end
