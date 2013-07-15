#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__),"todo.rb")

@done = Array.read DONE
ARGV[0] ? start = Date.parse(ARGV[0]) : start = Date.today
ARGV[1] ? finish = Date.parse(ARGV[1]) : finish = Date.today
stat = {}

(@list+@done).each do |t|
  dur = t.day_dur(start, finish) 
  puts "#{t[:description]} #{t[:uuid]} #{(dur/3600).round}" if dur > 8*3600
  if (t[:finished] and t[:finished] >= start and t[:finished] <= finish) or dur > 0
    t[:tags] = [:untagged] if t[:tags].empty?
    t[:tags] << :total 
    #t[:tags] << :work if (t[:tags] & not_work).size == 0
    t[:tags].each do |tag|
      stat[tag.to_sym] ||= {}
      stat[tag.to_sym][:dur] ||= 0.0
      stat[tag.to_sym][:tasks] ||= []
      stat[tag.to_sym][:dur] += dur
      if t[:punch] or t[:offline] 
        stat[tag.to_sym][:tasks] << t[:description]
      else
        stat[tag.to_sym][:tasks] << "*"+t[:description]
        stat[tag.to_sym][:dur_missing] = true
      end
    end
  end
end

weeks = (finish-start).to_f/7

stat.sort_by{|t,p| p[:dur]}.reverse.each do |tag|
  print "#{tag[0]}: "
  print "*" if tag[1][:dur_missing]
  puts "#{(tag[1][:dur]/3600).round} (#{(tag[1][:dur]/3600/weeks).round}/week) #{tag[1][:tasks].size}"# [ #{tag[1][:tasks].uniq.join(', ')} ]"
end
