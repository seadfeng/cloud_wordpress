require "core/railtie"

module Amz
  ROOT_PATH = Pathname.new(File.join(__dir__, "../../"))
  mattr_accessor :user_class

  def self.user_class(constantize: true)
    if @@user_class.is_a?(Class)
      raise 'Amz.user_class MUST be a String or Symbol object, not a Class object.'
    elsif @@user_class.is_a?(String) || @@user_class.is_a?(Symbol)
      constantize ? @@user_class.to_s.constantize : @@user_class.to_s
    end
  end

  # Used to configure Amz.
  #
  # Example:
  #
  #   Amz.configure do |config|
  #     config.track_inventory_levels = false
  #   end
  #
  # This method is defined within the core gem on purpose.
  # Some people may only wish to use the Core part of Amz.
  def self.configure
    yield(Amz::Config)
  end
  
  def self.config
    yield(Amz::Config) 
  end

  # Used to set dependencies for Amz.
  #
  # Example:
  #
  #   Amz.dependencies do |dependency|
  #     dependency.cart_add_item_service = MyCustomAddToCart
  #   end
  #
  # This method is defined within the core gem on purpose.
  # Some people may only wish to use the Core part of Amz.
  def self.dependencies
    yield(Amz::Dependencies)
  end   

  module Core
    autoload :TokenGenerator, 'amz/core/token_generator'
  end

end
