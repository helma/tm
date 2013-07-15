#!/usr/bin/env ruby

require 'fileutils'
require 'date'
require 'time'
require 'yaml'
require 'securerandom'
require 'term/ansicolor'
require 'tsort'
include Term::ANSIColor

TODO_DIR = "#{ENV["HOME"]}/.todo"
TODO = File.join TODO_DIR, "todo.yaml"
DONE = File.join TODO_DIR, "done.yaml"
DELETED = File.join TODO_DIR, "deleted.yaml"
RECURRENT = File.join TODO_DIR, "recurrent.yaml"
CURRENT = File.join TODO_DIR, "current"
DESCRIPTION = File.join TODO_DIR, "description"

class Float
  def to_m
    min,r = self.divmod 60
    "#{min}:#{format '%02d', r.round}m"
  end
  def to_h
    hr,r = self.divmod 3600
    "#{hr}:#{format '%02d', (r/60).round}h"
  end
  def to_datetime
    self > 3600.0 ? self.to_h : self.to_m
  end
end

def not_work
  YAML.load_file File.join(TODO_DIR,"not-work.yaml")
end

def not_computer
  YAML.load_file File.join(TODO_DIR,"not-computer.yaml")
end

def print_day date
  @list ||= Array.read TODO
  @done ||= Array.read DONE
  @deleted ||= Array.read DELETED

  YAML.load_file(RECURRENT).each do |taskstr,dates|
    if dates.include? date.wday #and !@deleted.select{|t| t[:scheduled] == date and t[:description] == taskstr}.empty?
      task = Task.new(taskstr.split(" "))
      task[:scheduled] = date.to_datetime
      @list << task if (@done+@list).select{|t| t.scheduled_at?(date) and t[:description] == task[:description]}.empty?
    end
  end
  @list.save TODO

  not_scheduled = (@list+@done).select{|t| t.day_dur(date) > 0.0 and !t.scheduled_at? date}
  all_stat = Stat.new not_scheduled, date, date#[@list,@done]
  done_stat = Stat.new @done, date, date
  todo_stat = Stat.new @list, date, date

  puts yellow("#{(date).strftime('%a %d %b %Y')} w#{todo_stat[:work][:planned].to_f.to_datetime}/f#{todo_stat[:not_work][:planned].to_f.to_datetime}/t#{todo_stat[:total][:planned].to_f.to_datetime}")
  @list.each{|t| @list.print t if t[:scheduled] and t[:scheduled].to_date == date}

  if date == Date.today
    puts blue("  Done: w#{done_stat[:work][:measured].to_f.to_datetime}/f#{done_stat[:not_work][:measured].to_f.to_datetime}/t#{done_stat[:total][:measured].to_f.to_datetime}")
    @done.each do |t|
      if t[:finished] == date
        print "  "
        @done.print t
      end
    end
    puts cyan("  Not scheduled: w#{all_stat[:work][:measured].to_f.to_datetime}/f#{all_stat[:not_work][:measured].to_f.to_datetime}/t#{all_stat[:total][:measured].to_f.to_datetime}")
    @list.each do |t|
      unless t.day_dur(date) == 0.0 or t.scheduled_at? date
        print "  "
        @list.print t
      end
    end
    @done.each do |t|
      unless t.day_dur(date) == 0.0 or t.scheduled_at? date
        print "  "
        @done.print t
      end
    end
  end
end


