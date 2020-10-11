local SpriteEditor = {}

--# Requires

local Widget = require'UI/Widget'

--# Constants

local SPRITE_WIDTH = 12
local SPRITE_HEIGHT = 12

--# Helpers

local function color_tuple_from_palette_index(palette_index)
    if palette_index == 0 then
        return 0  , 0  , 0  , 0
    elseif palette_index == 1 then
        return 0  , 0  , 0  , 1
    elseif palette_index == 2 then
        return 0.5, 0.5, 0.5, 1
    elseif palette_index == 3 then
        return 1  , 1  , 1  , 1
    else
        error(('palette index %q out of range'):format(palette_index))
    end
end

--# Interface

function SpriteEditor:initialize(love_image_data, love_image)
    Widget.initialize(self)
    self.active_color = 1
    self.love_image_data = love_image_data
    self.love_image = love_image

    if self.love_image_data == nil then
        self.love_image_data = love.image.newImageData(12, 12)
    end

    if self.love_image == nil then
        self.love_image = love.graphics.newImage(self.love_image_data)
    end

    self:compile_image()

    self:set_palette(
        {0, 0, 0, 1},
        {0.1, 0.1, 0.1, 1},
        {0.3, 0.3, 0.3, 1},
        {0.6, 0.6, 0.6, 1}
    )
end

function SpriteEditor:compile_image()
    self.love_image:replacePixels(self.love_image_data)
end

function SpriteEditor:draw_widget()
    local x, y, width, height = self:get_geometry()

    for x = 0, SPRITE_WIDTH - 1 do
        for y = 0, SPRITE_HEIGHT - 1 do
            local x_increment = width / SPRITE_WIDTH
            local y_increment = height / SPRITE_HEIGHT
            love.graphics.setColor(self.love_image_data:getPixel(x, y))

            love.graphics.rectangle('fill',
                x * x_increment + 1, y * y_increment + 1,
                x_increment - 2, y_increment - 2
            )
        end
    end
end

function SpriteEditor:on_press(press_x, press_y)
    local _, _, width, height = self:get_geometry()
    local x_increment = width / SPRITE_WIDTH
    local y_increment = height / SPRITE_HEIGHT
    local pixel_x = math.floor(press_x / x_increment)
    local pixel_y = math.floor(press_y / y_increment)

    self.love_image_data:setPixel(pixel_x, pixel_y,
        color_tuple_from_palette_index(self.active_color))

    self:compile_image()
end

return augment(mix{Widget, SpriteEditor})
