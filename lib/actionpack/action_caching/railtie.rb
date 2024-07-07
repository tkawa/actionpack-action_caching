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
      end
    end
  end
end
