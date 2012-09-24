#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

class Hash
  def self.from_gcal line
    task = {}
    items = line.split("\t")
    task[:uuid] = SecureRandom.uuid
    task[:description] = items[3]
    task[:description] += " " + items[1] unless items[1] == "00:00"
    task[:tags] = []
    task[:due] = Date.parse items[0] 
    case items[3]
    when /ToxBank/i
      task[:tags] << "toxbank"
    when /ModNanoTox/i
      task[:tags] << "nanotox"
    when /BMBF/i
      task[:tags] << "bmbf"
    end
    task
  end

=begin
  def to_gcal task
    str = task.text.gsub(/\+/, '').gsub(/due:/, '').gsub(/t:\d{4}-\d{2}-\d{2}/, '').gsub(/@\w+/, '')
    TRANSLATE.each{ |tr| str.gsub!(/#{tr.first}/,"#{tr.last}") }
    str
  end
=end
end

# import

`gcalcli --tsv agenda #{Date.today} #{Date.today+365}`.each_line do |line|
  task = Hash.from_gcal line
  @list << task unless @list.collect{|t| t[:description]}.include? task[:description]
end
save

=begin
# export
@list.select{|t| t.due_date}.each do |task|
  puts "gcalcli quick #{to_gcal(task)}" unless gcal.collect{|t| t.orig}.include? task.orig
  #`gcalcli quick #{to_gcal(task)}` unless gcal.collect{|t| t.orig}.include? task.orig
end
=end
