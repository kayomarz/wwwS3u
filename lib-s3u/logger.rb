require 'logger'

module Fh5

  # TODO: Use the logger provided in the standard ruby library
  class Logger < Logger 
    
    attr_reader :text
    
    def initialize(logdev)
      super(logdev)
      @level = Logger::DEBUG
      @text = ""
      @formatter = proc { |severity, datetime, progname, msg|
        datetime.utc
        millisecsStr = "%03d" % (datetime.usec / 1000.0).round
        "#{datetime.strftime('%Y-%m-%dT%H:%M:%S')}.#{millisecsStr}Z|#{severity}|#{progname}|#{msg}\n"
      }

    end
    
    
    def errorException(exception, progname = nil, &block)
      error("#{progname}:Exception", &block)
      backTraceString = exception.backtrace.join("\n")
      debug(progname) {"#{exception.inspect}\n#{exception.message}\nBacktrace:\n#{backTraceString}"}
    end
    
  end
end