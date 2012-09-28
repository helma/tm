#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
ARGV.each_with_index do |id,idx|
  print id
  unless idx >= ARGV.size - 1
    before = @list[id.to_i]
    after = @list[ARGV[idx+1].to_i]
    before[:before] ||= []
    before[:before] << after[:uuid]
    before[:before].uniq!
    after[:after] ||= []
    after[:after] << before[:uuid]
    after[:after].uniq!
    print " -> "
  end
end
puts
@list.save TODO
