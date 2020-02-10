Fonts = {}

local assets = exports.assets

local SIZE_NORMAL = 14
local SIZE_LARGE = 18
local SIZE_LARGER = 24
local SIZE_SMALL = 12

addEventHandler("onClientResourceStart", resourceRoot, function ()
    Fonts.default = assets:createFont("Gilroy-Medium.ttf", SIZE_NORMAL)
    Fonts.defaultBold = assets:createFont("Gilroy-Bold.ttf", SIZE_NORMAL, true)

    Fonts.defaultSmall = assets:createFont("Gilroy-Medium.ttf", SIZE_SMALL)
    Fonts.defaultLarge = assets:createFont("Gilroy-Medium.ttf", SIZE_LARGE)
    Fonts.defaultLarger = assets:createFont("Gilroy-Medium.ttf", SIZE_LARGER)

    Fonts.light = assets:createFont("Gilroy-Light.ttf", SIZE_NORMAL)
    Fonts.lightSmall = assets:createFont("Gilroy-Light.ttf", SIZE_SMALL)
end)