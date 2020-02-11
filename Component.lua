Component = {}

local function loadScale(data)
    if type(data) ~= "table" then
       data = {}
    end

    return {
        x = tonumber(data.x) or 1.0,
        y = tonumber(data.y) or 1.0
    }
end

function Component.create(properties)
    if type(properties) ~= "table" then
        properties = {}
    end

    local self = inherit({}, Component)
    self._type = "ui-root"
    self.ox = tonumber(properties.x) or 0
    self.oy = tonumber(properties.y) or 0
    self.x = self.ox
    self.y = self.oy
    self.width = tonumber(properties.width) or 0
    self.height = tonumber(properties.height) or 0
    self.offsetX = 0
    self.offsetY = 0
    self.scale = loadScale(properties.scale)
    self.children = {}
    self.parent = nil
    self.visible = properties.visible or true
    self.enabled = properties.enabled or true
    self.focused = false
    self.mouseOver = false
    self.mouseDown = false
    self.tooltip = {}

    Emitter.new(self)

    return self
end

addEvent("ui.draw")
function Component:render(mouseX, mouseY)
    if not self.visible then
        return
    end

    mouseX = mouseX - self.ox
    mouseY = mouseY - self.oy
    self.mouseX = mouseX
    self.mouseY = mouseY

    local parent = self:getParent()

    if parent then
        self.x = self.ox + parent.offsetX
        self.y = self.oy + parent.offsetY
    end

    if self.draw then
        self:draw()
        self:emit('update')

        if isElement(self.element) then
            triggerEvent("ui.draw", self.element)
        end
    end

    Drawing.translate(self.x, self.y)

    for i, childComponent in ipairs(self.children) do
        childComponent:render(mouseX, mouseY)
    end

    Drawing.translate(-self.x, -self.y)

    self.mouseOver = (self.focused or not parent) and isPointInRect(mouseX, mouseY, 0, 0, self.width, self.height)
    self:drawTooltip(mouseX, mouseY)
end

function Component:drawTooltip(mouseX, mouseY)
    if not self.tooltip.value then return end
    if not self.mouseOver then return end
    if not self:isOnTop() then return end

    local d = self.tooltip
    local val = d.value
    local tw, th = d.tw, d.th
    local pad = d.pad
    local offset = d.offset
    local fontSize = d.fontSize
    local font = d.font
    local mx, my = mouseX + offset, mouseY + offset

    dxDrawRectangle(
        mx,
        my,
        tw + pad*4,
        th + pad*2,
        tocolor(0, 0, 0, 215),
        true
    )
    dxDrawText(
        val,
        mx + pad*2,
        my + pad,
        tw - pad*2,
        th - pad*2,
        tocolor(255,255,255),
        fontSize,
        font,
        'left',
        'top',
        false,
        false,
        true
    )
end

function Component:setTooltip(data)
    if type(data.value) ~= 'string' then
        return
    end

    local d = self.tooltip
    d.value = data.value
    d.fontSize = data.fontSize or d.fontSize or 1.5
    d.pad = data.pad or d.pad or 3
    d.offset = data.offset or d.offset or 10
    d.font = data.font or d.font or Fonts.defaultSmall
    d.tw = dxGetTextWidth(d.value, d.fontSize, d.font)
    d.th = dxGetFontHeight(d.fontSize, d.font)
end

local function getRootComponent(component)
    if component.parent then
        return getRootComponent(component.parent)
    elseif isComponent(component, "ui-root") then
        return component
    end

    return false
end

function Component:getRootComponent()
    return getRootComponent(self)
end

function Component:isParentRoot()
    return self.parent and self.parent == self:getRootComponent() or false
end

function Component:getParent()
    return not self:isParentRoot() and self.parent or false
end

function Component:getIndex()
    if self.parent then
        local parentChildren = self.parent.children

        for i, component in ipairs(parentChildren) do
            if component.id == self.id then
                return i, parentChildren
            end
        end
    end

    return false
end

function Component:remove()
    local index, components = self:getIndex()

    return index and table.remove(components, index) or false
end

function Component:destroy()
    local children = self.children

    for i, component in ipairs(children) do
        component:destroy()
    end


    self:remove()
    self:emit('destroy', self)

    collectgarbage()
end

