module ActionController
  module CacheableRequestForgeryProtection
    extend ActiveSupport::Concern

    module ClassMethods
      def protect_from_forgery_with_cache(options = {})
        options = options.reverse_merge(prepend: false)

        self.forgery_protection_strategy = protection_method_class(options[:with] || :null_session)
        # self.request_forgery_protection_token ||= :authenticity_token
        before_action :verify_request_headers, options
        # append_after_action :verify_same_origin_request
      end

    end

    private

      def verify_request_headers
        # mark_for_same_origin_verification!

        if !verified_request_cacheable?
          logger.warn unverified_request_warning_message_cacheable if logger && log_warning_on_csrf_failure

          handle_unverified_request
        end
      end

      def verified_request_cacheable?
        !protect_against_forgery? || request.get? || request.head? ||
          (valid_request_origin? && valid_request_fetch_metadata?)
      end

      def valid_request_fetch_metadata?
        request.headers.key?('Sec-Fetch-Site') && request.headers['Sec-Fetch-Site'] == 'same-origin'
      end

      def unverified_request_warning_message_cacheable
        if valid_request_origin?
          "HTTP Sec-Fetch-Site header (#{request.headers['Sec-Fetch-Site']}) didn't match 'same-origin'"
        else
          "HTTP Origin header (#{request.origin}) didn't match request.base_url (#{request.base_url})"
        end
      end
  end
end
