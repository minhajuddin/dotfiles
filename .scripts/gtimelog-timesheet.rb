#!/usr/bin/env ruby
require 'time'

task = ARGV.first
exit(-1) unless task

days = File.readlines('/home/minhajuddin/.gtimelog/timelog.txt')[-140..-1]
days.map{|x| /(?<date>\d{4}-\d{2}-\d{2}) (?<hours>\d{2}:\d{2}): (?<task>.*$)/.match(x.chomp)}
.compact
.group_by{|x| x[:date]}
.each do |day, logs|
  total_hours = 0
  puts "\n==============\nLog for #{day}"
  logs.each_cons(2) do |l1, l2|
    next unless l2[:task] =~ /#{task}/i

    minutes = ( Time.parse("#{l2[:date]} #{l2[:hours]}") - Time.parse("#{l1[:date]} #{l1[:hours]}") )/60
    puts "#{l2[:task]}:  #{minutes}"
    total_hours += (minutes * 1.0 / 60)
  end
  puts "--------------\nTotal: #{total_hours}"
end
