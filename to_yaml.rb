#!/usr/bin/env ruby
require 'yaml'

require File.join(File.dirname(__FILE__),"todo.rb")

todo = {}

project_tasks = []
@list.projects.each do |project|
  todo[project] = []
  @list.project_tasks(project).each do |t|
    name = t.orig.sub(/\+#{project}/,'').strip
    due = name.match(/due:(\d{4}-\d{2}-\d{2})/)#[1]
    if due
      todo[project] << { name.sub(/due:(\d{4}-\d{2}-\d{2})/,'').strip => { "due" => due[1] } }
    else
      todo[project] << { t.orig.sub(/\+#{project}/,'').strip => nil }
    end
    project_tasks << t
  end
end
project = "not assigned"
todo[project] = []
(@list - Todo::List.new(project_tasks)).each{|t|
  #todo["not assigned"] << t.orig.strip
  name = t.orig.sub(/\+#{project}/,'').strip
  due = name.match(/due:(\d{4}-\d{2}-\d{2})/)#[1]
  if due
    todo[project] << { name.sub(/due:(\d{4}-\d{2}-\d{2})/,'').strip => { "due" => due[1] } }
  else
    todo[project] << { t.orig.sub(/\+#{project}/,'').strip => nil }
  end
}

puts todo.to_yaml