function Component:getChildIndex(child)
    if not child then
        return false
    end

    for i, childComponent in ipairs(self.children) do
        if childComponent.id == child.id then
            return i
        end
    end

    return false
end

function Component:removeParent()
    if self.parent then
        local rootComponent = self:getRootComponent()

        if rootComponent then
            self:remove()
            self.parent = rootComponent

            return table.insert(rootComponent.children, self)
        end
    end

    return self
end

function Component:setParent(parent)
    if not isComponent(parent) then
        outputDebugString("Component:setParent error: The parent doesn't exist or was destroyed")
        return false
    end

    if self.parent then
        self:removeParent()
    end

    self:remove()
    table.insert(parent.children, self)
    self.parent = parent

    return self
end

function Component:addChild(child)
    if not child then
        return false
    end

    child:setParent(self)

    return true
end

function Component:getPosition()
    return self.x, self.y
end

function Component:setPosition(x, y)
    x = tonumber(x) or self.ox
    y = tonumber(y) or self.oy
    self.ox, self.oy = x, y
    self.x, self.y = x, y

    return self
end

function Component:getSize()
    return self.width, self.height
end

function Component:setSize(width, height)
    self.width = tonumber(width) or self.width
    self.height = tonumber(height) or self.height

    return self
end

function Component:getVisible()
    return self.visible
end

function Component:setVisible(state)
    state = not not state
    self.visible = state

    return self
end

function Component:hide()
    self.visible = false

    return self
end

function Component:show()
    self.visible = true

    return self
end

function Component:getEnabled()
    return self.enabled
end

function Component:setEnabled(state)
    state = not not state
    self.enabled = state

    return self
end

function Component:focus()
    if not self.visible then
        return
    end

    local rootComponent = self:getRootComponent()
    local rootChildren = rootComponent.children

    for i, component in ipairs(rootChildren) do
        if self.id ~= component.id then
            component.focused = false
        end
    end

    for j, childComponent in ipairs(self.children) do
        childComponent:focus()
    end

    self.focused = true

    return self
end

function Component:setOnTop()
    local index, components = self:getIndex()

    if index and components[1].id ~= self.id then
        table.remove(components, index)
        table.insert(components, 1, self)
    end

    self:focus()

    return self
end

function Component:isOnTop()
    local index, components = self:getIndex()

    if index and components[1].id ~= self.id then
        return true
    end

    return false
end

function Component:setDraggable(state)
    state = not not state

    if state then
        if not isComponent(self.dragArea, "ui-drag-area") then
            self.dragArea = DragArea.create():setParent(self)
        end
    else
        if isComponent(self.dragArea, "ui-drag-area") then
            self.dragArea:destroy()
        end
    end

    return self
end

function Component:drawBorders(size, color)
    size = size or 2
    color = color or tocolor(255, 55, 55, 200)
    local borderX, borderY = size * self.scale.x, size * self.scale.y

    Drawing.setColor(color)
    Drawing.line(self.x - borderX, self.y - borderY / 2, self.x + self.width + borderY, self.y - borderY / 2, borderY)--top
    Drawing.line(self.x + self.width + borderX / 2, self.y, self.x + self.width + borderX / 2, self.y + self.height, borderX)--right
    Drawing.line(self.x + self.width + borderY, self.y + self.height + borderY / 2, self.x - borderX, self.y + self.height + borderY / 2, borderY)--bottom
    Drawing.line(self.x - borderX / 2, self.y + self.height, self.x - borderX / 2, self.y, borderX)--left
end

function Component:exec(name, ...)
    if name == "getPosition" then
        return self:getPosition(...)
    elseif name == "setPosition" then
        return self:setPosition(...)
    elseif name == "getSize" then
        return self:getSize(...)
    elseif name == "setSize" then
        return self:setSize(...)
    elseif name == "getVisible" then
        return self:getVisible(...)
    elseif name == "setVisible" then
        return self:setVisible(...)
    elseif name == "hide" then
        return self:hide(...)
    elseif name == "show" then
        return self:show(...)
    elseif name == "getEnabled" then
        return self:getEnabled(...)
    elseif name == "setEnabled" then
        return self:setEnabled(...)
    elseif name == "setOnTop" then
        return self:setOnTop(...)
    elseif type(self.execInternal) == "function" then
        return self:execInternal(name, ...)
    end

    return false
end