class Array
  include TSort

  attr_accessor :file

  def self.read file
    list = YAML.load_file file
    list.file = file
    list.each { |t| t.sanitize }
    list.prioritize
  end

  def save file
    File.open(file,"w+"){|f| f.puts self.to_yaml}
    `cd #{TODO_DIR}; git commit -am "#{file} saved #{Time.now}"`
  end

  def find_by_uuid uuid
    tasks = select{|t| t[:uuid] == uuid}
    tasks.empty? ? nil : tasks.first
  end

  def prioritize
    sort do |a,b|
      as = a[:scheduled] 
      bs = b[:scheduled]
      as ||= a[:due]
      bs ||= b[:due]
      as ||= (Date.today+3650).to_datetime
      bs ||= (Date.today+3650).to_datetime
      as <=> bs
    end.tsort
  end

  def print task
    str = "%03d" % self.index(task)
    if task.node? and task.after(self).nil?
      prefix = " * "
    elsif task.sink?
      prefix = " = "
    elsif task.node?
      prefix = " - "
    else
      prefix = " "
    end
    str += prefix
    str += task[:description]
    if task[:due]
      case task.date_diff
      when 0
        str+= " (today "
      when 1
        str+= " (tomorrow "
      else
        str += " (#{task.date_diff} days "
      end
      str += task[:due].to_s.split("T").last.split(":")[0..1].join(":")+")"
    end
    str += " "
    str += "#{task.total_dur.to_datetime}/" 
    str += "#{task[:expected_duration].to_f.to_datetime}" 
    task[:tags].each{|t| str += " +#{t}"}
    
    if task.after self
      dependencies = task.after(self).collect{|t| index t}
      str += " <- #{dependencies}"
    end
    if task[:before]
      dependencies = task.before(self).collect{|t| index t}
      str += " -> #{dependencies}"
    end
    str = red str if task[:due]#task.overdue?
    if task.today?
      task[:expected_duration] ? str = green(str) : str = cyan(str)
    end
    if task[:scheduled]
      task[:expected_duration] ? str = blue(str) : str = cyan(str)
    end
    tags = collect{|t| t[:tags]}.flatten.uniq.sort 
    work = tags - not_work
    str = bold str if !task[:tags].empty? and (task[:tags] & work).empty?
    str = on_blue str if !task[:tags].empty? and !(task[:tags] & not_computer).empty?
    str = underline str if task[:due]
    str = negative str if task == current
    puts "  "+str
  end

  alias tsort_each_node each

  def tsort_each_child(task, &block)
    task.after(self).each(&block) if task.after(self)
  end

  def current 
    uuid = File.read CURRENT
    self.select{|t| t[:uuid] == uuid.chomp}.first
  end

  def at_day date_offset
    date = Date.today + date_offset
    self.select{|t| t.scheduled_at? date}.sort{|a,b| a.date_diff <=> b.date_diff}
  end

  def overdue
    self.select{|t| t.overdue?}.sort{|a,b| a.date_diff <=> b.date_diff} 
  end

  def projects
    self.select{|t| t.node?}
  end

end

