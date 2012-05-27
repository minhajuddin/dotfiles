if defined?(ActiveRecord)
  def log_to_console
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActionController::Base.logger = Logger.new(STDOUT)
  end
end


class Object
  # Return only the methods not present on basic objects
  def interesting_methods(pattern=nil)
    cool_methods = (self.methods - Object.new.methods).sort
    if pattern
      pattern = Regexp.new(pattern, "i") if pattern.is_a?(String)
      cool_methods.find_all{|x| x.to_s =~ pattern}
    else
      cool_methods
    end
  end
end
