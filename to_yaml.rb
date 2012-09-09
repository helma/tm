#!/usr/bin/env ruby
require 'yaml'

require File.join(File.dirname(__FILE__),"todo.rb")

todo = []

project_tasks = []
@list.projects.each do |project|
  #todo[project] = []
  @list.project_tasks(project).each do |t|
    task = {}
    name = t.orig.sub(/\+#{project}/,'').strip
    due = name.match(/due:(\d{4}-\d{2}-\d{2})/)#[1]
    task[:description] = name
    task[:project] = project
    task[:due] = Date.new due[1] if due
    #if due
      #todo[project] << { name.sub(/due:(\d{4}-\d{2}-\d{2})/,'').strip => { "due" => due[1] } }
    #else
      #todo[project] << { t.orig.sub(/\+#{project}/,'').strip => nil }
    #end
  todo << task
    project_tasks << t
  end
end
project = "not assigned"
todo[project] = []
(@list - Todo::List.new(project_tasks)).each{|t|
  #todo["not assigned"] << t.orig.strip
    task = {}
  name = t.orig.sub(/\+#{project}/,'').strip
  due = name.match(/due:(\d{4}-\d{2}-\d{2})/)#[1]
    task[:description] = name
    task[:due] = Date.new due[1] if due
  #if due
    #todo[project] << { name.sub(/due:(\d{4}-\d{2}-\d{2})/,'').strip => { "due" => due[1] } }
  #else
    #todo[project] << { t.orig.sub(/\+#{project}/,'').strip => nil }
  #end
    task[:description] = name
    task[:due] = Date.new due[1] if due
}

puts todo.to_yaml
