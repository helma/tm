#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

def print_project project
  project ? puts(yellow(project)) : puts(yellow("--"))
  @list.select{|t| t[:project] == project}.each do |t|
    t.print @list
    #puts "  #{@list.index(t)} #{t[:description]}"
  end
end

if ARGV.empty?
  @list.collect{|t| t[:project]}.uniq.each { |project| print_project project }
else
  print_project ARGV.first
end
