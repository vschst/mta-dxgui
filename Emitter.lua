Emitter = {}

function Emitter.new(properties)
    local self = inherit(properties or {}, Emitter)
    self._on = {}
    self._once = {}

    return self
end

function Emitter:on(eventName, callback)
    if type(eventName) ~= "string" then
        outputDebugString("Emitter:on error: 'eventName' argument not a string")
        return false
    end

    if type(callback) ~= "function" then
        outputDebugString("Emitter:on error: 'callback' argument not a function")
        return false
    end

    local evtbl = self._on[eventName]

    if not evtbl then
        evtbl = {}
        self._on[eventName] = evtbl
    end

    table.insert(evtbl, callback)

    return self
end

function Emitter:once(eventName, callback)
    if type(eventName) ~= "string" then
        outputDebugString("Emitter:once error: 'eventName' argument not a string")
        return false
    end

    if type(callback) ~= "function" then
        outputDebugString("Emitter:once error: 'callback' argument not a function")
        return false
    end

    self._once[eventName] = callback

    return self
end

function Emitter:off(eventName, callback)
    local evtbl = self._on[eventName]

    if evtbl then
        for i=1, #evtbl do
            if evtbl[i] == callback then
                return table.remove(evtbl, i)
            end
        end
    end
end

function Emitter:emit(eventName, ...)
    if type(eventName) ~= "string" then
        outputDebugString("Emitter:emit error: 'eventName' argument not a string")
        return false
    end

    local evtbl = self._on[eventName]

    if evtbl then
        for i=1, #evtbl do
            evtbl[i](...)
        end
    end

    local ev = self._once and self._once[eventName]

    if ev then
        ev(...)

        if self._once then
            self._once[eventName] = nil
        end
    end
end