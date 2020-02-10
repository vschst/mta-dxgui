Image = {}

function Image.create(properties)
    if type(properties) ~= "table" then
        properties = {}
    end

    local component = inherit(Component.create(properties), Image)
    component._type = "ui-image"
    component.texture = properties.texture
    component.color = properties.color or tocolor(255, 255, 255, 255)

    return component
end

function Image:draw()
    if self.texture then
        Drawing.setColor(self.color)
        Drawing.image(self.x, self.y, self.width, self.height, self.texture)
    end
end