#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

@list.each do |task|
  if task[:due]
    print "REM "
    print task[:due].to_date
    print " MSG "
    puts task[:description]
  end
end
