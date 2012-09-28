#!/usr/bin/env ruby
require 'github_api'
require "rest-client"
require 'json'
require File.join(File.dirname(__FILE__),"todo.rb")

def parse uri
  JSON.parse(RestClient.get uri)
rescue
  []
end

parse("https://api.github.com/users/opentox/repos").each do |r|
  unless r["name"] =~ /opentox-ruby|validation/
    parse(r["url"]+"/issues").each do |i|
      task = Task.new ["+#{r["name"]}", " #{i["title"]} #{i["html_url"]}"]
      task[:description].strip!
      @list << task unless @list.collect{|t| t[:description]}.include? task[:description]
    end
  end
end
@list.save TODO
