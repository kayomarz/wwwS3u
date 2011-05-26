module Embbox
  module Config
    
  CONFIG_FILE_INFO = <<EOF
# This configuration file uses YAML which follows strict indentation rules.
# Don't use tabs. For each indentation level, use a single space.
#
# * SECURITY INFO *  This file contains sensitive data such as your AWS S3 keys
# Hence you should ensure this file is not compromised.
# Ensure that it has correct file permissions ($ chmod 600 .s3u) and that no one
# else can read it.  If you are not comfortable with storing AWS key info in this
# file you may specify them as command line arguments.
# ********************************************************************************


# The bucketname
bucket: bucketname

# S3 Key and Key Id (Read * SECURITY INFO * above)
# Alternatively, they can be specified using command line arguments.
key:   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
keyId: XXXXXXXXXXXXXXXXXXXX

# Filter - allow / deny - file uploads based on filename.
# Filter algorithm:
# 1) If filename looks like the config file ('.s3u') it is denied.
#    See the note below for more about this.
# 2) Else If filename matches a Deny Filter, the file is denied.
# 3) Else If filename matches a Allow Filter, the file is allowed.
# 4) Else, file is denied.
#
# NOTE: If filename looks like the config file ('.s3u') it is denied.
#    If the filename begins with the config filename (as of now it is '.s3u'), 
#    the file is is denied irrespective of case. This means that filenames
#    such as .s3u, .s3ufoo, .S3U-bar, .s3U-some-long-filename get excluded.
#    This behaviour is hardcoded in the ruby scripts and the only way to alter
#    this is to edit file dir_util.rb.  This is done to prevent the config file
#    (which may contain sensitive information) from being uploaded by mistake.

denyFiltersRegEx: [ 
        !ruby/regexp /^\./    # Begin with a period ('.')
        ]

allowFiltersRegEx: [ 
         # Commonly used file extensions
         !ruby/regexp /.*.htm(l)?$/i,  
         !ruby/regexp /.*.js$/i,
         !ruby/regexp /.*.css$/i,
         !ruby/regexp /.*.jp(e)?g$/i,
         !ruby/regexp /.*.bmp$/i,
         !ruby/regexp /.*.gif$/i,
         !ruby/regexp /.*.png$/i, 
         !ruby/regexp /.*.ico$/i, 
#         !ruby/regexp /.*.pdf$/i,
#         !ruby/regexp "/(^[^\.]+$)/",  # Does not contain a period ('.')  
         !ruby/regexp /.*.swf$/i,
         !ruby/regexp /.*.swc$/i
         ]
EOF
  end
end



if __FILE__ == $0
  include Embbox::Config
  puts CONFIG_FILE_INFO
end
