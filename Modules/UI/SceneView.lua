local SceneView = {}

--# Requires

local Color = require'Color'
local Scalable = require'UI/Scalable'
local Widget = require'UI/Widget'

--# Constants

local COLOR_SCHEME = require'ColorScheme':new(
    Color:new(315,  15,  90),

    {
        Color:new(285,  30,  80),
        Color:new(255,  45,  70),
        Color:new(240,  60,  60),
    },

    {
        Color:new(180,  15,  90),
        Color:new(210,  45,  70),
        Color:new(240,  75,  50),
    }
)

local IDENTITY_TRANSFORM = love.math.newTransform()

--# State

local sprite = love.graphics.newImage'Assets/Untitled.png'
local sprite2 = love.graphics.newImage'Assets/Untitled2.png'

--# Interface

function SceneView:initialize(session, player_sprite)
    Widget.initialize(self, COLOR_SCHEME)
    Scalable.initialize(self, require'Settings'.UI.SceneView)
    self.entities_canvas = love.graphics.newCanvas()
    self.session = session
    self.keys_down = {}
    self.player_sprite = player_sprite
    self.transform = love.math.newTransform()
end

function SceneView:get_scene()
    return self.session:get_scene()
end

function SceneView:before_drawing()
    Widget.before_drawing(self)
    self.transform:reset()
    local width, height = self:get_dimensions()
    local player_x, player_y = self:get_scene():get_entity_position(self.session:get_player_id())
    local player_sx, player_sy = player_x, player_y
    self.transform:scale(self:get_scale())
    local base_x, base_y = self.transform:inverseTransformPoint(width / 2, height / 2)

    self.transform:translate(
        math.floor(base_x - player_sx - 6),
        math.floor(base_y - player_sy - 6)
    )
end

function SceneView:draw_background()
    Widget.draw_background(self)
    love.graphics.replaceTransform(self.transform)
    love.graphics.draw(self:get_scene():get_chunk(0, 0))
end

function SceneView:draw_foreground()
    love.graphics.replaceTransform(self.transform)

    self.entities_canvas:renderTo(function ()
        love.graphics.push'all'
        love.graphics.clear()
        love.graphics.setShader()
        love.graphics.setBlendMode'replace'
        love.graphics.draw(sprite2, 24, 36)
        love.graphics.draw(self.player_sprite, self:get_scene():get_entity_position(1))
        love.graphics.pop()
    end)

    love.graphics.replaceTransform(IDENTITY_TRANSFORM)
    love.graphics.draw(self.entities_canvas)
end

function SceneView:on_unbound_key(key, down)
    self.keys_down[key] = down or nil
end

function SceneView:resize(...)
    Widget.resize(self, ...)
    self.entities_canvas = love.graphics.newCanvas(...)
end

function SceneView:tick()
    local delta_x, delta_y = 0, 0

    if self.keys_down['w'] then
        delta_y = delta_y - 1
    end

    if self.keys_down['a'] then
        delta_x = delta_x - 1
    end

    if self.keys_down['s'] then
        delta_y = delta_y + 1
    end

    if self.keys_down['d'] then
        delta_x = delta_x + 1
    end

    self:get_scene():move_entity(self.session:get_player_id(), delta_x, delta_y)
end

return augment(mix{Widget, Scalable, SceneView})
