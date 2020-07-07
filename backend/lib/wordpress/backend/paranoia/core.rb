 
require 'wordpress/backend/paranoia/dsl'
require 'wordpress/backend/paranoia/authorization'
::ActiveAdmin::DSL.send(:include, Wordpress::Backend::Paranoia::DSL)