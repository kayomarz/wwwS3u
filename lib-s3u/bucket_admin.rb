require 'RightHttpConnection/right_http_connection'
require 'RightAws/right_aws'

module Embbox

  class BucketAdmin
    attr_reader :s3
    
    def initialize(keyId, key)
      @s3 = RightAws::S3.new(keyId, key)
    end
      
    def defaultBucketName=(name)
      @defaultBucket = @s3.bucket(name)
      if (@defaultBucket == nil)
        $stderr.puts "ERR: Could not get bucket #{name}"
        exit 1
      end
    end

    def defaultBucket
      if (@defaultBucket != nil)
        return @defaultBucket
      else
        $stderr.puts 'ERR: Bucket not set'
        exit 1
      end
    end

  end
  
end
