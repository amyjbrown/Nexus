local lg = love.graphics
local sprite = lg.newImage('Assets/Untitled.png')
local sprite2 = lg.newImage('Assets/Untitled2.png')
local TileViewSettings = require'Settings'.UI.TileView
local Widget = require'UI/Widget'

local TileView = setmetatable({}, {__index = Widget})
local private = setmetatable({}, {__mode = 'k'})
local tile_view_metatable = {__index = TileView}

local function rgb24_to_love_color(red, green, blue)
    return red / 255, green / 255, blue / 255, 1
end

function TileView.new()
    local result = setmetatable(Widget.new(), tile_view_metatable)

    private[result] = {
        x = 0,
        y = 0,
    }

    result:set_palette(
        {rgb24_to_love_color(243, 243, 243)},
        {rgb24_to_love_color(  0, 228,  54)},
        {rgb24_to_love_color(  0, 135,  81)},
        {rgb24_to_love_color( 95,  87,  79)}
    )

    return result
end

function TileView:go(delta_x, delta_y)
    local self_ = private[self]
    self_.x = self_.x + delta_x
    self_.y = self_.y + delta_y
end

function TileView:on_draw(x, y, width, height)
    local self_ = private[self]

    lg.scale(TileViewSettings.scale)

    local base_x, base_y = lg.inverseTransformPoint(
        width / 2,
        height / 2
    )

    local girl_x, girl_y = x + 12 * self_.x, y + 12 * self_.y

    lg.translate(
        math.floor(base_x - girl_x - 6),
        math.floor(base_y - girl_y - 6)
    )

    lg.draw(sprite, girl_x, girl_y)
    lg.draw(sprite2, x + 24, y + 36)
end

function TileView:on_key(key, ctrl)
    if not ctrl then
        if key == 'w' then
            self:go( 0, -1)
        elseif key == 'a' then
            self:go(-1,  0)
        elseif key == 's' then
            self:go( 0,  1)
        elseif key == 'd' then
            self:go( 1,  0)
        end
    end
end

function TileView:on_scroll(units, ctrl)
    if ctrl then
        -- Ctrl+Scroll: Zoom in/out
        TileViewSettings.scale =
            math.max(1, math.min(TileViewSettings.scale + units, 8))
    end
end

function TileView:on_text_input(text)
end

return TileView
