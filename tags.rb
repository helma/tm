#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")

(@list.collect{|t| t[:tags]}.flatten.uniq.sort + ['-']).each { |tag| puts tag }
