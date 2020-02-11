Scrollbar = {}

local utils = exports.utils
local Thumb = {}
local ScrollbarLayout = ComponentLayout.scrollbar

function Scrollbar.create(properties)
    if type(properties) ~= "table" then
        properties = {}
    end

    local component = inherit(Component.create(properties), Scrollbar)
    component._type = "ui-scrollbar"
    component.min = 0
    component.max = 100
    component.thumb = Thumb.create({
        x = 0,
        y = 0,
        width = component.width,
        height = component.width
    }):setParent(component)

    return component
end

function Scrollbar:draw()
    local x, y, width, height = self.x, self.y, self.width, self.height
    local thumb = self.thumb

    thumb.dragArea.dragging = (Render.mouseDown and self.mouseY < height and thumb.pos > self.min) or (Render.mouseDown and self.mouseY > 0 and thumb.pos < self.max - 1)

    Drawing.setColor(ScrollbarLayout.bgColor)
    Drawing.rectangle(x, y, width, height)
end

function Scrollbar:setScrollPosition(pos)
    if tonumber(pos) == nil then
        return false
    end

    local min, max = self.min, self.max
    self.thumb:setPosition(0, math.max(0, utils:scaleLinear(utils:constrain(pos, min, max), min, max, 0, self.height - self.thumb.height)))

    return self
end

function Scrollbar:getScrollPosition()
    return self.thumb.pos
end

function Scrollbar:setThumbHeight(height)
    if tonumber(height) == nil then
        return false
    end

    self.thumb:setHeight(math.max(15 * self.scale.y, height))

    return self
end

function Scrollbar:scrollOneUp()
    local min, max = self.min, self.max
    self.thumb:setPosition(0,  math.max(0, utils:scaleLinear(utils:constrain(self.thumb.pos - 1, min, max), min, max, 0, self.height - self.thumb.height)))

    return self
end

function Scrollbar:scrollOneDown()
    local min, max = self.min, self.max
    self.thumb:setPosition(0,  math.max(0, utils:scaleLinear(utils:constrain(self.thumb.pos + 1, min, max), min, max, 0, self.height - self.thumb.height)))

    return self
end

function Scrollbar:setMinMax(min, max)
    if tonumber(min) == nil or tonumber(max) == nil then
        return false
    end

    self.min = min
    self.max = max

    return self
end

local ThumbLayout = ComponentLayout.thumb

function Thumb.create(properties)
    if type(properties) ~= "table" then
        properties = {}
    end

    local component = inherit(Component.create(properties), Thumb)
    component._type = "ui-thumb"
    component.pos = -1
    component:setDraggable(true)

    return component
end

function Thumb:setHeight(height)
    self.dragArea.height = height
    self.height = height
end

function Thumb:draw()
    local parent = self:getParent()

    if parent then
        local pos = utils:scaleLinear(self.y, parent.y, parent.y + parent.height - self.height, parent.min, parent.max)

        if pos ~= self.pos then
            self.pos = pos
            self.parent:emit('change', pos)
        end

        local bgColor
        if self.dragArea.mouseDown then
            bgColor = ThumbLayout.bgColor.dragging
        elseif self.dragArea.mouseOver then
            bgColor = ThumbLayout.bgColor.hover
        else
            bgColor = ThumbLayout.bgColor.default
        end

        Drawing.setColor(bgColor)
        Drawing.rectangle(self.x, self.y, self.width, self.height)
    end
end