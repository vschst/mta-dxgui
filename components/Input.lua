Input = {}

local Layout = ComponentLayout.input
local pasteEdit

local function loadLayout(data)
    if type(data) ~= "table" then
        data = {}
    end

    local layout = {
        bgColor = {},
        text = {
            color = {}
        }
    }
    --  bg color
    local bgColor = data.bgColor or {}
    layout.bgColor.default = bgColor.default or Layout.bgColor.default
    layout.bgColor.active = bgColor.active or Layout.bgColor.active
    layout.bgColor.hover = bgColor.hover or Layout.bgColor.hover
    layout.bgColor.invalid = bgColor.invalid or Layout.bgColor.invalid

    --  text color
    local textColor = data.textColor or {}
    layout.text.color.default = textColor.default or Layout.text.color.default
    layout.text.color.placeholder = textColor.placeholder or Layout.text.color.placeholder

    return layout
end

function Input.create(properties)
    if type(properties) ~= "table" then
        properties = {}
    end

    local component = inherit(Component.create(properties), Input)
    component._type = "ui-input"
    component.value = properties.value or ""
    component.font = properties.font or Fonts.defaultSmall
    component.fontScale = properties.fontScale or 1.0
    component.placeholder = properties.placeholder or ""
    component.masked = properties.masked or false
    component.readOnly = false
    component.maxLength = nil
    component.active = false
    component.invalid = false
    component.layout = loadLayout(properties.layout)
    component.caret = {
        pos = utf8.len(component.value),
        held = false,
        tick = nil,
        direction = nil
    }
    component.backspaceHeld = false
    component.backspaceTick = nil
    component.charEvent = function(char) component:onChar(char) end

    return component
end

