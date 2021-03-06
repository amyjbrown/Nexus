local Widget = require'UI/Widget'

local Container = augment(mix{Widget})

--# Interface

function Container:initialize(root_widget)
    Widget.initialize(self, nil)
    self.root_widget = root_widget
    self.widget_geometries = {}
    self.active_widget = nil
end

function Container:get_root_widget()
    return self.root_widget
end

function Container:set_root_widget(new_root_widget)
    self.root_widget = new_root_widget
end

function Container:has_widget(widget)
    return self.widget_geometries[widget] ~= nil
end

function Container:add_widget(widget, x, y, width, height)
    x = x or 0
    y = y or 0
    width = width or 0
    height = height or 0

    self.widget_geometries[widget] = {}
    self:set_widget_geometry(widget, x, y, width, height)
end

function Container:get_widget_geometry(widget)
    assert(self:has_widget(widget), 'widget not in container')
    local geometry = self.widget_geometries[widget]
    return geometry.x, geometry.y, geometry.width, geometry.height
end

function Container:set_widget_geometry(widget, x, y, width, height)
    assert(self:has_widget(widget), 'widget not in container')
    local geometry = self.widget_geometries[widget]
    local should_resize = false

    if x ~= nil then
        geometry.x = x
    end

    if y ~= nil then
        geometry.y = y
    end

    if width ~= nil then
        geometry.width = width
        should_resize = true
    end

    if height ~= nil then
        geometry.height = height
        should_resize = true
    end

    if should_resize then
        widget:resize(width, height)
    end
end

function Container:place_widget(widget, x, y)
    self:set_widget_geometry(widget, x, y, nil, nil)
end

function Container:resize_widget(widget, width, height)
    self:set_widget_geometry(widget, nil, nil, width, height)
end

function Container:get_active_widget()
    return self.active_widget
end

function Container:set_active_widget(widget)
    assert(widget == nil or self:has_widget(widget), 'widget not in container')
    self.active_widget = widget
end

function Container:remove_widget(widget)
    assert(self:has_widget(widget), 'widget not in container')
    self.widget_geometries[widget] = nil
end

--## Widget Methods

function Container:draw()
    love.graphics.push'all'
    love.graphics.setCanvas(self.canvas)

    if self.root_widget ~= nil then
        self.root_widget:draw()
        love.graphics.draw(self.root_widget:get_canvas(), 0, 0)
    end

    for widget, geometry in pairs(self.widget_geometries) do
        widget:draw()
        love.graphics.draw(widget:get_canvas(), geometry.x, geometry.y)
    end

    love.graphics.pop()
end

function Container:on_key(...)
    local widget = self:get_active_widget() or self.root_widget

    if widget ~= nil then
        return widget:on_key(...)
    end
end

function Container:on_press(...)
    local widget = self:get_active_widget() or self.root_widget

    if widget ~= nil then
        return widget:on_press(...)
    end
end

function Container:on_scroll(...)
    local widget = self:get_active_widget() or self.root_widget

    if widget ~= nil then
        return widget:on_scroll(...)
    end
end

function Container:on_text_input(...)
    local widget = self:get_active_widget() or self.root_widget

    if widget ~= nil then
        return widget:on_text_input(...)
    end
end

function Container:resize(...)
    if self.root_widget ~= nil then
        self.root_widget:resize(...)
    end

    return Widget.resize(self)
end

function Container:tick(...)
    for widget, _ in pairs(self.widget_geometries) do
        widget:tick(...)
    end

    if self.root_widget ~= nil then
        return self.root_widget:tick(...)
    end
end

--#

return Container
