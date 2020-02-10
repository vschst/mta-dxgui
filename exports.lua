local PRINT_META_XML = false
local function printMetaExport(name)
    if PRINT_META_XML then
        outputConsole('\t<export type="client" function="' .. tostring(name) ..'"/>')
    end
end

function fadeScreen(...)
    return Render.fadeScreen(...)
end
printMetaExport("fadeScreen")

function forceRotation(...)
    return Render.forceRotation(...)
end
printMetaExport("forceRotation")

function addChild(parentElement, childElement)
    local parent = Elements.getComponentByElement(parentElement, sourceResourceRoot)
    local child = Elements.getComponentByElement(childElement, sourceResourceRoot)

    if not parent or not child then
        return false
    end

    return parent:addChild(child)
end
printMetaExport("addChild")

function delete(element)
    return Elements.destroyComponent(element, sourceResourceRoot)
end
printMetaExport("delete")

function getRenderTarget()
    return Render.getRenderTarget()
end
printMetaExport("getRenderTarget")

function createMessage(...)
    return Messages.create(...)
end
printMetaExport("createMessage")

function isMessageActive()
    return Messages.isActive()
end
printMetaExport("isMessageActive")

function setMessageText(...)
    return Messages.setText(...)
end
printMetaExport("setMessageText")

local componentsList = {
    "Content",
    "Input",
    "Button",
    "Checkbox",
    "Label",
    "FrameLabel",
    "Image"
}

local function createComponentProxy(name, resourceRoot, properties, parentElement, ...)
    local ComponentType = _G[name]

    if type(ComponentType) ~= "table" then
        outputDebugString("Error: Component does not exist: " .. tostring(name))
        return false
    end

    local component = ComponentType.create(properties, ...)

    if not component then
        outputChatBox("Error: Failed to create component: " .. tostring(name))
        return false
    end

    return Elements.exportComponent(component, resourceRoot, parentElement)
end

for i, name in ipairs(componentsList) do
    _G["create" .. name] = function (properties, parentElement, ...)
        return createComponentProxy(name, sourceResourceRoot, properties, parentElement, ...)
    end

    printMetaExport("create" .. name)
end

function exec(element, name, ...)
    local component = Elements.getComponentByElement(element, sourceResourceRoot)

    if component and type(component.exec) == "function" then
        return component:exec(name, ...)
    end

    return false
end
printMetaExport("exec")