require 'devise'
require 'devise-encryptable'
Devise.secret_key = SecureRandom.hex(50)

module Wordpress
  module Auth
    mattr_accessor :default_secret_key

    def self.config
      yield(Wordpress::Auth::Config)
    end

  end
end

Wordpress::Auth.default_secret_key = Devise.secret_key
