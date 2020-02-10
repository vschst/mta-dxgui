addEventHandler("onClientResourceStop", root, function()
    Elements.resources[source] = nil
end)

addEventHandler("onClientResourceStart", resourceRoot, function ()
    Messages.start()
    Render.start()
end)