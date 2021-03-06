#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

def print_tag tag
  puts(yellow(tag))
  if tag == "-"
    @list.select{|t| t[:tags].empty? }.each { |t| @list.print t } 
  else
    @list.select{|t| t[:tags].include? tag}.each { |t| @list.print t } 
  end
end

if ARGV.empty?
  @list.collect{|t| t[:tags]}.flatten.uniq.sort.each { |tag| print_tag tag }
  print_tag "-"
else
  print_tag ARGV.first
end
