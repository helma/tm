#!/usr/bin/env ruby

SHORTCUTS = {
  :a => :add,
  :e => :edit,
  :l => :ls,
  :p => :punch,
  :s => :schedule,
  :d => :done,
  :D => :delete,
  :t => :today,
  :c => :current,
  :A => :add_punch
}

def run file
  require File.join(File.dirname(__FILE__),file.to_s)
end

if ARGV.empty?
  run "today" 
else
  case ARGV.first
  when /^\d+$/
    run :punch
  when /^\w$/ 
    action = ARGV.shift.to_sym
    run SHORTCUTS[action]
  else
    run :add
  end
end
