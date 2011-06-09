require 'mimemagic'

require 'lib-s3u/bucket_admin'
require 'lib-s3u/dir_util'

require 'RightHttpConnection/right_http_connection'
require 'RightAws/right_aws'

module Embbox
  
  class Upload
    
    def initialize(bucketName, keyId, key)
      @bucketAdmin = BucketAdmin.new(keyId, key)
      @bucketAdmin.defaultBucketName= bucketName
    end
    
    def setLogger(logger)
      @log = logger
      @logPrefix = 's3u-upload'
    end
    
    # recursively uplaod content of localDir.
    # Files can be excluded using a Allow and Deny Regexp filters.  If the
    # basename file (i.e. the filename without its path) matches the filter 
    # expression, that file will be excluded.
    def uploadDir(localDir, denyFilters = nil, allowFilters = nil)
      localDirWithSeparatorSuffix = File.expand_path(localDir) << File::SEPARATOR
      dirUtil = Embbox::DirUtil.new(@log)
      ignoredFiles = dirUtil.walk(localDir, denyFilters, allowFilters) do |file|
        remotePath = file.gsub(localDirWithSeparatorSuffix, '')
        # @log.debug(@logPrefix) {"  Include  : '#{remotePath}'"} 
        uploadFile(file, remotePath)
      end
      
      if (ignoredFiles.length > 0)
        ignoredFiles.each do |f|
          @log.info(@logPrefix) {"* EXCLUDE *: '#{f.gsub(localDirWithSeparatorSuffix, '')}'"} 
        end
      end
    end

    # uploads the content of localFilePath to destination file.
    def uploadFile(localFilePath, destFilePath)
      ext = File.extname(localFilePath).downcase
      infoContenType = ""
      if (ext == "")
        contentType = 'text/html'
        infoContenType = "No filename extension:"
      elsif (Fh5::Config.instance.contentTypes && Fh5::Config.instance.contentTypes.has_key?(ext))
        contentType = Fh5::Config.instance.contentTypes[ext]
        infoContenType = "Override for '#{ext}':"
      else 
        contentType = MimeMagic.by_path(destFilePath).type
      end
      @log.info(@logPrefix) {"Upload: '#{destFilePath}' (#{infoContenType}#{contentType})"}
      begin
        File.open(localFilePath) do |f|
          content = f.read
          @bucketAdmin.defaultBucket.put(destFilePath, content, {}, 'public-read', {'Content-Type' => contentType})
        end
      rescue
        @log.errorException($!, @logPrefix) {"Failed to upload to: '#{destFilePath}'"}
        return nil
      end
      
      # comment out stuff related to public links which doesn't seem to work for website bucket.
      # publicLink = @bucketAdmin.endpointBucket.key(destFilePath).public_link
      # @log.debug(@logPrefix) {"Public link: '#{publicLink}' for file: '#{destFilePath}'"}
      # return publicLink 
    end
    
  end
  
end
