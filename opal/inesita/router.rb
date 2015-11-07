module Inesita
  module Router
    include Inesita::Component

    attr_reader :params

    def initialize
      @routes = Routes.new
      @url_params = parse_url_params
      fail Error, 'Add #routes method to router!' unless respond_to?(:routes)
      routes
      fail Error, 'Add #route to your #routes method!' if @routes.routes.empty?
      add_js_listeners
    end

    def add_js_listeners
      JS.global.JS[:onpopstate] = -> { update_dom }
      JS.global.JS.addEventListener(:haschange, method(:update_dom))
    end

    def route(*params, &block)
      @routes.route(*params, &block)
    end

    def find_component
      @routes.routes.each do |route|
        params = path.match(route[:regex])
        next unless params
        @params = @url_params.merge(Hash[route[:params].zip(params[1..-1])])
        @component_props = route[:component_props]
        return route[:component]
      end
      fail Error, "Can't find route for url"
    end

    def render
      component find_component, props: @component_props
    end

    def handle_link(path)
      JS.global.JS[:history].JS.pushState({}, nil, path)
      update_dom
      false
    end

    def parse_url_params
      params = {}
      url_query = JS.global.JS[:location].JS[:search]
      url_query[1..-1].split('&').each do |param|
        key, value = param.split('=')
        params[JS.decodeURIComponent(key)] = JS.decodeURIComponent(value)
      end unless url_query.length == 0
      params
    end

    def url_for(name)
      route = case name
              when String
                @routes.routes.find { |r| r[:name] == name }
              when Object
                @routes.routes.find { |r| r[:component] == name }
              end
      route ? route[:path] : fail(Error, "Route '#{name}' not found.")
    end

    def path
      JS.global.JS[:document].JS[:location].JS[:pathname]
    end

    def current_url?(name)
      path == url_for(name)
    end
  end
end
