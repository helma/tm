#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
class Array

  def print task
    str = task[:description].strip if task[:description]
    if task[:due]
      str += " due:"
      str += task[:due].to_s.split(" ").first
    end
    task[:tags].each do |t|
      case t
      when "INBOX"
      when "NEXT"
        str = "(B) "+str 
      when "climbing","work","music"
        str += " @#{t}"
      else
        str += " +#{t}"
      end
    end
    puts str
  end
end

@list.each { |t| @list.print t } 
