#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
if @list.current
  @done = Array.read DONE
  stat = Stat.new [@list,@done]
  dur = stat.session_dur
  print "PAUSE! " if dur > 50*60
  print dur.to_time + " "
  puts @list.current[:description]
end
