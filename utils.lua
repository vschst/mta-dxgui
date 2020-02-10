local screenWidth, screenHeight = guiGetScreenSize()

function getMousePosition()
    local mx, my = screenWidth / 2, screenHeight / 2

    if isCursorShowing() then
        mx, my = getCursorPosition()
        mx = mx * screenWidth
        my = my * screenHeight
    end

    return mx, my
end

function isPointInRect(x, y, rx, ry, rw, rh)
    return (x >= rx and y >= ry and x <= rx + rw and y <= ry + rh)
end

function inherit(self, ...)
    for i=1, #arg do
        for k, v in pairs(arg[i]) do
            if k ~= "create" and type(v) == 'function' then
                self[k] = v
            end
        end
    end

    return self
end

function isComponent(component, componentType)
    if type(component) == 'table' and component._type then
        if componentType then
            return componentType == component._type
        end

        return true
    end

    return false
end