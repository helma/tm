#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
args = ARGV
project = args.grep(/^\+/)
args -= project
context = args.grep(/^@/)
args -= context
annotations = args.grep(/^\w+:/)
args -= annotations
task = {:description => args.join(" ")}
task[:project] = project.first.sub(/^\+/,'') unless project.empty?
task[:context] = context.first.sub(/^@/,'') unless context.empty?
task[:added] = Date.today
annotations.each do |a|
  k,v = a.split ':'
  task[k.to_sym] = v
end if annotations
@list << task
File.open(TODO,"w+"){|f| f.puts @list.to_yaml}
print "Added: "
task.print @list
