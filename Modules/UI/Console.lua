local lg = love.graphics
local Font = require'Font'
local TextBuffer = require'TextBuffer'
local Widget = require'UI/Widget'

local Console = setmetatable({}, {__index = Widget})
local private = setmetatable({}, {__mode = 'k'})
local console_metatable = {__index = Console}

function Console.new(prompt_string)
    local result = setmetatable({}, console_metatable)

    private[result] = {
        environment = setmetatable({
            print = function (...)
                return result:print(true, ...)
            end,
        }, {__index = _G}),

        prompt_string = prompt_string,
        scrollback = TextBuffer.new(),
        input_buffer = TextBuffer.new(),
        scale = 1,
        font = Font.new(require'Assets/Carpincho Mono'),
    }

    result:print(false, prompt_string)
    return result
end

function Console:print(with_final_line_break, ...)
    local self_ = private[self]
    local arguments = {...}

    for index = 1, select('#', ...) do
        self_.scrollback:append(tostring(arguments[index]) .. '\n')
    end

    if not with_final_line_break then
        self_.scrollback:backspace()
    end
end

function Console:on_draw(x, y, width, height)
    local self_ = private[self]

    -- Use the widget's own scale.
    lg.scale(self_.scale)

    -- Display the actual text of the console.
    self_.font:print(self_.scrollback:read() .. self_.input_buffer:read())
end

function Console:on_key(key, ctrl)
    local self_ = private[self]
    local input_buffer = self_.input_buffer

    if ctrl then
        if key == 'v' then
            -- Ctrl+V: Paste
            input_buffer:append(love.system.getClipboardText())
        elseif key == 'return' then
            -- Ctrl+Return: Insert newline
            input_buffer:append'\n'
        end
    else
        if key == 'backspace' then
            -- Backspace: Delete last character
            input_buffer:backspace()
        elseif key == 'return' then
            -- Return: Run command
            local input = input_buffer:read()
            self:print(true, input)

            local chunk, load_error_message = load(input_buffer:read(), 'player input', 't', self_.environment)

            if chunk == nil then
                chunk, load_error_message = load('return ' .. input_buffer:read(), 'player input', 't', self_.environment)
            end

            if chunk == nil then
                self:print(true, load_error_message)
            else
                local function handle_result(_, ...)
                    self:print(true, ...)
                end

                handle_result(pcall(chunk))
            end

            input_buffer:clear()
            self:print(false, self_.prompt_string)
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
    private[self].input_buffer:append(text)
end

return Console
