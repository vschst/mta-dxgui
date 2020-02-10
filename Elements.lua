Elements = {}
Elements.resources = {}

local function getComponentElementId(elements)
    local id = 0

    for element, component in pairs(elements) do
        if component.id > id then
            id = component.id
        end
    end

    return id + 1
end

function Elements.setupComponentId(component, id)
    component.id = id

    for i, childComponent in ipairs(component.children) do
        Elements.setupComponentId(childComponent, id)
    end
end

function Elements.setupComponent(component, resourceRoot)
    if isComponent(component) and Elements.resources[resourceRoot] then
        local elements =Elements.resources[resourceRoot].elements
        local id = getComponentElementId(elements)
        local element = Element(component._type, id)

        if element then
            Elements.setupComponentId(component, id)

            component.resourceRoot = resourceRoot
            component.element = element
            element:attach(resourceRoot)

            elements[element] = component

            return true
        end
    end

    return false
end

addEvent("ui.destroy")
function Elements.destroyComponent(element, resourceRoot)
    local component, elements = Elements.getComponentByElement(element, resourceRoot)

    if component and isElement(element) then
        component:destroy()

        elements[element] = nil
        triggerEvent("ui.destroy", element)
        element:destroy()

        collectgarbage()

        return true
    end

    return false
end

function Elements.setupResource(resourceRoot)
    if Elements.resources[resourceRoot] then
        return false
    end

    local rootComponent = Component.create()
    rootComponent.resourceRoot = resourceRoot

    Elements.resources[resourceRoot] = {
        elements = {},
        rootComponent = rootComponent
    }

    return true
end

function Elements.getComponentByElement(element, resourceRoot)
    if Elements.resources[resourceRoot] then
        local elements = Elements.resources[resourceRoot].elements

        return elements[element], elements or false
    end

    return false
end

function Elements.exportComponent(component, resourceRoot, parentElement)
    Elements.setupResource(resourceRoot)

    if Elements.setupComponent(component, resourceRoot) then
        local parent = parentElement and Elements.getComponentByElement(parentElement, resourceRoot) or Elements.resources[resourceRoot].rootComponent

        if parent then
            parent:addChild(component)
        end

        return component.element
    end

    return false
end