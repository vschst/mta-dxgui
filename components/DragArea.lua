DragArea = {}

local utils = exports.utils

function DragArea.create(properties)
    if type(properties) ~= "table" then
        properties = {}
    end

    local component = inherit(Component.create(properties), DragArea)
    component._type = "ui-drag-area"
    component.dragging = false
    component.show = false
    component.pmx = 0
    component.pmy = 0

    return component
end

function DragArea:draw()
    local parent = self.parent

    if not parent then
        return
    end

    local x, y = self.x, self.y
    local width, height = self.width, self.height

    if parent.type == "ui-image" then
        self.w = parent.w
        self.h = parent.h
    end

    self.width = self.width ~= 0 and self.width or parent.width
    self.height = self.height ~= 0 and self.height or parent.height

    local pmx, pmy = self.pmx, self.pmy
    local mo = parent.focused and Render.mouseX and isPointInRect(Render.mouseX, Render.mouseY, x, y, self.width, self.height)

    if pmx and Render.mouseX and self.mouseDown and mo or Render.mouseX and self.mouseDown and self.dragging then
        local children = self.children

        for k, component in pairs(children) do
            if component.mouseDown then
                self.dragging = false

                return
            end
        end

        local parentParent = parent.parent

        if parentParent then
            if parent.type == 'image' then
                parent.ox = utils:constrain(parent.ox + (Render.mouseX - pmx), 0, parentParent.width - width - parentParent.offsetX)
                parent.oy = utils:constrain(parent.oy + (Render.mouseY - pmy), 0, parentParent.height - height - parentParent.offsetY)
            else
                parent.ox = utils:constrain(parent.ox + (Render.mouseX - pmx), 0, parentParent.width - parent.width - parentParent.offsetX)
                parent.oy = utils:constrain(parent.oy + (Render.mouseY - pmy), 0, parentParent.height - parent.height - parentParent.offsetY)
            end
        else
            parent.x = parent.x + (Render.mouseX - pmx)
            parent.y = parent.y + (Render.mouseY - pmy)
        end

        self.dragging = true
    else
        self.dragging = false
    end

    self.pmx, self.pmy = Render.mouseX, Render.mouseY

    if self.show then
        self:drawBorders(2)
    end
end