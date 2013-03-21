#!/usr/bin/env ruby

#ns = [[2,2], [4]]
ns = [[4]]
chords = %w(A D E)
interval = 1.4
prev = chords.sample
while true
 ns.sample.each do |n|
    prev = chord = (chords-[prev]).sample
    n.times{
      print "#{chord}   "
      sleep interval
    }
  end
  puts ''
end
