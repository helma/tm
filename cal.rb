#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
(0..ARGV[0].to_i).each{ |d| print_day(Date.today + d)}
