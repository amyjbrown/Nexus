-- # Modules

local lg = love.graphics
local Font = require'Font'
local TextBuffer = require'TextBuffer'

-- # State

local buffer
local font
local shader

-- # Helpers

local function rgb24_to_love_color(red, green, blue)
    return red / 255, green / 255, blue / 255, 1
end

-- # Callbacks

function love.load()
    lg.setDefaultFilter('nearest', 'nearest')
    buffer = TextBuffer.new()
    font = Font.new(require'Assets/Font')
    shader = lg.newShader'palette_swap.glsl'

    shader:sendColor('palette',
        {rgb24_to_love_color(243, 243, 243)},
        {rgb24_to_love_color(  0, 228,  54)},
        {rgb24_to_love_color(  0, 135,  81)},
        {rgb24_to_love_color( 95,  87,  79)}
    )

    lg.setShader(shader)
end

function love.keypressed(key)
    if key == 'backspace' then
        buffer:backspace()
    end
end

function love.textinput(text)
    buffer:append(text)
end

function love.draw()
    lg.push'all'
    lg.setColor(0, 0, 0, 0)
    lg.rectangle('fill', 0, 0, lg.getDimensions())
    lg.setColor(1, 1, 1)
    lg.scale(8)
    font:print('type here: ' .. buffer:read())
    lg.pop()
end
