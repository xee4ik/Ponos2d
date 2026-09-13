local pad = app.pad*1.5
local color = app.color.dialogColor
local vel = sh/67
local dialogW =  math.min(app.content / 1.08, 540)

-- модуль диалогов и всяких всплывающих алертов-вводов оповещений

new_dialog = function(data)
    local opt = data or {}
    local headerStr = tostring(opt.header or "")
    local descStr = tostring(opt.description or "")
    local buttonsData = type(opt.buttons) == "table" and opt.buttons or {}

    local dialogGroup = display.newGroup()
    dialogGroup.x = sw / 2
    dialogGroup.y = sh / 2
    dialogGroup.isHitTestable = true
    dialogGroup:addEventListener("touch", function() return true end)

    local bgSize = math.max(display.contentWidth, display.contentHeight) * 2
    local bg = display.newRoundedRect(dialogGroup, 0, 0, bgSize, bgSize, 4)
    bg:setFillColor(0, 0, 0, 0.6)
    data.buttons = data.buttons or {}
    if #data.buttons > 0 then
        bg.isHitTestable = true
    else
        bg:addEventListener("touch", function() dialogGroup:close() end)
    end
	
	dialogGroup.contentWidth = dialogW


    local rect = display.newRoundedRect(dialogGroup, 0, 0, dialogW, 50, 8)
    rect.anchorX = 0.5
    rect.anchorY = 0
    rect:setFillColor(color.bg[1], color.bg[2], color.bg[3])

    -- Анимация появления
    dialogGroup.alpha = 0
    dialogGroup.y = dialogGroup.y + vel
    transition.to(dialogGroup, {transition = easing.outQuad, time = 225, alpha = 1, y = sh / 2})

    local headerText = display.newText({
        parent = dialogGroup,
        text = headerStr, width = dialogW - pad * 2,
        x = 0, y = 0, fontSize = app.fontsize2, font = app.fontBold,
    })
    headerText.anchorX = 0.5; headerText.anchorY = 0
    headerText:setFillColor(color.header[1],color.header[2],color.header[3])

    local descText = display.newText({
        parent = dialogGroup,
        text = descStr, width = dialogW - pad * 2,
        x = 0, y = 0, fontSize = math.floor(app.fontsize1 / 1.1), font = app.font
    })
    descText.anchorX = 0.5; descText.anchorY = 0
    descText:setFillColor(color.description[1],color.description[2],color.description[3])

    -- Контейнер для пользовательского контента
    local contentContainer = display.newGroup()
    contentContainer.anchorX = 0.5
    contentContainer.anchorY = 0
    contentContainer.x = 0
    contentContainer.y = 0
    dialogGroup:insert(contentContainer)

    local innerContent = display.newGroup()
    innerContent.anchorX = 0.5
    innerContent.anchorY = 0.5
    innerContent.x = 0
    innerContent.y = 0
    contentContainer:insert(innerContent)

    dialogGroup.innerContent = innerContent
    dialogGroup.contentContainer = contentContainer

    local bottomGroup = display.newGroup()
    bottomGroup.x = 0
    bottomGroup.anchorX = 0.5
    bottomGroup.anchorY = 0
    dialogGroup:insert(bottomGroup)

    local btns = {}
    for i = 1, #buttonsData do
        local b = buttonsData[i]
        local textis = utf8.upper(tostring(b.text or ""))
        local test = display.newText({
            x = 0,
            y = 0,
            fontSize = math.floor(app.fontsize1 / 1.1),
            text = textis,
			font = app.font
        })
        local btn = PonosUi.newButton(function(e)
            if e.phase == "ended" then
                if b.callback then b.callback() end
                dialogGroup:close()
            end
        end,
        {
            x = 0,
            y = 40,
            text = textis,
            width = test.width + pad / 2,
            height = 50,
            alpha = 0,
            rounded = 30,
            fontSize = math.floor(app.fontsize1 / 1.25),
			colorTxt = color.buttonText
        }, bottomGroup)
        display.remove(test)

        btn.anchorX = 0.5
        btn.anchorY = 0
        btns[#btns + 1] = {btn = btn}
    end

    local isClosing = false
	dialogGroup.customUserContentHeight = false

    local function recalc()
        local spacing = pad / 2

        local hTextH = (headerStr ~= "") and headerText.height or 0
        local dTextH = (descStr ~= "") and descText.height or 0

        local contentH = 0
        local contentTopOffset = 0

        if innerContent and innerContent.numChildren > 0 then
		    if dialogGroup.customUserContentHeight then
            contentH = dialogGroup.customUserContentHeight
			else
			contentH = innerContent.height
			end
			
			contentContainer.height = innerContent.height
        end

        local btnH = (#btns > 0) and btns[1].btn.height or 0

        local totalH = pad * 2
        local elementsCount = 0

        if hTextH > 0 then totalH = totalH + hTextH; elementsCount = elementsCount + 1 end
        if dTextH > 0 then totalH = totalH + dTextH; elementsCount = elementsCount + 1 end
        if contentH > 0 then totalH = totalH + contentH; elementsCount = elementsCount + 1 end
        if btnH > 0 then totalH = totalH + btnH; elementsCount = elementsCount + 1 end

        if elementsCount > 1 then
            totalH = totalH + (elementsCount - 1) * spacing
        end

        rect.height = totalH
        rect.y = -totalH / 2

        local currentY = rect.y + pad

        if hTextH > 0 then
            headerText.y = currentY
            currentY = currentY + hTextH + spacing
            headerText.isVisible = true
        else
            headerText.isVisible = false
        end

        if dTextH > 0 then
            descText.y = currentY
            currentY = currentY + dTextH + spacing
            descText.isVisible = true
        else
            descText.isVisible = false
        end

        if contentH > 0 then
            contentContainer.y = currentY
            innerContent.y = contentH / 2
            currentY = currentY + contentH + spacing
        end

        if btnH > 0 then
            bottomGroup.y = totalH/2-bottomGroup.height-app.pad
            local slotW = (dialogW - pad * 2) / #btns
            local startX = -dialogW / 2 + pad + slotW / 2
            for i, b in ipairs(btns) do
                b.btn.x = startX + (i - 1) * slotW
                b.btn.y = 0
            end
        end
    end

    recalc()
    dialogGroup.recalc = recalc
	
	dialogGroup.insert = function(self, object)
	    innerContent.enable = true
        innerContent:insert(object)
        timer.performWithDelay(1, function()
            if self.recalc then
                self:recalc()
            end
        end)
        return object
    end

    dialogGroup.close = function()
        if isClosing then return end
        isClosing = true
        transition.to(dialogGroup, {y = sh / 2 - vel / 1.5, time = 290, alpha = 0, transition = easing.outQuad, onComplete = function() display.remove(dialogGroup) end})
    end
	
	dialogGroup.dialogW = dialogW

    return dialogGroup
end

new_variants = function(data, buttons, callback)
    local dialog = new_dialog(data)
    local dialogCC = display.newGroup()
    buttons = buttons or {}
    local btnHeight = 60
    
    for j = 1, #buttons do
        local item = buttons[j]
        local text = item[2]
        local id = item[1]
        local btn = PonosUi.newButton(function(event)
            if event.phase == "ended" then
			    if math.abs(event.yDelta+event.yDelta)<btnHeight/2 then
                    callback(id)
                    dialog.close()
				end
				display.getCurrentStage():setFocus(nil)
			elseif event.phase == 'began' then
			    display.getCurrentStage():setFocus(event.target)
            end
        end, {
            x = 0, y = (j - 1) * (btnHeight + app.pad),
            width = dialog.contentWidth - app.pad * 2, height = btnHeight,
            text = text, fontSize = app.fontsize1, colorBg = {0, 0, 0},
            alpha = 0.2, rounded = 10, text_align = "left"
        }, dialogCC)
    end
    dialog:insert(dialogCC)
    dialogCC.y = -dialogCC.height/2+app.pad/2+btnHeight/2
    dialog:recalc()
	return dialog
end

new_input_alert = function( data, func, isField ) 
    local data = data or {header = app.words[223] or "."}
    local headerStr = tostring(data.header or "")
    local descStr = tostring(data.description or "")
    local buttonsData = type(data.buttons) == "table" and data.buttons or {}

    local dialogGroup = display.newGroup()
    dialogGroup.x = sw/2
    dialogGroup.y = sh/2
    dialogGroup.isHitTestable = true
    dialogGroup:addEventListener("touch", function(e) return true end)

    local bgSize = math.max(display.contentWidth, display.contentHeight) * 2
    local bg = display.newRoundedRect(dialogGroup,0, 0, bgSize, bgSize, 4)
    bg:setFillColor(0, 0, 0, 0.6)
    bg.isHitTestable = true
    dialogGroup:insert(bg)


    local rect = display.newRoundedRect(0, 0, dialogW, 50, 8)
    rect.anchorX = 0.5
    rect.anchorY = 0
    rect:setFillColor(color.bg[1],color.bg[2],color.bg[3])
    dialogGroup:insert(rect)

    dialogGroup.alpha = 0
	dialogGroup.y = dialogGroup.y+vel
    transition.to(dialogGroup, {transition = easing.outQuad,time = 225, alpha = 1, y = sh/2})

    local headerText = display.newText({
        text = headerStr, width = dialogW - pad*2,
        x = 0, y = 0, fontSize = app.fontsize2, font = app.fontBold,
    })
    headerText.anchorX = 0.5; headerText.anchorY = 0
    headerText:setFillColor(color.header[1],color.header[2],color.header[3])
    dialogGroup:insert(headerText)

    local descText = display.newText({
        text = descStr, width = dialogW - pad*2,
        x = 0, y = 0, fontSize = math.floor(app.fontsize1/1.1),font = app.font
    })
    descText.anchorX = 0.5; descText.anchorY = 0
    descText:setFillColor(color.header[1],color.header[2],color.header[3])
    dialogGroup:insert(descText)

    local isClosing = false
	
	local buttonsGroup = display.newGroup()
	dialogGroup:insert(buttonsGroup)
	local inputBox
	local ok = PonosUi.newButton(function(e)
		    if e.phase == "ended" then 
			    if func then func(inputBox.text); dialogGroup:close() end
			end 
		end, 
		{   x = 0, 
		    y = 40, 
			text = utf8.upper(app.words[224]), 
			width = 100, 
			height = 50, 
			alpha = 0,
			rounded = 30,
			colorTxt = color.buttonText
		}, buttonsGroup)
		ok.anchorY = 1
    local input = display.newGroup()
	dialogGroup:insert(input)
	local inputHeight = isField and 75 or 150
	local inputRect = display.newRoundedRect(input, 0, 0, rect.width-pad*2, inputHeight, 8)
    inputRect.alpha = 0.4
	inputRect:setFillColor(0,0,0)
	local inputLine = display.newRect(input, 0, inputRect.height/2-pad/2, inputRect.width- pad,4)
	if isField then
	    inputBox = native.newTextField(0, 0, inputRect.width- pad, inputRect.height-pad)
	else
	    inputBox = native.newTextBox(0, 0, inputRect.width- pad, inputRect.height-pad)
	end
	inputBox.isEditable = true
    inputBox.hasBackground = false
	inputBox.size = 25
	if utils.isSim or utils.isWin then
        inputBox:setTextColor(0, 0, 0)
        inputBox.size = 25
    else
        inputBox:setTextColor(1, 1, 1)
    end
	input:insert(inputBox)
	
	native.setKeyboardFocus(inputBox)
	
	
    local function recalc()
        
        local hTextH = (headerStr ~= "") and headerText.height or 0
        local dTextH = (descStr ~= "") and descText.height or 0
		
		local inputH = input.height+pad*2 or 0
		local btnH = buttonsGroup.height
		
		local totalH = pad*1.5+hTextH + dTextH + inputH + btnH
		
		buttonsGroup.y = totalH/2-btnH
		
		rect.height = totalH
		rect.y = -totalH/2
		
		input.y = buttonsGroup.y - inputH/2
		
		headerText.y = -totalH/2+pad
		descText.y = headerText.y + pad/2 + hTextH
		
    end
    
    recalc()
    
	local link_old_fun = special_back_fun
	
    dialogGroup.close = function()
        if isClosing then return end
        isClosing = true
		display.remove(inputBox)
        transition.to(dialogGroup, {y = sh/2-vel/1.5, time = 290, alpha = 0,transition = easing.outQuad, onComplete = function() display.remove(dialogGroup) end})
		special_back_fun = link_old_fun
		native.setKeyboardFocus(nil)
    end
	dialogGroup.text = function(text)
	    inputBox.text = text
    end
	
	dialogGroup.dialogW = dialogW
	
	special_back_fun = function() dialogGroup.close() end
    
    return dialogGroup
end

local alerts = {}
local alertwidth = math.min(app.content / 2, 300)
local alertheight = 86

local function recalculate_warings()
    for i = 1, #alerts do
        local alertGroup = alerts[i]
        
        if alertGroup.moveTransition then
            transition.cancel(alertGroup.moveTransition)
        end
        
        local targetY = sh - app.pad - alertheight/2 - (#alerts * (alertheight + app.pad)) + i*(alertheight + app.pad)- getBottomNavHeight()
        
        alertGroup.moveTransition = transition.to(alertGroup, {
            y = targetY, 
            alpha = 1, 
            time = 300, 
            transition = easing.outQuad,
            onComplete = function()
                if alertGroup then
                    alertGroup.moveTransition = nil
                end
            end
        })
        
        alertGroup.button.my_i = i
    end
end

new_warning = function(text, callback)
    local group = display.newGroup()
    
    local t = {
        startT = 0,
        startO = 0
    }
    
    local alert
    alert = PonosUi.newButton( function(event)
        local target = event.target
		
		if target.ended == true then return false end

        if event.phase == "began" then
            display.currentStage:setFocus( target )
            target.isFocus = true

            t.startT = event.x
            t.startO = target.x

        elseif target.isFocus then

            if event.phase == "moved" then
                target.x = t.startO + (event.x - t.startT)

            elseif event.phase == "ended" or event.phase == "cancelled" then
                display.currentStage:setFocus( nil )
                target.isFocus = nil

                local current_index = target.my_i
				
				target.ended = true
                
                if group.moveTransition then
                    transition.cancel(group.moveTransition)
                end
				
                table.remove(alerts, current_index)
                recalculate_warings()
                
                transition.to(group, {x = 0, alpha = 0, time = 300, transition = easing.inOutQuad, onComplete = function()
                    display.remove(group)
                    
                    if callback then callback() end
                end})
            end
        end
    end, { x = 0, y = 0, width = alertwidth, height = alertheight, rounded = 27, text = text, font = native.systemFont, fontSize = math.floor(app.fontsize1*0.95), text_align = "left"}, group )
    
	timer.performWithDelay(3000, function() 
	    local current_index = alert.my_i
	    table.remove(alerts, current_index)
        recalculate_warings()
		transition.to(group, {x = 0, alpha = 0, time = 300, transition = easing.inOutQuad, onComplete = function()
            display.remove(group)
        end})
	end, 1)
	
    alert.anchorX = 1
    
    group.button = alert 
	alert.ended = false
    
    group.alpha = 0
    group.y = sh - app.pad - alertheight/2 + getBottomNavHeight()
    
    table.insert(alerts, group)
    
    transition.to(group, {x = alertwidth + app.pad, alpha = 1, time = 300, transition = easing.outQuad})
	recalculate_warings()
end

new_s_warning = function(text)
    local group = display.newGroup()
	
	local bgShadow = display.newRoundedRect(group, 0, 2, 200+6, 65+6, 24)
	bgShadow:setFillColor(0,0,0,0.1)
	local bg = display.newRoundedRect(group, 0, 0, 200, 65, 24)
	bg:setFillColor(color.bg[1] ,color.bg[2], color.bg[3])
	
	local text = display.newText({
	    parent = group,
		x = 0,
		y = 0,
		width = bg.width,
		text = utf8.sub(text, 1, 12),
		fontSize = app.fontsize1,
		align = "center",
		font = app.font
	})
	group.x = sw/2
	local normal_y = sh- 100 - getBottomNavHeight()
	group.y = normal_y+20
	text:setFillColor(app.unpack(app.color.standartTextColor))
	
	group.alpha = 0
	
	transition.to(group, {alpha = 1, y = normal_y, time = 200, transition = easing.outQuad})
	
	timer.performWithDelay(2000, function()
	    transition.to(group, {alpha = 0, time = 200, y = normal_y + 20,  transition = easing.inQuad, onComplete = function()
		    display.remove(group)
		end})
	end)
end