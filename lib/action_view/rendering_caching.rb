module ActionView
  module RenderingCaching
    class MissingCacheKeyError < StandardError; end

    private

    def render_with_layout(view, template, path, locals)
      layout  = path && find_layout(path, locals.keys, [formats.first])

      body = if layout
        ActiveSupport::Notifications.instrument("render_layout.action_view", identifier: layout.identifier) do
          cache_rendering(view, template, layout) do
            view.view_flow.set(:layout, yield(layout))
            layout.render(view, locals) { |*name| view._layout_for(*name) }
          end
        end
      else
        yield
      end
      build_rendered_template(body, template)
    end

    def cache_rendering(view, template, layout = nil, &block)
      controller = view.controller
      rendering_cache_options = controller.instance_variable_get(:@_rendering_cache_options)
      if controller.respond_to?(:perform_caching) && controller.perform_caching && rendering_cache_options && rendering_cache_options[:enabled]
        key = rendering_cache_options.include?(:key) ? expand_key(controller, rendering_cache_options[:key]) : default_key(controller)
        raise MissingCacheKeyError, "The cache key cannot be nil." if key.nil?

        fragment_name = fragment_name_with_digest(key, view, template, layout)
        fragment_for(fragment_name, controller, &block)
      else
        yield
      end
    end

    def fragment_for(name, controller, options = nil)
      if content = controller.read_fragment(name, options)
        # @view_renderer.cache_hits[@current_template&.virtual_path] = :hit if defined?(@view_renderer)
        content
      else
        # @view_renderer.cache_hits[@current_template&.virtual_path] = :miss if defined?(@view_renderer)
        content = yield
        controller.write_fragment(name, content, options)
      end
    end

    def fragment_name_with_digest(name, view, template, layout)
      digest_path = view.digest_path_from_template(template)
      layout_path = view.digest_path_from_template(layout) if layout
      [ :rendering, digest_path, layout_path, name ].compact
    end

    def default_key(controller)
      name = controller.class.to_s.demodulize.delete_suffix("Controller").underscore
      name = controller.action_name == 'index' ? name.pluralize : name.singularize
      controller.instance_variable_get("@#{name}")
    end

    def expand_key(controller, key)
      key = key.to_proc if key.respond_to?(:to_proc)

      if key.is_a?(Proc)
        case key.arity
        when -2, -1, 1
          controller.instance_exec(controller, &key)
        when 0
          controller.instance_exec(&key)
        else
          raise ArgumentError, "Invalid proc arity of #{key.arity} - proc options should have an arity of 0 or 1"
        end
      elsif key.respond_to?(:call)
        key.call(controller)
      else
        key
      end
    end
  end
end
