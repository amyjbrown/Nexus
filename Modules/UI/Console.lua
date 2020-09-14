local lg = love.graphics
local Font = require'Font'
local TextBuffer = require'TextBuffer'
local Widget = require'UI/Widget'

local Console = setmetatable({}, {__index = Widget})
local private = setmetatable({}, {__mode = 'k'})
local console_metatable = {__index = Console}

local function run_lua_code(code)
    -- Use a separate thread so we don't crash the main thread.
    local thread = love.thread.newThread(code .. '\n')
    thread:start()
    thread:wait()
end

function Console.new(prompt_string)
    local result = setmetatable({}, console_metatable)

    private[result] = {
        prompt_string = prompt_string,
        buffer = TextBuffer.new(),
        scale = 4,
        font = Font.new(require'Assets/Carpincho Mono'),
    }

    return result
end

function Console:on_draw(x, y, width, height)
    local self_ = private[self]

    -- Draw the widget's background.
    lg.setColor(0, 0, 0, 0)
    lg.rectangle('fill', x, y, width, height)
    lg.setColor(1, 1, 1)

    -- Use the widget's own scale.
    lg.scale(self_.scale)

    -- Show the prompt.
    self_.font:print(self_.prompt_string .. self_.buffer:read())
end

function Console:on_key(key, ctrl)
    local buffer = private[self].buffer

    if ctrl then
        if key == 'v' then
            -- Ctrl+V: Paste
            buffer:append(love.system.getClipboardText())
        elseif key == 'return' then
            -- Ctrl+Return: Insert newline
            buffer:append'\n'
        end
    else
        if key == 'backspace' then
            -- Backspace: Delete last character
            buffer:backspace()
        elseif key == 'return' then
            -- Return: Run command
            run_lua_code(buffer:read())
            buffer:clear()
        end
    end
end

function Console:on_scroll(units, ctrl)
    if ctrl then
        -- Ctrl+Scroll: Zoom in/out
        local self_ = private[self]
        self_.scale = math.max(1, math.min(self_.scale + units, 8))
    end
end

function Console:on_text_input(text)
    private[self].buffer:append(text)
end

return Console