module Wordpress
  class Proxy < Wordpress::Base
    acts_as_paranoid 
    CONNECTION_TYPES = %W( SSH SFTP FTP )

  end
end
