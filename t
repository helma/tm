#!/usr/bin/env ruby

SHORTCUTS = {
  :a => :add,
  :e => :edit,
  :l => :ls,
  :p => :punch,
  :d => :done,
  :x => :delete,
  :t => :today,
  :c => :current,
  :pri => :priority,
  :dep => :dependencies,
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
    if ARGV.size == 1
      run :punch
    else
      run "modify"
    end
  when /^\w+$/ 
    action = ARGV.shift.to_sym
    run SHORTCUTS[action]
  else
    run :add
  end
end
