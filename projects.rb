#!/usr/bin/env ruby

require 'rinruby'
require File.join(File.dirname(__FILE__),"todo.rb")
# use Tsort!!

if ARGV.empty?
  @list.each{|t| @list.print t}
  #@list.each{|t| @list.print t if t.sink?}
else
  #nodes = []
  #nodes << @list[ARGV.first.to_i]

  #edges = []
  #sin

edges = []
@list.projects.each do |t|
  t[:before].each do |uuid|
    child = @list.select{|c| c[:uuid] == uuid}.first
    edges << [t[:description], child[:description]]
  end if t[:before]
end
R.eval <<EOF
library(igraph)
png("test.png")
el <- matrix( c('#{edges.join "','"}'), nc=2, byrow=TRUE)
g <- graph.edgelist( el )
V(g)$label <- V(g)$name
plot(g)
c <- clusters(g)
lapply(c,plot)
class(c)
dev.off()
EOF
#`display test.png`
#@list.projects.each{|t| puts t.to_yaml}
end
