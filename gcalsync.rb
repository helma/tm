#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
@done = Array.read DONE

@google = []
@new = []
`google -u christophhelma calendar list --date #{Date.today.to_s},#{Date.today.year}-12-31 --delimiter "\t" --cal ".*"`.each_line do |line|
  line.chomp!
  case line
  when /^\[/
    @cal = line.gsub(/[\[\]]/,'')
  when ""
  else
    next if @cal == "Deutsche Feiertage"
    @description,time = line.split("\t")
    @time = time.split(" - ")
    @time.collect! do |t|
      month,day,time = t.split " "
      h,m = time.split ":"
      Time.local Date.today.year,month,day,h,m
    end
    tasks = (@done+@list).select{|t| t[:due] and t[:description] == @description and t[:due] == @time.first }
    task = Task.new
    task[:description] = @description
    task[:tags] = [@cal.downcase]
    task[:due] = @time.first if @time and @time.first
    @google << task 
    @new << task if tasks.size == 0
  end
end
@list += @new
@list.save TODO

# export
@list.select{|t| t[:due]}.each do |task|
  dups = @google.select{|t|  t[:description] == task[:description] and t[:due] == task[:due]}.size
  `google -u christophhelma --cal 'helma@in-silico.ch' add '#{task[:description]} #{task[:due]}'` if dups.size == 0
end
