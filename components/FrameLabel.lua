FrameLabel = {}

local Layout = ComponentLayout.frameLabel

local function loadLayout(data)
    if type(data) ~= "table" then
        data = {}
    end

    return  {
        bgColor = data.bgColor or Layout.bgColor,
        color = data.color or Layout.color
    }
end

local function loadLabel(height, data)
    if type(data) ~= "table" then
        data = {}
    end

    local label = {}
    label.height = tonumber(data.height) or height
    label.text = data.text or ""
    label.font = data.font or Fonts.defaultSmall
    label.fontScale = data.fontScale or 1.0
    label.alignX = data.alignX or "center"
    label.alignY = data.alignY or "center"
    label.clip = not not data.clip
    label.wordBreak = not not data.wordBreak
    label.colorCoded = not not data.colorCoded

    return label
end

function FrameLabel.create(properties)
    if type(properties) ~= "table" then
        properties = {}
    end

    local component = inherit(Component.create(properties), FrameLabel)
    component._type = "ui-frame-label"
    component.label = loadLabel(component.height, properties.label)
    component.rt = DxRenderTarget(component.width, component.height, true)
    component.sp = 1
    component.rtUpdated = false
    component.layout = loadLayout(properties.layout)
    component.scrollbarWidth = 10 * component.scale.x
    component.scrollbarVisible = true
    component.scrollbar = Scrollbar.create(component.width - component.scrollbarWidth, 0, component.scrollbarWidth, component.height):setParent(component)

    component.scrollbar:on('change', function(pos)
        if component.scrollbar.mouseDown then
            component.sp = math.ceil(pos)
            component.rtUpdated = false
        end
    end)

    component:calculateScrollbar()

    return component
end

local function updateRT(frameLabel)
    dxSetRenderTarget(frameLabel.rt, true)
    frameLabel:drawLabel()
    dxSetRenderTarget()
end

function FrameLabel:calculateScrollbar()
    local height = self.height * (self.height / self.label.height)
    self.scrollbar.enabled = height <= self.height
    self.scrollbar:setThumbHeight(math.min(self.height, height))
end

function FrameLabel:drawLabel()
    --  set color and font
    Drawing.setColor(self.layout.color)
    Drawing.setFont(self.label.font)

    --  draw text
    Drawing.text(
        0,
        self.y * (self.sp / 100),
        self.width - self.scrollbar.width,
        self.label.height,
        self.label.text,
        self.label.fontScale,
        self.label.alignX,
        self.label.alignY,
        self.label.clip,
        self.label.wordBreak,
        self.label.colorCoded
    )
end

function FrameLabel:draw()
    if not self.visible then
        return
    end

    self.mouseOver = Render.mouseX and isPointInRect(Render.mouseX, Render.mouseY, self.x, self.y, self.width, self.height)

    Drawing.setColor(self.layout.bgColor)
    Drawing.rectangle(self.x, self.y, self.width, self.height)

    if not self.rtUpdated or self.mouseOver and self.focused then
        updateRT(self) -- draw items onto the render target
        self.rtUpdated = true
    end

    Drawing.image(self.x, self.y, self.width, self.height, self.rt)
end

function FrameLabel:onKey(key, down)
    if not self.mouseOver then return end

    self.rtUpdated = false
end