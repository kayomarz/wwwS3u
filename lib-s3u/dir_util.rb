module Embbox
  class DirUtil
    
    def initialize(log = nil)
      @log = log
      @logPrefix = "DirUtil"
    end
    
    # Recursive directory walk, calling block for each file 
    # which passes throgh the filters
    # Deny filters take precedence over Allow filters
    def walk(dir, denyFilters = nil, allowFilters = nil)
      verifyConfigFilename
      ignoreList = []
      Find.find(dir) do |file|
        if File.file?(file)
          fileNameWithoutPath = File.basename(file)

          # ignore filenames which start with the config filename        
          if (fileNameWithoutPath.upcase.start_with?(S3U_CONFIG_FILENAME.upcase))
            @log.debug(@logPrefix) {"Ignore #{fileNameWithoutPath} due to .s3u filter"} if (@log)
            ignoreList.push file
          elsif (filter = match?(fileNameWithoutPath, denyFilters))
            @log.debug(@logPrefix) {"Ignore #{fileNameWithoutPath} due to deny filter: #{filter.to_s}"} if (@log)
            ignoreList.push file
          elsif (filter = match?(fileNameWithoutPath, allowFilters))
            @log.debug(@logPrefix) {"Pass #{fileNameWithoutPath} due to allow filter: #{filter.to_s}"} if (@log)
            yield file
          else
            @log.debug(@logPrefix) {"Ignore #{fileNameWithoutPath} due to no rule"} if (@log)
            ignoreList.push file
          end
          
        end
      end
      ignoreList
    end
    

    def verifyConfigFilename
      # The s3u config file may contain sensitive information such as 
      # the S3 key and key id.
      # Hence the config file should not be uploaded to server
      # If the name of the config file is not found or is empty 
      # bail out because something is wrong.
      if (S3U_CONFIG_FILENAME)
        if (S3U_CONFIG_FILENAME.strip.length == 0)
          $stderr.puts "Config filename not found"
          exit 1
        end
      else
        $stderr.puts "Config filename not found"
        exit 1
      end
    end

    def match?(filename, filterList)
      return false if (!filterList)
      filterList.each do |filter|
        return filter if ((filename =~ filter) != nil)
      end
      return false
    end
    
  end
end