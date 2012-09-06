#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

if ARGV.empty?
  project_tasks = []
  @list.projects.each do |project|
    puts project.yellow
    @list.project_tasks(project).each do |t|
      print "  "
      t.print
      project_tasks << t
    end
  end
  puts "not assigned".yellow
  (@list - Todo::List.new(project_tasks)).each{|t| print "  "; t.print}

else
  puts ARGV.first
  @list.project_tasks(ARGV.first).each{|t| print "  "; t.print}
end
