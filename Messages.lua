Messages = {}

local assets = exports.assets

local maskShader
local MAX_TRANSORM_ANGLE = 15
local screenWidth, screenHeight = guiGetScreenSize()

local messages = {}

local function draw()
    local message = Messages.getActive()

    if message then
        dxDrawRectangle(0, 0, screenWidth, screenHeight, tocolor(0, 0, 0, 150))
        RenderTarget3D.setDarken(true)

        local mouseX, mouseY = getMousePosition()
        mouseX = mouseX - message.x
        mouseY = mouseY - message.y

        dxSetRenderTarget(message.rt)
        message:render(mouseX, mouseY)
        dxSetRenderTarget()

        if maskShader then
            local rotationX = -(mouseX - screenWidth / 2) / screenWidth * MAX_TRANSORM_ANGLE
            local rotationY = (mouseY - screenHeight / 2) / screenHeight * MAX_TRANSORM_ANGLE

            dxSetShaderTransform(maskShader, rotationX, rotationY, 0, 0, 0, 0.1)
            dxSetShaderValue(maskShader, "sPicTexture", message.rt)
            dxDrawImage(
                message.x,
                message.y,
                message.width,
                message.height,
                maskShader,
                0, 0, 0,
                tocolor(255, 255, 255, 240),
                true
            )
        end
    end
end

local function click(btn, state)
    if btn == "left" and state == "down" then
        local message = Messages.getActive()

        if message and message.button.mouseOver then
            Messages.destroy(message.element)
        end
    end
end

function Messages.isActive()
    return #messages > 0
end

function Messages.getActive()
    return Messages.isActive() and messages[1] or false
end

function Messages.setupMessageElement(message)
    local element = Element("ui-message", #messages + 1)

    if element then
        message.element = element
        element:attach(resourceRoot)

        return true
    end

    return false
end

function Messages.create(properties)
    local message = MessageBox.create(properties)

    if Messages.setupMessageElement(message) then
        table.insert(messages, message)
        showCursor(true)

        return message.element
    end

    return false
end

function Messages.getMessageByElement(element)
    for i, message in ipairs(messages) do
        if message.element == element then
           return i, message
        end
    end

    return false
end

function Messages.destroy(element)
    local index = Messages.getMessageByElement(element)

    if index then
        element:destroy()
        table.remove(messages, index)

        if not Messages.isActive() then
            RenderTarget3D.setDarken(false)
            showCursor(false)
        end

        return true
    end

    return false
end

function Messages.setText(element, messageText, buttonText)
    local index, message = Messages.getMessageByElement(element)

    if index then
        message.label:setText(messageText)

        if buttonText then
            message.button:setText(buttonText)
        end

        return true
    end

    return false
end

function Messages.start()
    maskShader = assets:createShader("texture3d.fx")

    addEventHandler("onClientRender", root, draw, true, "low-10")
    addEventHandler('onClientClick', root, click, true, "low-10")
end