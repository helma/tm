#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

(0..6).each do |d|
  total_dur = 0
  work_dur = 0
  today = day d
  today.each do |t|
    total_dur += t[:expected_duration] if t[:expected_duration]
    work_dur += t[:expected_duration] if t[:expected_duration] and (t[:tags] & @fun).empty?
  end
  puts yellow("#{(Date.today+d).strftime('%a %d %b %Y')} #{work_dur.to_f.to_time}/#{total_dur.to_f.to_time}")
  today.each{|t| t.print @list}
end
