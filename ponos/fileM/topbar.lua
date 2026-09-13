local newNumPad = function(callback)
    local height = math.min(sh/2.4, 350)
	
	local group = display.newGroup()
	group.x = sw/2
	
	local bg = display.newRoundedRect(group, 0, 0, sw-app.pad, height+getBottomNavHeight()+app.pad, 0)
	bg:addEventListener("touch", function()
	return true end)
	bg:setFillColor(0.4, 0.4, 0.4)
	local buttons = {
	    { {text = "1", symbol = 1}, {text = "2", symbol = 2}, {text = "3", symbol = 3}, },
		{ {text = "4", symbol = 4}, {text = "5", symbol = 5}, {text = "6", symbol = 6}, },
		{ {text = "7", symbol = 7}, {text = "8", symbol = 8}, {text = "9", symbol = 9}, },
		{ {text = ".", symbol = "."}, {text = "0", symbol = 0}, {text = "⌫", symbol = "backspace"}, },
	}
	
	local currenty = -bg.height/2+app.pad
	local dag = display.newGroup()
	group:insert(dag)
	local bheight = height/#buttons
	local padh = math.min(bg.width-app.pad, height*1.3)
	for i = 1, #buttons do
	    local list = buttons[i]
		
		local mygroup = display.newGroup()
		dag:insert(mygroup)
		
		local width = padh/#list
		
		for ii = 1, #list do
		    local this = list[ii]
			
			local btn = PonosUi.newButton(function(event) 
			    if event.phase == "ended" then
				    callback(this.symbol)
				end
			    return true
			end, {x = -padh/2+ii*width-width+app.pad/2, y = currenty, width = width-app.pad, height = bheight-app.pad, text = this.text, rounded = bheight/4, colorBg = {0.2,0.2,0.2}},mygroup)
			btn.anchorX = 0
			btn.anchorY = 0
		end
		currenty = currenty+bheight
	end
	group.y = sh-group.height/2
	
	return group
end

local newPad = function(callback)
    local height = math.min(sh/2.4, 350)
	
	local group = display.newGroup()
	group.x = sw/2
	
	local bg = display.newRoundedRect(group, 0, 0, sw, height+getBottomNavHeight(), 0)
	bg:addEventListener("touch", function()
	return true end)
	bg:setFillColor(0.4, 0.4, 0.4)
	local buttons = {
	    { {text = "q", symbol = "q"}, {text = "w", symbol = "w"}, {text = "e", symbol = "e"},{text = "r", symbol = "r"},{text = "t", symbol = "t"},{text = "y", symbol = "y"},{text = "u", symbol = "u"},{text = "i", symbol = "i"},{text = "o", symbol = "o"},{text = "p", symbol = "p"} },
		{ {text = "a", symbol = "a"}, {text = "s", symbol = "s"}, {text = "d", symbol = "d"},{text = "f", symbol = "f"},{text = "g", symbol = "g"},{text = "h", symbol = "h"},{text = "j", symbol = "j"},{text = "k", symbol = "k"},{text = "l", symbol = "l"} },
		{ {text = "^", symbol = "upper"}, {text = "z", symbol = "z"},{text = "x", symbol = "x"},{text = "c", symbol = "c"},{text = "v", symbol = "v"},{text = "b", symbol = "b"},{text = "n", symbol = "n"},{text = "m", symbol = "m"}, {text = "⌫", symbol = "backspace"}},
		{ {text = "space", symbol = " "} },
	}
	
	local currenty = -bg.height/2
	local dag = display.newGroup()
	group:insert(dag)
	local bheight = height/#buttons
	local padh = bg.width
	for i = 1, #buttons do
	    local list = buttons[i]
		
		local mygroup = display.newGroup()
		dag:insert(mygroup)
		
		local width = padh/#list
		
		for ii = 1, #list do
		    local this = list[ii]
			
			local btn = PonosUi.newButton(function(event) 
			    if event.phase == "ended" then
				    callback(this.symbol)
				end
			    return true
			end, {x = -padh/2+ii*width-width, y = currenty, width = width, height = bheight, text = this.text, rounded = 30, fontSize = app.fontsize2, colorBg = {0.2,0.2,0.2}},mygroup)
			btn.anchorX = 0
			btn.anchorY = 0
		end
		currenty = currenty+bheight
	end
	group.y = sh-group.height/2
	
	return group
end

