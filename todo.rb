#!/usr/bin/env ruby

require 'fileutils'
require 'colorize'
require 'date'
require 'time'

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

module Todo
  TODO_DIR = "#{ENV["HOME"]}/.todo"
  TODO = File.join TODO_DIR, "todo.txt"
  DONE = File.join TODO_DIR, "done.txt"
  PUNCH = File.join TODO_DIR,"punch.csv"
end

require File.join(File.dirname(__FILE__),"list.rb")
require File.join(File.dirname(__FILE__),"task.rb")

@list = Todo::List.new Todo::TODO
