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

@list = YAML.load_file TODO

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
  @list ||= YAML.load_file TODO
  @list.select{|t| t[:description] == description.chomp}.first
end

def save
  File.open(TODO,"w+"){|f| f.puts @list.to_yaml} if @list and !@list.empty?
  File.open(DONE,"w+"){|f| f.puts @done.to_yaml} if @done and !@done.empty?
  File.open(DELETED,"w+"){|f| f.puts @deleted.to_yaml} if @deleted and !@deleted.empty?
  `cd #{TODO_DIR}; git commit -am "#{Time.now}"`
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
    str = "#{"%02d" % list.index(self)} #{self[:description]}"
    str += " (#{self.date_diff} days) " if self.scheduled?
    str += " (#{self.dur.to_m} min)" if self.dur
    str = red str if self.overdue?
    str = green str if self.today?
    puts str
  end

  def punchout
    self[:punch].last << Time.now
    File.open(CURRENT,"w+"){|f| f.print ""}
  end

  def punchin 
    self[:punch] ||= []
    self[:punch] << [Time.now]
    File.open(CURRENT,"w+"){|f| f.print self[:description]}
  end

  def parse args
    shortcuts = {
      :e => :expected_duration,
      :s => :scheduled,
      :d => :due,
      :p => :pri
    }
    project = args.grep(/^\+/)
    args -= project
    #billing = args.grep(/^\$/)
    #puts billing
    #args -= billing
    context = args.grep(/^@/)
    args -= context
    annotations = args.grep(/^\w+:/)
    args -= annotations
    self[:added] = Date.today if self.empty?
    self[:description] = args.join(" ") unless args.empty?
    self[:project] = project.first.sub(/^\+/,'') unless project.empty?
    #self[:billing] = billing.first.sub(/^\$/,'') unless billing.empty?
    self[:context] = context.first.sub(/^@/,'') unless context.empty?
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
      when "dep"
      when "pri"
      end
      self[k.to_sym] = v
    end if annotations
  end

end

