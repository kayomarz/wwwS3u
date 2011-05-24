wwwS3Upload (abbreviated as 's3u' for simplicity) is a utility to upload a static website to Amazon S3


SYSTEM REQUIREMENTS
==================

'wwwS3Upload' was developed using ruby 1.8.7. It has not been used with any other version of ruby.


INSTALLATION
============

There is no installation script.  Save the top-level directory (wwwS3Upload) to any location on disk, for example to ~/local.

Thereafter, s3u can be run as follows:
  $ ruby ~/local/wwwS3Upload/s3u.rb

For convenience you can use either one of the following:
 + Symbolic link (For this to work ~/bin should be in your PATH)
   $ ln -s ~/local/wwwS3Upload/s3u.rb ~/bin/s3u
 + OR create an alias:
   $ alias s3u="ruby ~/local/wwwS3Upload/s3u.rb"

Now you can just run s3u as:
  $ s3u


Quick Start Usage
==================

To upload the contents of a local directory named '~/public' to a bucket named foo.bucket

1) Create the config file
   $ s3u -c > ~/public/.s3u

2) Upload the contents to the bucket
   $ s3u -u -d ~/public -b foo.bucket --key-id <key-id> --key <key>

If the s3u command is run from the directory whoose content is to be uploaded. i.e. if you were run the above command when the pwd is ~/public then you can exclude the -d ~/public switch and the command will just be:

   $ s3u -u -b foo.bucket --key-id <key-id> --key <key>

You can also place bucket and key info within the config file (Read the info output by the cmd 's3u -c') in which case the -b, --key-id and --key switches can be excluded and the command will just be:

   $ s3u -u

That's it.

s3u doesn't upload all files in the local directory but uses filters (see detail usage).


Detail usage:
=============

For details about command line options do:
$ s3u --help

s3u requires a configuration file named '.s3u' to be present in the directory which needs to be uploaded as the static website.  If you are hosting more than one static site on S3, each will have its own local config file - '.s3u'

Amazon keys:
The amazon key and key id which is sensitive information may be stored in your configuration file if you can maintain its security.  Alternatively, if you feel this is a security risk, the key and key id can be given as command line parameters.

Filters:
s3u doesn't upload all files present in your local directory to the bucket.  You can control which files are uploaded based on their filenames using Allow / Deny Filters.
Allow/Deny filters are explained within the basic conifguration file which you can dump onto your screen using the -c flag.

$ s3u -c

...

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
        !ruby/regexp /^./    # names which begin with a period '.'
        ]

allowFiltersRegEx: [ 
         # Commonly used file extensions
         !ruby/regexp /.*.htm(l)?$/i,  
         !ruby/regexp /.*.css$/i,
         !ruby/regexp /.*.jp(e)?g$/i,
         !ruby/regexp /.*.bmp$/i,
         !ruby/regexp /.*.gif$/i,
         !ruby/regexp /.*.png$/i, 
         !ruby/regexp /.*.ico$/i, 
         !ruby/regexp /.*.swf$/i,
         !ruby/regexp /.*.swc$/i
         ]

License
=======

Read LICENSE.txt


Author: Kayomarz Gazder, Embbox Solutions.
Twitter id: kayumarz
