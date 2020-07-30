module Wordpress
  class Monitor < Wordpress::Base
    include Wordpress::Monitor::StateMachine 
    belongs_to :blog  

  end
end
