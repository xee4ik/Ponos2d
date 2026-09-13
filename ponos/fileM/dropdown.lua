--[[ модуль всплывающего списка. Очень удобный
     принимает menuItems вида { текст, индекс, иконка } и выводит эту же таблицу нажатого элемента
]]

local defaultWidth = math.min(app.content / 1.8, 250)

function dropdownScroll(groupScene, menuItems, func, params)
    if not groupScene then
        groupScene = display.newGroup()
    end
    
    local x = params.x or 0
    local y = params.y or 0
    local width = params.width or defaultWidth
    local height = params.height or 64
	
    local notVisibleRect = display.newRect(groupScene, 0, 0, sw, sh)
    notVisibleRect:setFillColor(0, 0, 0)
    notVisibleRect.alpha = 0
    notVisibleRect.anchorX, notVisibleRect.anchorY = 0, 0
    
    local groupMenu = display.newGroup()
    groupMenu.x, groupMenu.y = x, y
    groupMenu.alpha = 0
	
    local buttonContainer = display.newContainer(width, height)
    buttonContainer.anchorX, buttonContainer.anchorY = 0, 0.5
    buttonContainer.isVisible = false
    groupMenu:insert(buttonContainer)

    local buttonCircle = display.newCircle(0, 0, width / 2)
    buttonCircle:setFillColor(unpack(app.color.dropdown.ripple))
    buttonCircle.xScale, buttonCircle.yScale, buttonCircle.alpha = 0.25, 0.25, 0
    buttonContainer:insert(buttonCircle)
	
    local scrollHeight = math.min(#menuItems * height, sh - y - getBottomNavHeight() - 20)
    local buttonsScroll = PonosUi.newScrollView({
        x = width/2,
        y = 0,
        width = width,
        height = scrollHeight,
        horizontalScrollDisabled = true,
    })
    groupMenu:insert(buttonsScroll)

    local buttons = {}

    local function touchTypeFunction(event)
        local target = event.target
        
        if event.phase == "began" then
            target.isDrag = false
			buttonsScroll:stop()
            
            buttonContainer.isVisible = true
            buttonContainer:toFront()
            
            local screenX, screenY = target:localToContent(0, 0)
            local localX, localY = groupMenu:contentToLocal(screenX, screenY)
            buttonContainer.x = 0
            buttonContainer.y = localY + height / 2
            
            buttonCircle.xScale, buttonCircle.yScale, buttonCircle.alpha = 0.25, 0.25, 1
            local lx, ly = buttonContainer:contentToLocal(event.x, event.y)
            buttonCircle.x, buttonCircle.y = lx, ly
            transition.to(buttonCircle, {transition=easing.outQuad, time=400, xScale=2, yScale=2, alpha=0.3})
            
            display.getCurrentStage():setFocus(target, event.id)
            
        elseif event.phase == "moved" then
            if math.abs(event.x - event.xStart) > 10 or math.abs(event.y - event.yStart) > 10 then
			    buttonsScroll:takeFocus(event)
                target.isDrag = true
                buttonContainer.isVisible = false
            end
            
        elseif event.phase == "ended" or event.phase == "cancelled" then
            display.getCurrentStage():setFocus(target, nil)
            
            if not target.isDrag and func then
                func(target.itemIndex, target.itemData)
            end
            
            for i = 1, #buttons do
                if buttons[i] then
                    buttons[i]:removeEventListener("touch", touchTypeFunction)
                end
            end
            transition.to(notVisibleRect, {time=200, alpha=0, onComplete=function() display.remove(notVisibleRect) end})
            transition.to(groupMenu, {time=200, alpha=0, onComplete=function() display.remove(groupMenu) end})
        end
        
        return true
    end

    for i = 1, #menuItems do
        local btnGroup = display.newGroup()
        btnGroup.anchorX, btnGroup.anchorY = 0, 0
        btnGroup.x = 0
        btnGroup.y = height * (i - 1)
        
        local bg = display.newRect(btnGroup, 0, 0, width, height)
        bg.anchorX, bg.anchorY = 0, 0
        bg:setFillColor(app.color.dropdown.bg[1], app.color.dropdown.bg[2], app.color.dropdown.bg[3])
        
        local iconWidth = 0
        if menuItems[i][3] then
            local icon = display.newImage(btnGroup, menuItems[i][3])
			if not menuItems[i][4] then icon:setFillColor(app.color.dropdown.text[1], app.color.dropdown.text[2], app.color.dropdown.text[3]) end
            icon.width = height / 2
            icon.height = height / 2
            icon.x = height / 2
            icon.y = height / 2
            iconWidth = height
        end
        
        local label = display.newText({
            parent = btnGroup,
            text = menuItems[i][1],
            x = iconWidth + 10,
            y = height / 2,
            width = width - iconWidth - 20,
            fontSize = app.fontsize2 / 1.4,
            align = "left",
			font = app.font
        })
        label.anchorX, label.anchorY = 0, 0.5
		
		label:setFillColor(app.color.dropdown.text[1], app.color.dropdown.text[2], app.color.dropdown.text[3])
        
        btnGroup.itemIndex = i
        btnGroup.itemData = menuItems[i]
        btnGroup.isHitTestable = true
        btnGroup:addEventListener("touch", touchTypeFunction)
        
        buttonsScroll:insert(btnGroup)
        buttons[i] = btnGroup
    end

    if x + width > sw then
        groupMenu.x = sw - width - 10
    end
    if y + scrollHeight > sh - getBottomNavHeight() then
        groupMenu.y = sh - scrollHeight - getBottomNavHeight() - 10
    end

    notVisibleRect:addEventListener("touch", function(event)
        if event.phase == "ended" then
            for i = 1, #buttons do
                if buttons[i] then
                    buttons[i]:removeEventListener("touch", touchTypeFunction)
                end
            end
            transition.to(notVisibleRect, {time=200, alpha=0, onComplete=function() display.remove(notVisibleRect) end})
            transition.to(groupMenu, {time=200, alpha=0, onComplete=function() display.remove(groupMenu) end})
			func(false)
        end
        return true
    end)
	
    groupScene:insert(groupMenu)
    transition.to(notVisibleRect, {time=150, alpha=0.5})
    transition.to(groupMenu, {transition=easing.outQuad, time=200, alpha=1})
end

function dropdown(groupScene, menuItems, func, params)   
	if not groupScene then
	    groupScene = display.newGroup()
	end
    local x = params.x or 0
    local y = params.y or 0
    local width = params.width or defaultWidth
    local height = params.height or 70
	
	if #menuItems * height > sh-getBottomNavHeight() then
	    dropdownScroll(groupScene, menuItems, func, params)
		return false
	end

    local notVisibleRect = display.newRect(groupScene, 0,0,0,0)
    notVisibleRect.x, notVisibleRect.y, notVisibleRect.width, notVisibleRect.height =
        0, 0, sw, sh
	notVisibleRect:setFillColor(0,0,0)
	notVisibleRect.alpha = 0.01
	notVisibleRect.anchorX = 0
	notVisibleRect.anchorY = 0
	transition.to(notVisibleRect, {time = 150, alpha = 0.5})

    local groupMenu = display.newGroup()
    groupMenu.x, groupMenu.y = x, y
    groupMenu.xScale, groupMenu.yScale, groupMenu.alpha = 0.3, 0.3, 0

    local buttons = {}

    local buttonContainer = display.newContainer(width, height)
    buttonContainer.anchorX, buttonContainer.anchorY = 1, 0.5
    groupMenu:insert(buttonContainer)

    local buttonCircle = display.newCircle(0, 0, width / 2)
    buttonCircle:setFillColor(unpack(app.color.dropdown.ripple))
    buttonCircle.xScale, buttonCircle.yScale, buttonCircle.alpha = 0.25, 0.25, 0
    buttonContainer:insert(buttonCircle)
	
	local touchtimer = 0

    local function touchTypeFunction(event)
        if event.phase == "began" then
            buttonContainer:toFront()
            buttonContainer.y = event.target.y
			buttonCircle.xScale = 0.25
			buttonCircle.yScale = 0.25
			buttonCircle.alpha = 1
			local lx, ly = buttonContainer:contentToLocal(event.x, event.y)
			buttonCircle.x = lx
			buttonCircle.y = ly
            transition.to(buttonCircle, {transition = easing.outQuad,time = 400, xScale = 2, yScale = 2, alpha = 0.3})
			event.target.timer = true
        elseif event.phase == "moved" then
		    if event.target.timer then
			     event.target.timer = false
                 transition.to(buttonCircle, {time = 400, alpha = 0, onComplete = function() event.target.timer = true end})
			end
        else
            if func then
                func(event.target.itemIndex, event.target.itemData)
            end

            for i = 1, #buttons do
                buttons[i]:removeEventListener("touch", touchTypeFunction)
            end
            transition.to(notVisibleRect, {transition = easing.outQuad,time = 200, alpha = 0, onComplete = function() display.remove(notVisibleRect) end})
            transition.to(groupMenu, {transition = easing.inQuad,time = 200, alpha = 0, onComplete = function() display.remove(groupMenu) end})
        end
        return true
    end
	
	if params.title then
	    local title = display.newText({
		    parent = groupMenu,
			x = app.pad,
			y = -app.pad/2,
			width = width,
			text = params.title,
			fontSize = fontsize2,
			font = app.font
		})
		title.anchorY = 1
		title.anchorX = 1
	end

    for i = 1, #menuItems do
        buttons[i] = display.newRect(0, height * (i - 1), width, height)
        buttons[i].anchorX, buttons[i].anchorY = 1, 0.5
        buttons[i]:setFillColor(app.color.dropdown.bg[1], app.color.dropdown.bg[2], app.color.dropdown.bg[3])
        groupMenu:insert(buttons[i])
        
        buttons[i].itemIndex = i
        buttons[i].itemData = menuItems[i]
        buttons[i]:addEventListener("touch", touchTypeFunction)
        buttons[i].bigger = 1 / 0.3
		
		local iconWidth = height/3
		if menuItems[i][3] then
		   iconWidth = height
		end

        buttons[i].header = display.newText({
		    text = menuItems[i][1], 
			x = -width + iconWidth, 
			y = height * (i - 1) , 
			font = nil, 
			fontSize = app.fontsize2/1.4,
			width = width - iconWidth - height/3,
			font = app.font
		})
        buttons[i].header.anchorX = 0
        groupMenu:insert(buttons[i].header)
		buttons[i].header:setFillColor(app.color.dropdown.text[1], app.color.dropdown.text[2], app.color.dropdown.text[3])

        if menuItems[i][3] then
            buttons[i].icon = display.newImage(menuItems[i][3])
			if not menuItems[i][4] then buttons[i].icon:setFillColor(app.color.dropdown.text[1], app.color.dropdown.text[2], app.color.dropdown.text[3]) end
            buttons[i].icon.y = height * (i - 1)
            buttons[i].icon.width = height/2
            buttons[i].icon.height = height/2
            buttons[i].icon.x = -width+height/2
            groupMenu:insert(buttons[i].icon)
        end
    end
    
    local newX = x
    if x-width < 0 then
        newX = width
    end
	
	local newY = y
    if y+(height * #menuItems) > sh then
        newY = sh-(height * #menuItems)
    end
	
    notVisibleRect:addEventListener("touch", function(event)
        if event.phase == "ended" then
		    notVisibleRect.isHitTestable = true
            transition.to(notVisibleRect, {transition = easing.outQuad,time = 200, alpha = 0, onComplete = function() display.remove(notVisibleRect) end})
            for i = 1, #buttons do
                buttons[i]:removeEventListener("touch", touchTypeFunction)
            end
            transition.to(groupMenu, {transition = easing.outQuad,time = 200, alpha = 0, onComplete = function() display.remove(groupMenu) end})
			func(false)
        end
        return true
    end)
	
    transition.to(groupMenu, {transition = easing.outQuad,time = 200, x = newX, y = newY, xScale = 1, yScale = 1, alpha = 1, transition = easing.outQuad})

    groupScene:insert(groupMenu)
end