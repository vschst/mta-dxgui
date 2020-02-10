Label = {}

local Layout = ComponentLayout.label

local function loadLayout(data)
    if type(data) ~= "table" then
        data = {}
    end

    return {
        color = data.color or Layout.color
    }
end

function Label.create(properties)
    if type(properties) ~= "table" then
        properties = {}
    end

    local component = inherit(Component.create(properties), Label)
    component._type = "ui-label"
    component.text = properties.text or ""
    component.font = properties.font or Fonts.defaultSmall
    component.fontScale = properties.fontScale or 1.0
    component.alignX = properties.alignX or "center"
    component.alignY = properties.alignY or "center"
    component.clip = not not properties.clip
    component.wordBreak = not not properties.wordBreak
    component.colorCoded = not not properties.colorCoded
    component.layout = loadLayout(properties.layout)

    return component
end

function Label:draw()
    --  set color and font
    Drawing.setColor(self.layout.color)
    Drawing.setFont(self.font)

    --  draw text
    Drawing.text(
        self.x,
        self.y,
        self.width,
        self.height,
        self.text,
        self.fontScale,
        self.alignX,
        self.alignY,
        self.clip,
        self.wordBreak,
        self.colorCoded
    )
end

function Label:setText(text)
    self.text = text or ""
end

function Label:getText()
    return self.text
end

function Label:execInternal(name, ...)
    if name == "setText" then
       return self:setText(...)
    elseif name == "getText" then
        return self:getText(...)
    end

    return false
end