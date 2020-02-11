Render = {}
Render.mouseDown = false

local MAX_TRANSORM_ANGLE = 20
local screenWidth, screenHeight = guiGetScreenSize()
local oldMouseState = false
local renderTarget3D

local targetFadeVal = 0
local currentFadeVal = 0
local fadeSpeed = 10
local fadeActive = false

local forceRotationX, forceRotationY = 0, 0

local function draw()
    dxDrawRectangle(0, 0, screenWidth, screenHeight, tocolor(0, 0, 0, 230 * currentFadeVal))

    Drawing.setColor()
    Drawing.origin()

    local mouseX, mouseY = getMousePosition()
    if Messages.isActive() then
        mouseX = 0
        mouseY = 0
    end

    local newMouseState = getKeyState("mouse1")
    if mouseX and not Render.mouseClick and newMouseState and not oldMouseState then
        Render.mouseDown = true
    end
    oldMouseState = newMouseState

    RenderTarget3D.set(renderTarget3D)
    for resourceRoot, resourceInfo in pairs(Elements.resources) do
        resourceInfo.rootComponent:render(mouseX, mouseY)
    end
    dxSetRenderTarget()

    Render.mouseDown = false

    -- Draw renderTarget3D
    if renderTarget3D then
        RenderTarget3D.draw(renderTarget3D, 0, 0, screenWidth, screenHeight)

        if not isCursorShowing() then
            mouseX, mouseY = forceRotationX * screenWidth, forceRotationY * screenHeight
        end

        local rotationX = -(mouseX - screenWidth / 2) / screenWidth * MAX_TRANSORM_ANGLE
        local rotationY = (mouseY - screenHeight / 2) / screenHeight * MAX_TRANSORM_ANGLE
        RenderTarget3D.setTransform(renderTarget3D, rotationX, rotationY, 0)
    end
end

local function update(dt)
    dt = dt / 1000
    currentFadeVal = currentFadeVal + (targetFadeVal - currentFadeVal) * fadeSpeed * dt
end

addEvent("ui.mouseDown")
addEvent("ui.mouseUp")
addEvent("ui.click")
local function dxClickHandler(component, btn, state, mx, my)
    if Messages.isActive() or not component or not component.visible or not component.enabled then
        return
    end

    mx = mx - component.x
    my = my - component.y

    local children = component.children

    for i, childComponent in ipairs(children) do
        if dxClickHandler(childComponent, btn, state, mx, my) then
            return true
        end
    end

    if state == 'down' then
        if component.mouseOver then
            component.mouseDown = true
            component:setOnTop()

            component:emit("mousedown", btn)
            component:emit("click", btn, state)
            triggerEvent("ui.mouseDown", component.element, btn)
            triggerEvent("ui.click", component.element, btn, state)

            if component:isParentRoot() then
                return true
            end
        end
    else
        if component.mouseOver and component.focused and component.mouseDown then
            component:emit("mouseup", btn)
            component:emit("click", btn, state)
            triggerEvent("ui.mouseUp", component.element, btn)
            triggerEvent("ui.click", component.element, btn, state)

            component.mouseDown = false

            return false
        end

        component.mouseDown = false
    end

    if component.onClick and component.focused then
        component:onClick(btn, state)
    end

    return false
end

local function click(btn, state, mx, my)
    for resourceRoot, resourceInfo in pairs(Elements.resources) do
        local rootChildren = resourceInfo.rootComponent.children

        for i, component in ipairs(rootChildren) do
            local clicked = dxClickHandler(component, btn, state, mx, my)

            if clicked then
                component.focused = clicked

                return true
            end
        end
    end
end

local function dxKeyHandler(component, key, down)
    if Messages.isActive() or component.visible and not component.focused and not component.enabled then
        return
    end

    local children = component.children

    for i, childComponent in ipairs(children) do
        if dxKeyHandler(childComponent, key, down) then
            return true
        end
    end

    if component.onKey then
        component:onKey(key, down)

        return true
    end
end

local function key(key, down)
    for resourceRoot, resourceInfo in pairs(Elements.resources) do
        local rootChildren = resourceInfo.rootComponent.children

        for i, childComponent in ipairs(rootChildren) do
            childComponent.keyUsed = dxKeyHandler(childComponent, key, down)

            if childComponent.keyUsed then
                return false
            end
        end
    end
end

function Render.start()
    renderTarget3D = RenderTarget3D.create(screenWidth, screenHeight)

    Drawing.POST_GUI = not not renderTarget3D.fallback
    addEventHandler("onClientRender", root, draw)
    addEventHandler("onClientPreRender", root, update)
    addEventHandler('onClientClick', root, click)
    addEventHandler('onClientKey', root, key)
end

function Render.getRenderTarget()
    return renderTarget3D.renderTarget
end

function Render.fadeScreen(fade)
    fade = not not fade

    if fade == fadeActive then
        return
    end

    fadeActive = fade
    targetFadeVal = fade and 1 or 0
end

function Render.forceRotation(x, y)
    if type(x) == "number" and type(y) == "number" then
        forceRotationX = x
        forceRotationY = y
    end
end