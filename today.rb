#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
@done = YAML.load_file DONE

today = []
today += overdue
today += day 0
total = [0.0,0.0]
work = [0.0,0.0]
today.each do |t|
  total[1] += t[:expected_duration] if t[:expected_duration]
  work[1] += t[:expected_duration] if t[:expected_duration] and (t[:tags] & @fun).empty?
end
@done.select{|t| t[:finished] == Date.today}.each do |t|
  total[0] += t.total_dur 
  work[0] += t.total_dur if (t[:tags] & @fun).empty?
end
[total,work].each { |arr| arr << arr.first+arr.last }
worktime = work.collect{|t| t.to_time}.join("/")
totaltime = total.collect{|t| t.to_time}.join("/")
#puts yellow("#{(Date.today).strftime('%a %d %b %Y')} #{work_dur.to_f.to_time}/#{total_dur.to_f.to_time}")
puts yellow("#{(Date.today).strftime('%a %d %b %Y')} #{worktime} #{totaltime}")
today.each{|t| t.print @list}