function Input:draw()
    --  set bg color
    local bgColor
    if self.active then
        bgColor = self.layout.bgColor.active
    elseif self.mouseOver then
        bgColor = self.layout.bgColor.hover
    else
        bgColor = self.layout.bgColor.default
    end

    -- draw background
    if self.invalid then
        Drawing.setColor(self.layout.bgColor.invalid)
        local invalidBorderX, invalidBorderY = 2 * self.scale.x, 2 * self.scale.y
        Drawing.rectangle(
            self.x - invalidBorderX,
            self.y - invalidBorderY,
            self.width + 2 * invalidBorderX,
            self.height + 2 * invalidBorderY
        )
    end

    Drawing.setColor(bgColor)
    Drawing.rectangle(self.x, self.y, self.width, self.height)

    --  draw text or placehodler
    Drawing.setFont(self.font)
    local textColor = self.layout.text.color.placeholder
    local text = self.placeholder

    if self.active or utf8.len(self.value) > 0 then
        textColor = self.layout.text.color.default
        text = self.masked and ("*"):rep(#self.value) or self.value
    end

    local textOffsetX = 10 * self.scale.x
    local textLeftX = self.x + textOffsetX
    local textBoxWidth = self.width - textOffsetX * 2
    local caretTextWidth = dxGetTextWidth(utf8.sub(text, 1, self.caret.pos), 1, self.font, false)
    local caretOffsetX = 2 * self.scale.x
    local caretX = self.x + textOffsetX + caretTextWidth + caretOffsetX
    local textAlign = "left"
    if (caretTextWidth > textBoxWidth) then
        caretX = self.x + self.width - textOffsetX + caretOffsetX
        textAlign = "right"
    end

    Drawing.setColor(textColor)
    Drawing.text(
        textLeftX,
        self.y,
        textBoxWidth,
        self.height,
        text,
        self.fontScale,
        textAlign,
        "center",
        true,
        false
    )

    -- draw caret
    if self.active and getTickCount() % 1000 < 500 then
        local caretTop, caretWidth = 5 * self.scale.y, 2 * self.scale.x
        Drawing.rectangle(caretX, self.y + caretTop, caretWidth, self.height - 2 * caretTop)
    end

    --  backspace held
    if self.backspaceHeld and getTickCount() > self.backspaceTick + 25 then
        self.backspaceTick = getTickCount()
        self:removeChar()
    end

    --  caret pos held
    if self.caret.held and getTickCount() > self.caret.tick + 20 then
        self.caret.tick = getTickCount()

        if self.caret.direction == 'left' then
            self:moveCaretLeft()
        elseif self.caret.direction == 'right' then
            self:moveCaretRight()
        end
    end
end

function Input:setMasked(state)
    state = not not state
    self.masked = state
end

function Input:getMasked()
    return self.masked
end

function Input:setInvalid(state)
    state = not not state
    self.invalid = state
end

function Input:setActive(state)
    state = not not state

    if state then
        if not self.active then
            self.invalid = false

            guiSetInputMode("no_binds")
            addEventHandler("onClientCharacter", root, self.charEvent)

            self.active = true
        end
    else
        guiSetInputMode("allow_binds")
        removeEventHandler("onClientCharacter", root, self.charEvent)

        self.active = false
    end

    return self
end

function Input:onChar(char)
    if self.visible and self.active then
        self:insertString(char)
    else
        self:setActive(false)
    end
end

function Input:getCaretValueParts()
    local currentCaretPos = self.caret.pos
    return self.value:sub(1, currentCaretPos), self.value:sub(currentCaretPos + 1)
end

function Input:insertString(str)
    local before, after = self:getCaretValueParts()
    self.value = before .. str .. after
    self:moveCaretRight(utf8.len(str))
end

function Input:removeChar()
    local before, after = self:getCaretValueParts()
    local beforeSub = before:sub(1, -2)
    self.value = beforeSub .. after
    self:moveCaretLeft()
end

function Input:moveCaretLeft()
    local oldCaretPos = self.caret.pos
    self.caret.pos = (oldCaretPos - 1 > 0) and (oldCaretPos - 1) or 0
end

function Input:moveCaretRight(offset)
    offset = tonumber(offset) or 1
    local oldCaretPos = self.caret.pos
    local textSize = utf8.len(self.value)
    self.caret.pos = (oldCaretPos + offset < textSize) and oldCaretPos + offset or textSize
end

addEvent("ui.inputAccepted", true)
function Input:onKey(key, down)
    if self.readOnly then
        return
    end

    if key == 'mouse1' then
        self:setActive(self.mouseOver)
    elseif key == 'backspace' then
        if self.active and down then
            self:removeChar()
            self.backspaceHeld = true
            self.backspaceTick = getTickCount() + 500
        else
            self.backspaceHeld = false
        end
    elseif self.active and key == 'arrow_l' or key == 'arrow_r' then
        if down then
            if key == 'arrow_l' then
                self.caret.direction = 'left'
                self:moveCaretLeft()
            else
                self.caret.direction = 'right'
                self:moveCaretRight()
            end

            self.caret.held = true
            self.caret.tick = getTickCount() + 450
        else
            self.caret.held = false
        end
    elseif self.active and key == 'c' and not down then
        if getKeyState("lctrl") then
            setClipboard(self.value)
        end
    elseif self.active and key == 'v' and not down then
        if getKeyState("lctrl") then
            if isElement(pasteEdit) then
                self:insertString(pasteEdit.text)
                pasteEdit:destroy()
            end
        end
    elseif self.active and key == 'enter' and down then
        self:emit('accepted')
        triggerEvent("ui.inputAccepted", self.element)

        self:setActive(false)
    elseif self.active and key == 'tab' and down then
        local inputs = {}
        local parentChildren = self.parent and self.parent.children or {}
        local currentIndex = 1

        for i, component in ipairs(parentChildren) do
            if component._type == "ui-input" then
                table.insert(inputs, component)

                if component.id == self.id then
                    currentIndex = i
                end
            end
        end

        if #inputs > 1 then
            currentIndex = currentIndex + 1

            if currentIndex > #inputs then
                currentIndex = 1
            end

            local activeInput = inputs[currentIndex]
            self:setActive(false)
            activeInput:setOnTop()
            activeInput:setActive(true)
        end
    end

    if self.active then
        if not isElement(pasteEdit) and getKeyState('lctrl') and down then
            pasteEdit = guiCreateEdit(0, 0, 0, 0, '', false)
            pasteEdit:setAlpha(0)
            pasteEdit:focus()
        else
            if isElement(pasteEdit) and key ~= 'v' then
                pasteEdit:destroy()
            end
        end
    end
end

function Input:setPlaceholder(text)
    self.placeholder = text or ""
end

function Input:getValue()
    return self.value
end

function Input:execInternal(name, ...)
    if name == "getValue" then
        return self:getValue(...)
    elseif name == "setMasked" then
       return self:setMasked(...)
    elseif name == "getMasked" then
       return self:getMasked(...)
    elseif name == "setPlaceholder" then
       return self:setPlaceholder(...)
    elseif name == "setInvalid" then
       return self:setInvalid(...)
    end

    return false
end