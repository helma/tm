#!/usr/bin/env ruby
require 'date'
require File.join(File.dirname(__FILE__),"todo.rb")

TRANSLATE = [
  ["toxbank", "ToxBank"],
  ["nanotox", "ModNanoTox"]
]

def from_gcal line
  items = line.split("\t")
  str = items[3]
  TRANSLATE.each{ |tr| str.gsub!(/#{tr.last}/,"+#{tr.first}") }
  str += " due:" + items[0] 
  str += " " + items[1] unless items[1] == "00:00"
  Todo::Task.new str
end

def to_gcal task
  str = task.text.gsub(/\+/, '').gsub(/due:/, '').gsub(/t:\d{4}-\d{2}-\d{2}/, '').gsub(/@\w+/, '')
  TRANSLATE.each{ |tr| str.gsub!(/#{tr.first}/,"#{tr.last}") }
  str
end

# import
#gcal = []
`gcalcli --tsv agenda #{Date.today} #{Date.today+365}`.each_line do |line|
  task = from_gcal line
  #gcal << task 
  @list.push task unless @list.include? task
end
@list.save

=begin
# export
@list.select{|t| t.due_date}.each do |task|
  puts "gcalcli quick #{to_gcal(task)}" unless gcal.collect{|t| t.orig}.include? task.orig
  #`gcalcli quick #{to_gcal(task)}` unless gcal.collect{|t| t.orig}.include? task.orig
end
=end
