#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

def punchout
  File.open(Todo::PUNCH,"a+"){|f| f.puts ", #{DateTime.now}, #{@list.current.duration}" } if @list.current
end

if ARGV.empty?
  punchout
elsif ARGV.first =~ /\d+/
  punchout
  File.open(Todo::PUNCH,"a+"){|f| f.print "\"#{@list[ARGV.first.to_i-1].orig.chomp}\", #{DateTime.now}"}
elsif ARGV.size == 2 # add duration
  punchout
  File.open(Todo::PUNCH,"a+"){|f| f.puts "\"#{@list[ARGV.first.to_i-1].orig.chomp}\", , ,#{ARGV.last}.to_f*60*60}"}
end

