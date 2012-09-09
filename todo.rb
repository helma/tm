#!/usr/bin/env ruby

require 'fileutils'
require 'colorize'
require 'date'
require 'time'
require 'yaml'

TODO_DIR = "#{ENV["HOME"]}/.todo"
TODO = File.join TODO_DIR, "todo.yaml"
DONE = File.join TODO_DIR, "done.yaml"
DELETED = File.join TODO_DIR, "deleted.yaml"
CURRENT = File.join TODO_DIR, "current"

class Float
  def to_m
    min,r = self.divmod 60
    "#{min}:#{format '%02d', r.round}"
  end
  def to_h
    hr,r = self.divmod 3600
    "#{hr}:#{format '%02d', (r/60).round}"
  end
end

def colorize(text, color_code)
  "#{color_code}#{text}\033[0m"
end

def red(text); colorize(text, "\033[31m"); end
def green(text); colorize(text, "\033[32m"); end
def yellow(text); colorize(text, "\033[33m"); end

def current 
  description = File.read CURRENT
  @list.select{|t| t[:description] == description.chomp}.first
end

class Hash

  def overdue?
    self[:due] and self[:due] < Date.today
  end

  def today?
    (self[:due] and self[:due] == Date.today) or
    (self[:scheduled] and self[:scheduled] <= Date.today)
  end

  def scheduled?
    self[:due] or self[:scheduled]
  end

  def future?
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

  def dur
    Time.now - self[:punch].last.first if self[:punch] and self[:punch].last.size == 1
  end

  def print list

    str = "#{"%02d" % list.index(self)}  #{self[:description]}"
    str += " (#{self.date_diff} days) " if self.scheduled?
    str += " (#{self.dur.to_m} min)" if self.dur
    str = red str if self.overdue?
    str = green str if self.today?
    puts str
  end

  def punchout
    self[:punch].last << Time.now
    File.open(CURRENT,"w+"){|f| f.print ""}
    File.open(TODO,"w+"){|f| f.puts @list.to_yaml}
  end

  def punchin 
    self[:punch] ||= []
    self[:punch] << [Time.now]
    File.open(CURRENT,"w+"){|f| f.print self[:description]}
    File.open(TODO,"w+"){|f| f.puts @list.to_yaml}
  end

  def done
    @done = YAML.load_file DONE
    self.punchout if self == current
    self[:finished] = Date.today
    @done << task
    @list.delete self
    File.open(DONE,"a+"){|f| f.puts @done.to_yaml}
    File.open(TODO,"w+"){|f| f.puts @list.to_yaml}
  end

end

@list = YAML.load_file TODO
