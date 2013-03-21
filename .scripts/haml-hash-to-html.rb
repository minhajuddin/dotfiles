#!/usr/bin/env ruby

h = eval(ARGF.read)
puts "(#{h.map{|key,value| "#{key}='#{value}'"}.join(' ')})"
