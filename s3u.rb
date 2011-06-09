#!/usr/bin/ruby

RIGH_HTTP_CONNECTION_DIR = 'external_libs/right_http_connection'
RIGHT_AWS_DIR = 'external_libs/right_aws'
MIMEMAGIC_DIR = 'external_libs/mimemagic/lib'

APPLICATION_DIR = File::expand_path(File::dirname(File::expand_path(__FILE__)))
# puts "APPLICATION_DIR: " + APPLICATION_DIR
$:.push(APPLICATION_DIR)
$:.push("#{APPLICATION_DIR}/#{RIGH_HTTP_CONNECTION_DIR}")
$:.push("#{APPLICATION_DIR}/#{RIGHT_AWS_DIR}")
$:.push("#{APPLICATION_DIR}/#{MIMEMAGIC_DIR}")

require 'rubygems'
require 'find'

require 'lib-s3u/config'
require 'lib-s3u/logger'
require 'lib-s3u/upload'
require 's3uinfo'
require 's3u_version'

# S3u provides the command line interface to all s3u operations.

module Embbox
  
  S3U_CONFIG_FILENAME = '.s3u'

  class S3u
    
    def initialize(sourceDir)
      @log = Fh5::Logger.new(STDERR)
      @log.level=(Logger::INFO)
      @logPrefix = 's3u'
      @sourceDir = File.expand_path(sourceDir.strip)
      @log.debug(@logPrefix) {"Using source dir: '#{@sourceDir}'"}
      if (!File.directory?(@sourceDir))
        $stdout.puts "Directory doesn't exist: '#{@sourceDir}'"
        exit 1
      end
      readConfig(@sourceDir)
    end
    
    def debug=(bool)
      if (bool)
        @log.level=(Logger::DEBUG)
      else
        @log.level=(Logger::INFO)
      end
      
    end
    
    def readConfig(dir)
      dir = File.expand_path(dir)
      file = "#{dir}/#{S3U_CONFIG_FILENAME}"
      if (!File.file?(file))
        $stderr.puts {"No config file."}
      else
        Fh5::Config.instance.read(file)
      end
    end
    
    def upload(bucket)
      # (Fh5::Config.instance.keyId, Fh5::Config.instance.key)
      upload = Embbox::Upload.new(bucket, Fh5::Config.instance.keyId, Fh5::Config.instance.key)
      upload.setLogger(@log)
      upload.uploadDir(@sourceDir, Fh5::Config.instance.denyFiltersRegEx, Fh5::Config.instance.allowFiltersRegEx)
    end

    def list(bucket)
      puts "List #{bucket}"
      puts "Not yet implemented."
    end
    
  end
end


if __FILE__ == $0
  require 'optparse'
  require 'lib-s3u/logger'
  
  bucket = nil
  action = nil
  source = nil
  keyId = nil
  key = nil
  debug = nil

  ACTION_LIST = 0
  ACTION_UPLOAD = 1
  
# Specify command line options
  Optparser = OptionParser.new do |opts|
    opts.banner = "s3u.rb is the command line interface to all s3u operations.\nUsage: ruby s3u.rb [options]\nIt exits with a value of 0 on success."
    
    opts.on('-l', '--list', 'List the website as a tree.') do
      action = ACTION_LIST
    end

    opts.on('-b', '--bucket bucket', 'The name of the S3 bucket.') do |ep|
      bucket = ep.strip
    end
    
    opts.on('-d', '--dir dir', 'Directory to work on; if not specified uses pwd.') do |dir|
      source = dir
    end
    
    opts.on('-u', '--upload', 'Upload dir contents to the bucket.') do |dir|
      action = ACTION_UPLOAD
    end
    
    opts.on('-c', '--config-info', 'Information about the config file and exit.') do
      include Embbox::Config
        puts CONFIG_FILE_INFO
      exit
    end

    opts.on('-k', '--key-id id', 'S3 Key ID.') do |k|
      keyId = k
    end

    opts.on('--debug', 'Include debug info in output.') do
      debug = true
    end

    opts.on('-K', '--key key', 'S3 Key.') do |k|
      key = k
    end

    opts.on('--version', 'Print version and exit.') do
      include Embbox
      puts "s3u version #{Embbox::S3U_VERSION}"
      exit
    end

  end
  
  # Exits with a messaeg if switch doesn't exist.
  def checkForSwitch(switch, switchName) 
    if (switch == nil)
      $stdout.puts "ERR: '#{switchName}' should be specified"
      puts Optparser
      exit 1
    end
  end

  Optparser.parse!
  
  # s3u is tied down to the source directory specified. 
  source = File.expand_path('.') if (!source)
  s3u = Embbox::S3u.new(source)
  s3u.debug=(true) if (debug)

  # Few options missing on the command line are read form the config.
  bucket = Fh5::Config.instance.bucket if (!bucket)
  
  #Few options needed by the config are read on the command line.
  Fh5::Config.instance.add('keyId', keyId) if (keyId)
  Fh5::Config.instance.add('key', key) if (key)
  
  checkForSwitch(action, '-l or -u')
  checkForSwitch(bucket, 'bucket')
  
#   Perform action
  if (action == ACTION_LIST)
    s3u.list(bucket)
  elsif (action == ACTION_UPLOAD)
    s3u.upload(bucket)
  end
  
  
end