class Task < Hash

  def initialize args=nil
    self[:uuid] = SecureRandom.uuid
    parse args if args
  end

  def sanitize
    if self[:finished]
      self[:scheduled] = self[:due] if self[:due] and !self[:scheduled]
    else
      self[:scheduled] = self[:due] if self[:due] and !self[:scheduled]
      self[:scheduled] = DateTime.now if overdue? or (self[:scheduled] and self[:scheduled] < DateTime.now)
    end
  end

  def overdue?
    self[:due] and self[:due] < DateTime.now
  end

  def scheduled_at? date
    self[:scheduled] and self[:scheduled].to_date == date
  end

  def today?
    scheduled_at? Date.today
  end

  def next?
    self[:due] and self[:due].to_date > Date.today
  end

  def date_diff
    (self[:due].to_date - Date.today).to_i if self[:due]
  end

  def total_dur
    dur = 0.0
    self[:punch].each do |d|
      if d.size == 2
        dur += d.last - d.first
      elsif d.size == 1
        dur += Time.now - d.first 
      end
    end if self[:punch] 
    self[:offline].each{|d,t| dur += t} if self[:offline]
    dur
  end

  def current_dur
    Time.now - self[:punch].last.first if self[:punch] and self[:punch].last.size == 1
  end
  
  def day_dur date, end_date=date
    dur = 0.0
    self[:punch].each do |punch|
      if punch.first.to_date >= date and punch.first.to_date <= end_date
        if punch.size == 2
          dur += punch.last - punch.first
        elsif punch.size == 1
          dur += Time.now - punch.first 
        end
      end
    end if self[:punch]
    self[:offline].each { |d,time| dur += time if d == date } if self[:offline]
    dur
  end

  def expected_dur date
    (self[:expected_duration] and self[:scheduled] == date) ?  self[:expected_duration] : 0.0
  end

  def source?
    self[:before] and !self[:after]
  end

  def before list
    self[:before].collect{ |uuid| list.find_by_uuid uuid } if self[:before]
  end

  def after list
    if self[:after]
      tasks = self[:after].collect{ |uuid| list.find_by_uuid uuid  }.compact
      tasks.empty? ? nil : tasks
    end
  end

  def node?
    self[:after] or self[:before]
  end

  def sink?
    self[:after] and !self[:before]
  end

  def print
    puts "#{current_dur.to_datetime} #{self[:description]}"
  end

  def punchout
    self[:punch].last << Time.now
    File.open(CURRENT,"w+"){|f| f.print ""} 
    File.open(DESCRIPTION,"w+"){|f| f.print ""} 
  end

  def punchin 
    self[:punch] ||= []
    self[:punch] << [Time.now]
    File.open(CURRENT,"w+"){|f| f.print self[:uuid]}
    File.open(DESCRIPTION,"w+"){|f| f.print self[:description]} 
  end

  def parse args
    shortcuts = {
      :e => :expected_duration,
      :s => :scheduled,
      :d => :due,
    }
    tags = args.grep(/^\+/)
    args -= tags
    untags = args.grep(/^-/)
    args -= untags
    annotations = args.grep(/^[a-z]+:/)
    args -= annotations
    self[:added] = Date.today if self.empty?
    self[:description] = args.join(" ") unless args.empty?
    self[:tags] ||= []
    self[:tags] += tags.collect{|t| t.sub(/^\+/,'')}
    self[:tags] -= untags.collect{|t| t.sub(/^-/,'')}
    annotations.each do |a|
      k,v = a.split ':', 2
      k = shortcuts[k.to_sym] if shortcuts.keys.include? k.to_sym
      case k.to_s
      when /scheduled|due/
        case v.to_s
        when /\d{4}-\d{2}-\d{2}/
          v = DateTime.parse(v+" +02:00")
        when /\d+/
          v = DateTime.now + v.to_i
        when ""
          v = nil
        end
      when "expected_duration"
        v = v.to_i * 60
      end
      v ? self[k.to_sym] = v : self.delete(k.to_sym)
    end if annotations
    sanitize
  end

end

class Stat < Hash

  def initialize lists, start=Date.today, finish=Date.today
    @list = lists.flatten
    @tags = @list.collect{|t| t[:tags]}.flatten.uniq.sort 
    @work = @tags - not_work
    @tags += [:none,:work,:not_work,:total]
    @tags.each{ |t| self[t.to_sym] = {:planned => 0.0, :measured => 0.0} }
    (start..finish).each do |day|
      @list.each do |t|
        measured = t.day_dur(day)
        planned = t.expected_dur day
        self[:total][:planned] += planned
        self[:total][:measured] += measured
        if (t[:tags] & @work).empty?
          self[:not_work][:planned] += planned
          self[:not_work][:measured] += measured
        else
          self[:work][:planned] += planned
          self[:work][:measured] += measured
        end
        t[:tags].each do |tag|
          self[tag.to_sym][:planned] += planned
          self[tag.to_sym][:measured] += measured
          self[tag.to_sym][:finished] ||= 0
          self[tag.to_sym][:finished] += 1 if t[:finished] == day
        end
        if t[:tags].empty?
          self[:none][:planned] += planned
          self[:none][:measured] += measured
        end
      end
    end
  end

  def session_dur
    punch = []
    @list.each do |t|
      t[:punch].each{|p| punch << p } if t[:punch] and !t[:tags].empty? and (t[:tags] & not_computer).empty?
    end
    punch.sort!{|a,b| a.first <=> b.first}
    punch.last[1] = Time.now if punch.last.size == 1
    dur = 0.0
    start = Time.now
    punch.reverse.each do |p|
      pause = start - p.last 
      break if pause > 5*60
      dur += p.last - p.first
      start = p.first
    end
    dur
  end

end

@list = Array.read TODO
