#!/usr/bin/env ruby
require 'fileutils'

exit 1 if ARGV.empty?

dir = File.expand_path ARGV.first

files = `ls #{dir}/*.html`.lines.map &:chomp

files.each do |file|
  canonical = `grep canonical #{file}`
  canonical.match(/href="([^"]*)"/)
  url = $1.sub(%r{http://[^/]*},'').sub(%r{^/}, '').sub(%r{/$}, '')
  dir_name = File.dirname(url)
  filepath = url + '.html'
  `mkdir -p #{dir_name}`
  `mv #{file} #{filepath}`
end
