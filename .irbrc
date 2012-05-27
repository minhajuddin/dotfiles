IRB.conf[:PROMPT_MODE] = :SIMPLE
IRB.conf[:AUTO_INDENT] = true
require '~/.irb/helpers'

unless defined?(Rails)
  require 'rubygems'
  require 'wirble'
  require 'ori'
  Wirble.init
  Wirble.colorize
end
