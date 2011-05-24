require 'yaml'
require 'singleton'

module Fh5
  
  class Config
    
    include Singleton
    
    def initialize
      @vals = {}
    end
    
    def read(file)
      puts "Reading config: '#{file}'"
      @yamlConfig = YAML::load(File.open(file))
    end
    
    def add(name, value)
      @vals[name] = value
    end
    
    def method_missing(method, *args)
      # If a method is missing, try to retrieve it as value from the config file
      method_name = method.to_s.strip
      
      # @vals hash gets precedence over config file
      return @vals[method_name] if (@vals[method_name])
      
      if (!@yamlConfig)
        $stderr.puts "WARNING: 'Config not found." 
        return nil  
      end
      return @yamlConfig[method_name] if (@yamlConfig.has_key?(method_name))

      $stderr.puts "WARNING: '#{method_name}' not found in config file." 
      return nil
    end
    
  end
  
end