require "rails/railtie"

module ActionPack
  module ActionCaching
    class Railtie < Rails::Railtie
      initializer "action_pack.action_caching" do
        ActiveSupport.on_load(:action_controller) do
          require "action_controller/action_caching"
        end
        ActiveSupport.on_load(:action_view) do
          require "action_view/rendering_caching"
          ActionView::TemplateRenderer.send :prepend, ActionView::RenderingCaching
        end
        ActiveSupport.on_load(:after_initialize) do
          ActionDispatch::Routing::Mapper::Mapping.class_eval do
            def self.normalize_path(path, format)
              path = ActionDispatch::Routing::Mapper.normalize_path(path)

              if format == true
                "#{path}.:format"
              elsif optional_format_with_variant?(path, format)
                "#{path}(+:variant)(.:format)"
              elsif optional_format?(path, format)
                "#{path}(.:format)"
              else
                path
              end
            end

            def self.optional_format_with_variant?(path, format)
              format == :with_variant && optional_format?(path, format)
            end
          end
          ActionDispatch::Routing::Mapper::Mapping::JOINED_SEPARATORS << '+'
        end
      end
    end
  end
end
