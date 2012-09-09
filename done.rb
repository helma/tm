#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

if ARGV.first =~ /\d+/
  @list[ARGV.first.to_i].done
elsif ARGV.empty? 
  current.done
end
