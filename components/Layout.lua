ComponentLayout = {
    input = {
        bgColor = {
            default = tocolor(0, 139, 255, 200),
            active = tocolor(0, 175, 255, 200),
            hover = tocolor(0, 154, 255, 200),
            invalid = tocolor(220, 53, 69, 200)
        },
        text = {
            color = {
                default = tocolor(255, 255, 255, 255),
                placehodler = tocolor(255, 255, 255, 200)
            }
        }
    },
    button = {
        bgColor = {
            default = tocolor(0, 75, 255),
            hover = tocolor(150, 150, 150),
            down = tocolor(255, 255, 255),
            disabled = tocolor(0, 75, 255, 150)
        },
        textColor = {
            default = tocolor(255, 255, 255),
            hover = tocolor(224, 224, 224)
        }
    },
    checkbox = {
        color = {
            default = tocolor(42, 40, 41),
            hover = tocolor(42, 40, 41, 150)
        }
    },
    label = {
        color = tocolor(255, 255, 255)
    },
    frameLabel = {
        bgColor = tocolor(16, 160, 207, 255),
        color = tocolor(10, 10, 10)
    },
    messageBox = {
        bgColor = tocolor(40, 40, 40),
        text = {
            color = tocolor(255, 255, 255)
        },
        button = {
            bgColor = {
                default = tocolor(212, 0, 40),
                hover = tocolor(212, 40, 40)
            },
            textColor = tocolor(255, 255, 255)
        }
    },
    scrollbar = {
        bgColor = tocolor(11, 11, 11, 255)
    },
    thumb = {
        bgColor = {
            dragging = tocolor(55, 110, 255, 255),
            hover = tocolor(55, 80, 255, 255),
            default = tocolor(55, 55, 255, 255)
        }
    }
}