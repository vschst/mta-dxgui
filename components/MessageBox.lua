MessageBox = {}

local Layout = ComponentLayout.messageBox

local function loadLayout(data)
    if type(data) ~= "table" then
        data = {}
    end

    local textLayout = data.text or {}
    local buttonLayout = data.button or {}
    buttonLayout.bgColor = buttonLayout.bgColor or {}

    local layout = {
        bgColor = data.bgColor or Layout.bgColor,
        text = {
            color = textLayout.color or Layout.text.color
        },
        button = {
            bgColor = {
                default = buttonLayout.bgColor.default or Layout.button.bgColor.default,
                hover = buttonLayout.bgColor.hover or Layout.button.bgColor.hover
            },
            textColor = {
                default = buttonLayout.textColor or Layout.button.textColor
            }
        }
    }

    layout.button.bgColor.down = layout.button.bgColor.default
    layout.button.textColor.hover = layout.button.textColor.default

    return layout
end

local function createLabel(component, layout)
    local labelWidth, labelHeight = 0.9 * component.width, 0.7 * component.height
    local labelX, labelY = (component.width - labelWidth) / 2, 0.05 * component.height

    return Label.create({
        x = labelX,
        y = labelY,
        width = labelWidth,
        height = labelHeight,
        text = component.messageText,
        font = Fonts.defaultSmall,
        layout = layout
    })
end

local function createButton(component, layout)
    local buttonWidth, buttonHeight = component.width / 2, 0.2 * component.height
    local buttonX, buttonY = (component.width - buttonWidth) / 2, 0.75 * component.height

    return Button.create({
        x = buttonX,
        y = buttonY,
        width = buttonWidth,
        height = buttonHeight,
        text = component.buttonText,
        font = Fonts.defaultSmall,
        layout = layout
    })
end

function MessageBox.create(properties)
    if type(properties) ~= "table" then
        properties = {}
    end

    local component = inherit(Component.create(properties), MessageBox)
    component.messageText = properties.messageText or ""
    component.buttonText = properties.buttonText or "OK"
    component.layout = loadLayout(properties.layout)
    component.label = createLabel(component, component.layout.label)
    component.button = createButton(component, component.layout.button)
    component.rt = DxRenderTarget(component.width, component.height, false)

    return component
end

function MessageBox:draw()
    --  draw message window
    Drawing.setColor(self.layout.bgColor)
    Drawing.rectangle(0, 0, self.width, self.height)
end

function MessageBox:render(mouseX, mouseY)
    self:draw()

    --  render label and button
    self.label:draw()
    self.button:draw()

    mouseX = mouseX - self.button.x
    mouseY = mouseY - self.button.y
    self.button.mouseOver = isPointInRect(mouseX, mouseY, 0, 0, self.button.width, self.button.height)
end

