module Wordpress::Preferences
    class ScopedCloudflare
      def initialize(prefix, suffix = nil)
        @prefix = prefix
        @suffix = suffix
      end
  
      def cloudflare
        Wordpress::Preferences::Cloudflare.instance
      end
  
      def fetch(key, &block)
        cloudflare.fetch(key_for(key), &block)
      end
  
      def []=(key, value)
        cloudflare[key_for(key)] = value
      end
  
      def delete(key)
        cloudflare.delete(key_for(key))
      end
  
      private
  
      def key_for(key)
        [rails_cache_id, @prefix, key, @suffix].compact.join('/')
      end
  
      def rails_cache_id
        ENV['RAILS_CACHE_ID']
      end
    end
  end