local UI = {}

function UI:HideCursor()
    poke(0x3FFB,1)
end



return UI