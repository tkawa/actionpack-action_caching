module ActionView
  module Helpers
    module CacheHelperWithSessionDisabled
      def cache(name = {}, options = {}, &block)
        if controller.respond_to?(:perform_caching) && controller.perform_caching
          ActionView::Helpers::CacheHelper::CachingRegistry.track_caching do
            name_options = options.slice(:skip_digest)
            _with_session_disabled(controller) do
              safe_concat(fragment_for(cache_fragment_name(name, **name_options), options, &block))
            end
          end
        else
          yield
        end

        nil
      end

      private def _with_session_disabled(controller)
        # ProtectionMethods::NullSession#handle_unverified_request を参考にした
        # https://github.com/rails/rails/blob/v7.2.1/actionpack/lib/action_controller/metal/request_forgery_protection.rb#L259
        # TODO: session, cookie にアクセスすると例外にすべきかもしれない
        request = controller.request
        original_session = request.session
        original_flash = request.flash
        original_session_options = request.session_options
        original_cookie_jar = request.cookie_jar
        request.session = ActionController::RequestForgeryProtection::ProtectionMethods::NullSession::NullSessionHash.new(request)
        request.flash = nil
        request.session_options = { skip: true }
        request.cookie_jar = ActionController::RequestForgeryProtection::ProtectionMethods::NullSession::NullCookieJar.build(request, {})
        yield
      ensure
        request.session = original_session
        request.flash = original_flash
        request.session_options = original_session_options
        request.cookie_jar = original_cookie_jar
      end
    end
  end
end
