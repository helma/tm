#!/usr/bin/env ruby
require 'github_api'
require "rest-client"
require 'json'
#require 'yaml'
require File.join(File.dirname(__FILE__),"todo.rb")

def parse uri
  JSON.parse(RestClient.get uri)
rescue
  []
end

parse("https://api.github.com/users/opentox/repos").each do |r|
  name = r["name"]
  name = "opentox-" + name unless name =~ /opentox-/
  parse(r["url"]+"/issues").each do |i|
    task = Todo::Task.new "#{name} #{i["title"]} #{i["html_url"]}"
    @list.push task unless @list.include? task
  end
end
@list.save
