Button = {}

local Layout = ComponentLayout.button

local function loadLayout(data)
    if type(data) ~= "table" then
        data = {}
    end

    local layout = {
        bgColor = {},
        textColor = {}
    }
    --  bg color
    local bgColor = data.bgColor or {}
    layout.bgColor.default = bgColor.default or Layout.bgColor.default
    layout.bgColor.hover = bgColor.hover or Layout.bgColor.hover
    layout.bgColor.down = bgColor.down or Layout.bgColor.down
    layout.bgColor.disabled = bgColor.disabled or Layout.bgColor.disabled

    --  text color
    local textColor = data.textColor or {}
    layout.textColor.default = textColor.default or Layout.textColor.default
    layout.textColor.hover = textColor.hover or Layout.textColor.hover

    return layout
end

function Button.create(properties)
    if type(properties) ~= "table" then
        properties = {}
    end

    local component = inherit(Component.create(properties), Button)
    component._type = "ui-button"
    component.value = properties.value or ""
    component.selected = properties.selected or false
    component.text = properties.text or ""
    component.font = properties.font or Fonts.defaultSmall
    component.fontScale = properties.fontScale or 1.0
    component.alignX = properties.alignX or "center"
    component.alignY = properties.alignY or "center"
    component.layout = loadLayout(properties.layout)

    return component
end

function Button:draw()
    --  set bg and text color
    local bgColor = self.layout.bgColor.default
    local textColor = self.layout.textColor.default

    if not self.enabled then
        bgColor = self.layout.bgColor.disabled
    elseif self.mouseOver then
        if self.mouseDown then
            bgColor = self.layout.bgColor.down
        else
            bgColor = self.layout.bgColor.hover
        end
    end

    if (self.mouseOver or self.selected) and self.enabled then
        textColor = self.layout.textColor.hover
    end

    --  draw background
    Drawing.setColor(bgColor)
    Drawing.rectangle(self.x, self.y, self.width, self.height)

    --  draw text
    Drawing.setColor(textColor)
    Drawing.setFont(self.font)
    Drawing.text(
        self.x,
        self.y,
        self.width,
        self.height,
        self.text,
        self.fontScale,
        self.alignX,
        self.alignY,
        true,
        false
    )
end

function Button:setText(text)
    self.text = text or ""
end

function Button:getText()
    return self.text
end

function Button:getValue()
    return self.value
end

function Button:setSelected(state)
    state = not not state
    self.selected = state
end

function Button:execInternal(name, ...)
    if name == "setText" then
        return self:setText(...)
    elseif name == "getText" then
        return self:getText(...)
    elseif name == "getValue" then
       return self:getValue(...)
    elseif name == "setSelected" then
       return self:setSelected(...)
    end

    return false
end