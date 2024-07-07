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
        cache_key = rendering_cache_options.key?(:cache_key) ? expand_cache_key(controller, rendering_cache_options[:cache_key]) : default_cache_key(controller)
        raise MissingCacheKeyError, "The cache key cannot be nil." if cache_key.nil?

        fragment_name = fragment_name_with_digest(cache_key, view, template, layout)
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

    def default_cache_key(controller)
      name = controller.class.to_s.demodulize.delete_suffix("Controller").underscore
      name = controller.action_name == 'index' ? name.pluralize : name.singularize
      controller.instance_variable_get("@#{name}")
    end

    def expand_cache_key(controller, cache_key)
      cache_key = cache_key.to_proc if cache_key.respond_to?(:to_proc)

      if cache_key.is_a?(Proc)
        case cache_key.arity
        when -2, -1, 1
          controller.instance_exec(controller, &cache_key)
        when 0
          controller.instance_exec(&cache_key)
        else
          raise ArgumentError, "Invalid proc arity of #{cache_key.arity} - proc options should have an arity of 0 or 1"
        end
      elsif cache_key.respond_to?(:call)
        cache_key.call(controller)
      else
        cache_key
      end
    end
  end
end
