-- Use nearest neighbor scaling in order to preserve pixel fidelity.
love.graphics.setDefaultFilter('nearest', 'nearest')

-- # Modules

-- Look for modules in the Modules directory.
package.path = './Modules/?.lua;' .. package.path

local lg = love.graphics
local lk = love.keyboard
local Serialization = require'Serialization'
local UI = require'UI'

-- # State

local main_widget
local shader

-- # Helpers

local function is_ctrl_down()
    return lk.isDown'lctrl' or lk.isDown'rctrl'
end

local function rgb24_to_love_color(red, green, blue)
    return red / 255, green / 255, blue / 255, 1
end

-- # Callbacks

function love.load()
    lk.setKeyRepeat(true)

    main_widget = UI.Overlay.new(UI.TileView.new(), UI.Console.new'> ')

    -- Set up the palette swap pixel shader.

    shader = lg.newShader'palette_swap.glsl'

    -- Tell the shader which colors to swap in.
    shader:sendColor('palette',
        -- For now, these are just some sample PICO-8 colors.
        {rgb24_to_love_color(243, 243, 243)},
        {rgb24_to_love_color(  0, 228,  54)},
        {rgb24_to_love_color(  0, 135,  81)},
        {rgb24_to_love_color( 95,  87,  79)}
    )

    lg.setShader(shader)
end

function love.keypressed(key)
    main_widget:on_key(key, is_ctrl_down())
end

function love.wheelmoved(_, y)
    main_widget:on_scroll(y, is_ctrl_down())
end

function love.textinput(text)
    main_widget:on_text_input(text)
end

function love.draw()
    main_widget:draw(0, 0, lg.getDimensions())
end

function love.threaderror()
    -- Swallow thread errors; if we care about them, we will ask for them.
end

function love.quit()
    love.filesystem.write('Widget Settings.lua',
        Serialization.to_lua_module(UI.Widget.settings)
    )
end
