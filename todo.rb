#!/usr/bin/env ruby

require 'fileutils'
require 'date'
require 'time'
require 'yaml'
require 'securerandom'

TODO_DIR = "#{ENV["HOME"]}/.todo"
TODO = File.join TODO_DIR, "todo.yaml"
DONE = File.join TODO_DIR, "done.yaml"
DELETED = File.join TODO_DIR, "deleted.yaml"
CURRENT = File.join TODO_DIR, "current"

@list = YAML.load_file TODO
@fun = [ "alfadeo", "art", "body", "climbing", "mind", "music" ]

class Float
  def to_m
    min,r = self.divmod 60
    "#{min}:#{format '%02d', r.round}m"
  end
  def to_h
    hr,r = self.divmod 3600
    "#{hr}:#{format '%02d', (r/60).round}h"
  end
  def to_time
    self > 3600.0 ? self.to_h : self.to_m
  end
end

def colorize(text, color_code)
  "#{color_code}#{text}\033[0m"
end

def red(text); colorize(text, "\033[31m"); end
def green(text); colorize(text, "\033[32m"); end
def cyan(text); colorize(text, "\033[36m"); end
def yellow(text); colorize(text, "\033[33m"); end
def blue(text); colorize(text, "\033[34m"); end
def underline(text); colorize(text, "\033[4m"); end
def blink(text); colorize(text, "\033[5m"); end
def bold(text); colorize(text, "\033[1m"); end

def current 
  uuid = File.read CURRENT
  @list ||= YAML.load_file TODO
  @list.select{|t| t[:uuid] == uuid.chomp}.first
end

def save
  File.open(TODO,"w+"){|f| f.puts @list.to_yaml} if @list and !@list.empty?
  File.open(DONE,"w+"){|f| f.puts @done.to_yaml} if @done and !@done.empty?
  File.open(DELETED,"w+"){|f| f.puts @deleted.to_yaml} if @deleted and !@deleted.empty?
  `cd #{TODO_DIR}; git commit -am "#{Time.now}"`
end

def session_dur
  @list ||= YAML.load_file TODO
  @done ||= YAML.load_file DONE
  punch = []
  (@list+@done).each do |t|
    t[:punch].each{|p| punch << p } if t[:punch]
  end
  punch.sort!{|a,b| a.first <=> b.first}
  punch.last[1] = Time.now if punch.last.size == 1
  dur = 0
  start = Time.now
  punch.reverse.each do |p|
    pause = start - p.last 
    break if pause > 5*60
    dur += p.last - p.first
    start = p.first
  end
  dur
end

def day date_offset
  date = Date.today + date_offset
  @list.select{|t| t.day? date}.sort{|a,b| a.date_diff <=> b.date_diff}
end

def stat start=Date.today, finish=Date.today, tags=nil#, tasks=nil
  dates = start..finish
  @list ||= YAML.load_file TODO
  @done ||= YAML.load_file DONE
  @list += @done
  tags ||= (@list.collect{|t| t[:tags]}.flatten.uniq.sort + ['-']) #TOO fix empty tags
  planned_time = 0.0
  real_time = 0.0
  @list.each do |t|
    unless (t[:tags] & tags).empty?
      planned_time += t[:expected_duration]
      (start..finish).each do |day|
        real_time += t.duration(day)
      end
    end
  end
  [real_time, planned_time]
end

def overdue
  @list.select{|t| t.overdue?}.sort{|a,b| a.date_diff <=> b.date_diff} 
end

class Hash

  def overdue?
    self[:due] and self[:due] < Date.today
  end

  def day? date
    (self[:due] and self[:due] == date) or
    (self[:scheduled] and self[:scheduled] == date)
  end

  def today?
    day? Date.today
  end

  def scheduled?
    self[:due] or self[:scheduled]
  end

  def next?
    (self[:due] and self[:due] > Date.today) or
    (self[:scheduled] and self[:scheduled] > Date.today)
  end

  def date_diff
    if self[:due] 
      (self[:due] - Date.today).to_i
    elsif self[:scheduled]
      (self[:scheduled] - Date.today).to_i
    end
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
    self[:offline].each_value{|t| dur += t} if self[:offline]
    dur
  end

  def dur
    Time.now - self[:punch].last.first if self[:punch] and self[:punch].last.size == 1
  end
  
  def duration date
  end

  def sprint
    puts "#{dur.to_time} #{self[:description]}"
  end

  def print list
    str = "#{"%02d" % list.index(self)} #{self[:description]}"
    if self.scheduled?
      case self.date_diff
      when 0
        str+= " (today)"
      when 1
        str+= " (tomorrow)"
      else
        str += " (#{self.date_diff} days)"
      end
    end
    str += " #{self.total_dur.to_time} min" unless self.total_dur == 0
    str += " (#{self[:expected_duration].to_f.to_time})" if self[:expected_duration]
    self[:tags].each{|t| str += " +#{t}"}
    str = red str if self.overdue?
    if self.today?
      self[:expected_duration] ? str = green(str) : str = cyan(str)
    end
    #str = blue str
    if self.scheduled?
      self[:expected_duration] ? str = blue(str) : str = cyan(str)
    end
    puts str
  end

  def punchout
    self[:punch].last << Time.now
    File.open(CURRENT,"w+"){|f| f.print ""} 
  end

  def punchin 
    self[:punch] ||= []
    self[:punch] << [Time.now]
    File.open(CURRENT,"w+"){|f| f.print self[:uuid]}
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
      k,v = a.split ':'
      k = shortcuts[k.to_sym] if shortcuts.keys.include? k.to_sym
      case k.to_s
      when /scheduled|due/
        case v.to_s
        when /\d{4}-\d{2}-\d{2}/
          v = Date.parse v
        when /\d+/
          v = Date.today + v.to_i
        when ""
          v = Date.today
        end
      when "expected_duration"
        v = v.to_i * 60
      end
      self[k.to_sym] = v
    end if annotations
  end

end