newNumInput = function(params)
    local width = params.width or 200
    local height = params.height or 50
    local fontSize = params.fontSize or app.fontsize1
    local initText = params.text or ""
    
    local onPadOpen = params.onPadOpen
    local onPadClose = params.onPadClose
    local onClose = params.onClose
    
    local group = display.newGroup()
    group.x = params.x or 0
    group.y = params.y or 0
    
    local bg = display.newRect(group, 0, 0, width, height)
    bg:setFillColor(0.2, 0.2, 0.2)
    
    local scrollview = PonosUi.newScrollView({
        x = -height/2,
        y = -bg.height/2,
        width = bg.width-height,
        height = bg.height,
        verticalScrollDisabled = true,
        showScrollbars = false
    })
    
    group:insert(scrollview)
    
    local textGroup = display.newGroup()
    scrollview:insert(textGroup)
    
    local cursor = display.newRect(0, bg.height/2, 2, height * 0.8)
    cursor:setFillColor(0.8, 0.8, 0.8)
    cursor.isVisible = false
    scrollview:insert(cursor)
    
    local chars = {}
    for i = 1, #initText do
        chars[i] = initText:sub(i, i)
    end
    local cursorIndex = #chars
    local activePad = nil
    
    local blinkTimer = nil
    local function blinkCursor()
        cursor.isVisible = not cursor.isVisible
    end
    
    local function updateDisplay()
        for i = textGroup.numChildren, 1, -1 do
            textGroup[i]:removeSelf()
        end
        
        local currentX = 10
        
        local startHit = display.newRect(textGroup, currentX - 10, bg.height/2, 18, height)
        startHit.anchorX = 0
        startHit.isHitTestable = true
        startHit.isVisible = false
        startHit:addEventListener("touch", function(event)
            if event.phase == "moved" then
                scrollview:takeFocus(event)
            elseif event.phase == "ended" then
                cursorIndex = 0
                updateDisplay()
            end
            return true
        end)
        
        if cursorIndex == 0 then cursor.x = currentX end
        
        for i = 1, #chars do
            local charText = display.newText({
                parent = textGroup, text = chars[i],
                x = currentX, y = bg.height/2,
                font = app.font, fontSize = fontSize
            })
            charText.anchorX = 0
            local charWidth = charText.width
            
            local charHit = display.newRect(textGroup, currentX, bg.height/2, charWidth + 2, height)
            charHit.anchorX = 0
            charHit.isHitTestable = true
            charHit.isVisible = false
            charHit:addEventListener("touch", function(event)
                if event.phase == "moved" then
                    scrollview:takeFocus(event)
                elseif event.phase == "ended" then
                    cursorIndex = i
                    updateDisplay()
                end
                return true
            end)
            
            currentX = currentX + charWidth + 2
            if cursorIndex == i then cursor.x = currentX end
        end
    end
    
    local function onNumPadCallback(symbol)
        if symbol == "backspace" then
            if cursorIndex > 0 then
                table.remove(chars, cursorIndex)
                cursorIndex = cursorIndex - 1
                updateDisplay()
            end
        else
            table.insert(chars, cursorIndex + 1, tostring(symbol))
            cursorIndex = cursorIndex + 1
            updateDisplay()
        end
    end
    
    local hitBg = display.newRect(group, width/2-height/2, 0, height, height)
    hitBg:setFillColor(0.25, 0.25, 0.25)
	hitBg.x = 0
	hitBg.width = width
	hitBg.alpha = 0.1
    local hitBgIcon = display.newRect(group, width/2-height/2, 0, height/1.5, height/1.5)
    hitBgIcon.fill = { filename = "res/ui/play.png", type = "image" }
	hitBgIcon.alpha = 0.5
    
    hitBg:addEventListener("touch", function(event)
        if event.phase == "ended" then
            if not activePad then
			    hitBg.x = width/2-height/2
				hitBg.width = height
                hitBgIcon.fill = { filename = "res/ui/continue.png", type = "image" }
				hitBgIcon.alpha = 1
				hitBg.alpha = 0.8
                cursorIndex = #chars
                updateDisplay()
                cursor.isVisible = true
                if blinkTimer then timer.cancel(blinkTimer) end
                blinkTimer = timer.performWithDelay(500, blinkCursor, 0)
                
                activePad = newNumPad(onNumPadCallback)
                
                if onPadOpen then onPadOpen(activePad.height) end
            else
                group:closePad()
            end
        end
        return true
    end)
    
    group:addEventListener("finalize", function()
        if blinkTimer then timer.cancel(blinkTimer) end
    end)
    
    function group:getText()
        return table.concat(chars)
    end
    
    function group:closePad()
        if activePad then
            activePad:removeSelf()
            activePad = nil
            cursor.isVisible = false
            if blinkTimer then 
                timer.cancel(blinkTimer)
                blinkTimer = nil
            end
			hitBg.x = 0
			hitBg.width = width
			hitBg.alpha = 0.1
			hitBgIcon.alpha = 0.5
            hitBgIcon.fill = { filename = "res/ui/play.png", type = "image" }
			local x, y = scrollview:getContentPosition() 
			scrollview:scrollToPosition2(0, 0, -x*2)
            
            if onPadClose then onPadClose() end
            if onClose then onClose(group:getText()) end
        end
    end
    
    updateDisplay()
    return group
end