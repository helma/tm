#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
(0..6).each{ |d| print_day(Date.today + d)}
