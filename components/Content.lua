Content = {}

local function loadLayout(data)
    if type(data) ~= "table" then
        data = {}
    end

    return {
        bgColor = data.bgColor or tocolor(255, 255, 255, 0)
    }
end

function Content.create(properties)
    if type(properties) ~= "table" then
        properties = {}
    end

    local component = inherit(Component.create(properties), Content)
    component._type = "ui-content"
    component.layout = loadLayout(properties.layout)

    return component
end

function Content:draw()
    Drawing.setColor(self.layout.bgColor)
    Drawing.rectangle(self.x, self.y, self.width, self.height)
end