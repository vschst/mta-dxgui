Checkbox = {}

local Layout = ComponentLayout.checkbox

local function loadLayout(data)
    if type(data) ~= "table" then
        data = {}
    end

    local layout = {
        color = {}
    }
    local color = data.color or {}
    layout.color.default = color.default or Layout.color.default
    layout.color.hover = color.hover or Layout.color.hover

    return layout
end

function Checkbox.create(properties)
    if type(properties) ~= "table" then
        properties = {}
    end

    local component = inherit(Component.create(properties), Checkbox)
    component._type = "ui-checkbox"
    component.selected = false
    component.layout = loadLayout(properties.layout)

    component:on('mouseup', function(btn)
        component:toggle()
    end)

    return component
end

function Checkbox:draw()
    -- draw border
    self:drawBorders(2, self.layout.color.default)

    --  draw box
    local boxColor = self.mouseOver and self.layout.color.hover or tocolor(255, 255, 255, 0)
    if self.selected then
        boxColor = self.layout.color.default
    end

    Drawing.setColor(boxColor)
    local boxOffsetX, boxOffsetY = 0.2 * self.width, 0.2 * self.height
    Drawing.rectangle(
        self.x + boxOffsetX,
        self.y + boxOffsetY,
        self.width - 1.5 * boxOffsetX,
        self.height - 1.5 * boxOffsetY
    )
end

addEvent("ui.toggleCheckbox", true)
function Checkbox:toggle()
    self.selected = not self.selected

    self:emit("toggle", self.selected)
    triggerEvent("ui.toggleCheckbox", self.element, self.selected)
end

function Checkbox:getSelected()
    return self.selected
end

function Checkbox:execInternal(name, ...)
    if name == "toggle" then
        return self:toggle(...)
    elseif name == "getSelected" then
        return self:getSelected(...)
    end

    return false
end