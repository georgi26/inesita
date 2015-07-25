module Inesita
  module Component
    include VirtualDOM

    def mount(element)
      @virtual_dom = render
      @mount_point = VirtualDOM.create(@virtual_dom)
      element.inner_dom = @mount_point
    end

    def update
      return unless @virtual_dom && @mount_point
      new_virtual_dom = render
      diff = VirtualDOM.diff(@virtual_dom, new_virtual_dom)
      VirtualDOM.patch(@mount_point, diff)
      @virtual_dom = new_virtual_dom
    end
  end
end
