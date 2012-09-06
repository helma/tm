#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
#projects = ARGV.grep /^\+/
#puts projects
#@list.push Task.new(ARGV.join(" "))
#@sorted = 
File.open(Todo::TODO,"a+"){|f| f.puts "#{Date.today} #{ARGV.join(" ")}"}
line = `wc -l #{Todo::TODO}|cut -f1 -d ' '`.chomp
puts "Task #{line} created"
