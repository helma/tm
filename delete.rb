#!/usr/bin/env ruby

puts `cp -v $HOME/.todo/todo.txt $HOME/.todo/todo.txt~`
puts `sed -i #{ARGV.first}d $HOME/.todo/todo.txt`
