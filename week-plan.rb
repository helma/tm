#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),"todo.rb")
tasks = []
(0..6).each do |n|
  tasks << "morning mental training s:#{n} e:10 +mind"
  if n < 5
    tasks << "mail +mail s:#{n} e:60"
    n == 0 ? pdur = 90 : pdur = 30
    tasks << "plan +plan s:#{n} e:#{pdur}"
  end
  tasks << "warm up and flex s:#{n} e:15 +body"
  tasks << "antagonists s:#{n} e:20 +body" if [0,2,4].include? n
  tasks << "core s:#{n} e:20 +body" if [1,2,4,5,6].include? n
  tasks << "climbing or training s:#{n} e:240 +climbing" if [1,3,5,6].include? n
  tasks << "evening mental training s:#{n} e:30 +mind"
end

tasks.each do |t|
  task = {:uuid => SecureRandom.uuid}
  task.parse t.split(/\s+/)
  @list << task
end
save
