require "action_controller/caching/actions"
require "action_controller/cacheable_request_forgery_protection"

module ActionController
  module Caching
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Actions
    end

    include Actions
  end
end

ActionController::Base.send(:include, ActionController::Caching::Actions)
ActionController::Base.send(:include, ActionController::CacheableRequestForgeryProtection)
