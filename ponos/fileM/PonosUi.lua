local M = {}
local maskCache = {}
local unpack = unpack or table.unpack

-- Вспомогательные функции

local function setColor(obj, val)
obj:setFillColor(val[1], val[2], val[3], val[4] or 1)
end

local function getRoundedMask(w, h, r)
    local cx = display.contentScaleX
    local cy = display.contentScaleY
    
    local padding = 12
    
    local pxW = math.ceil((w + padding) / cx)
    pxW = pxW + (4 - (pxW % 4)) % 4
    
    local pxH = math.ceil((h + padding) / cy)
    pxH = pxH + (4 - (pxH % 4)) % 4
    
    local mw = pxW * cx
    local mh = pxH * cy

    local fname = "PonosMasks/ponos_mask_" .. pxW .. "x" .. pxH .. "_w" .. math.ceil(w) .. "_h" .. math.ceil(h) .. "_r" .. math.ceil(r) .. ".png"

    if maskCache[fname] then
        return graphics.newMask(fname, system.DocumentsDirectory)
    end

    local path = system.pathForFile(fname, system.DocumentsDirectory)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        maskCache[fname] = true
        return graphics.newMask(fname, system.DocumentsDirectory)
    end

    local tempGroup = display.newGroup()
    
    tempGroup.x = display.contentCenterX
    tempGroup.y = display.contentCenterY
    
    local bg = display.newRect(tempGroup, 0, 0, mw, mh)
    bg:setFillColor(0, 0, 0)
    
    local shape = display.newRoundedRect(tempGroup, 0, 0, w, h, r)
    shape:setFillColor(1, 1, 1)
    
    display.save(tempGroup, {
        filename = fname, 
        baseDir = system.DocumentsDirectory, 
        isFullResolution = false,
        captureOffscreenArea = true
    })
    
    display.remove(tempGroup)
    
    maskCache[fname] = true
    return graphics.newMask(fname, system.DocumentsDirectory)
end

-- Функции создания элементов интерфейса

function M.newButton(func, params, parentGroup)
    local width = params.width or 100
    local height = params.height or 40
    local x = params.x or 0
    local y = params.y or 0
    local alpha = params.alpha or 1
    local style = params.style or "default"
	local linewidth
	if params.line_width then
	    linewidth = params.line_width
	else
	    linewidth = 2
	end
	
	local rounded = params.rounded or 0
	local colorBg = params.colorBg or {app.color.btnBgColor[1],app.color.btnBgColor[2],app.color.btnBgColor[3]}
	local colorTxt = params.colorTxt or {app.color.btnTextColor[1],app.color.btnTextColor[2],app.color.btnTextColor[3]}
    local font = params.font or app.font
    local fontSize = params.fontSize or math.min(36, math.min(width,height)/2.5)
	local text_align = params.text_align
	
	if style ~= "default" then
	    if style == "list" then
		    colorBg = app.color.listBgColor
		end
		if style == "del" then
		    colorBg = app.color.btnDelBgColor
		end
		if style == "copy" then
		    colorBg = app.color.btnCopyBgColor
		end
	end

    local container = display.newContainer(width, height)
    container.x = x or display.contentCenterX
    container.y = y or display.contentCenterY
    
    if parentGroup and parentGroup.insert then
        parentGroup:insert(container)
    end

    local button = display.newGroup()
    if rounded > 0 then
        local mask = getRoundedMask(width, height, rounded)
        button:setMask(mask)
        button.maskScaleX = display.contentScaleX
        button.maskScaleY = display.contentScaleY
        button.maskX, button.maskY = 0, 0
    end
    container:insert(button)

    local bgRect
    if rounded > 0 then
        bgRect = display.newRoundedRect(button, 0, 0, width, height, rounded)
    else
        bgRect = display.newRect(button, 0, 0, width, height)
		if alpha >0.2 then bgRectline = display.newRect(button, 0, height/2-linewidth/2, width, linewidth); bgRectline:setFillColor(unpack(app.color.lineColor) ) end
    end

    bgRect.anchorX, bgRect.anchorY = 0.5, 0.5
    bgRect:setFillColor(unpack(colorBg))
    bgRect.alpha = alpha
    
    local iconParams = params.icon or {}
    local iconPath = iconParams.path
    local iconPos = iconParams.position or (iconPath and "center")
    local iconSize = iconParams.size or height/1.5
	local iconSaveColor = iconParams.saveColor or false

    local textX, textY = 0, 0
    local textWidth = width * 0.9
    local textHeight = height * 0.8
    local hasIconLeftRight = false
    local icon

    if iconPos ~= "none" and iconPath then
        icon = display.newImageRect(container, iconPath, iconSize, iconSize)
        if not iconSaveColor then icon:setFillColor(unpack(colorTxt)) end
		
        if icon then
            icon.anchorX, icon.anchorY = 0.5, 0.5
            local paddingIcon = math.min(height, width)/8
            if iconPos == "left" then
                icon.x = -(width / 2) + (iconSize / 2) + paddingIcon
                textWidth = width - (iconSize + paddingIcon * 3)
                textX = (iconSize) / 2 + paddingIcon/2
                hasIconLeftRight = true
            elseif iconPos == "right" then
                icon.x = (width / 2) - (iconSize / 2) - paddingIcon
                textWidth = width - (iconSize + paddingIcon * 3)
                textX = -(iconSize / 2 ) / 2
                hasIconLeftRight = true
            elseif iconPos == "center" then
                icon.x, icon.y = 0, 0
                hasIconLeftRight = true
            elseif iconPos == "top" then
                icon.y = -(height / 2) + (iconSize / 2) + paddingIcon
                textY = (iconSize / 2 + paddingIcon) / 2
                textHeight = height - (iconSize + paddingIcon * 2)
            elseif iconPos == "bottom" then
                icon.y = (height / 2) - (iconSize / 2) - paddingIcon
                textY = -(iconSize / 2 + paddingIcon) / 2
                textHeight = height - (iconSize + paddingIcon * 2)
            end
        end
    else
        hasIconLeftRight = true
    end

    local btnText = display.newText({
        parent = container,
        text = params.text or "",
        x = textX,
        y = textY,
        font = font,
        fontSize = fontSize,
        width = math.max(textWidth, 40),
        align = text_align or "center"
    })
    btnText.anchorX, btnText.anchorY = 0.5, 0.5
    btnText:setFillColor(unpack(colorTxt))

    if iconPos == "center" and iconPath then
    elseif not hasIconLeftRight then
        btnText.height = math.max(textHeight, 30)
    end
	
	if icon then
	    container.icon = icon
	    icon.origx = icon.x
	end
	
    local function onTouch(event)
        if func then func(event) end
        if event.phase == "began" then
            local lx, ly = button:contentToLocal(event.x, event.y)
            local rippleRect = display.newCircle(button, lx, ly, math.max(width, height))
			
			rippleRect:setFillColor(unpack(app.color.buttonRippleColor))
            
            rippleRect.anchorX, rippleRect.anchorY = 0.5, 0.5
            rippleRect.isHitTestable = false
            rippleRect.alpha = 0.3
            rippleRect.width, rippleRect.height = 4, 4
			
			rippleRect.xScale = 0.1
			rippleRect.yScale = 0.1

            local targetW = 1
			local targetH = 1
			local time = 430 --math.min(math.max(width, height)*2, 800)

            transition.to(rippleRect, { time = time, xScale = targetW, yScale = targetH, transition = easing.outQuad })
            transition.to(rippleRect, { time = 800, alpha = 0, transition = easing.outQuad, onComplete = function() display.remove(rippleRect) end })
        end

        if event.phase == "ended" then
            event.posx, event.posy = container.x, container.y
        end
        return true
    end
	

    container:addEventListener("touch", onTouch)
    
    container.podsvetka = "btn"
    container.rounded = rounded
	
	container.setIcon = function(pararam)
	    local origx = icon.origx
	    transition.to(icon, {alpha = 0.1, x = origx+10, time = 167, transition = easing.inQuad, onComplete = function()
		    icon.fill = {
		        type = "image",
		        filename = pararam.path
		    }
			icon.x = origx-15
			transition.to(icon, { alpha = 1, x = origx, transition = easing.outBack, time = 360 })
		end})
	end
    
    function container:setBgFillColor(r, g, b, a)
        bgRect:setFillColor(r, g, b, a)
    end 
	
	function container:setButtonText(t)
        btnText.text = t
    end 
    
    return container
end

function M.newCheckBox(func, params)
    if not params then return nil end

    local x = params.x or display.contentCenterX
    local y = params.y or display.contentCenterY
    local startActive = params.active
    local size = params.size or 40

    local checkBox = display.newGroup()

    local iconInactive = display.newImageRect(checkBox, "res/widget/checkbox_1.png", size, size)
	iconInactive:setFillColor(unpack(app.color.checkBoxColor.inactive))
    local iconActive = display.newImageRect(checkBox, "res/widget/checkbox_2.png", size, size)
	iconActive:setFillColor(unpack(app.color.checkBoxColor.active))

    iconInactive.x, iconInactive.y = 0, 0
    iconActive.x, iconActive.y = 0, 0

    local isActive = startActive
    iconInactive.isVisible = not isActive
    iconActive.isVisible = isActive
	
	checkBox.click = function() 
	    isActive = not isActive
        iconInactive.isVisible = not isActive
        iconActive.isVisible = isActive 
		if func then
            func({phase = "ended",target = checkBox, active = isActive})
        end
	end

    local function onTouch(event)
        if event.phase == "ended" then
            checkBox.click()
        end
        return true
    end

    checkBox:addEventListener("touch", onTouch)
    checkBox.x = x
    checkBox.y = y
    checkBox.isActive = function() return isActive end

    return checkBox
end

function M.newRadioGroup(params)
    local parent = params.parent
    local options = params.options -- таблица вида { {value, text, icon}, ... }
    local key = params.key
    local currentValue = params.value
    local x = params.x or 0
    local y = params.y or 0
    local fontSize = params.fontSize or app.fontsize1
    local title = params.title
    local titleFontSize = params.titleFontSize or app.fontsize1 * 1.1
    local callback = params.callback
    
    local radioSize = 35
    local group = display.newGroup()
    parent:insert(group)
    group.x = x
    group.y = y
    
    local yOffset = 0
    
    if title then
        local titleLabel = display.newText({
            parent = group,
            text = title,
            x = 0,
            y = yOffset + titleFontSize/2,
            fontSize = titleFontSize,
            align = "left",
			font = app.font
        })
        titleLabel.anchorX = 0
        titleLabel:setFillColor(unpack(app.color.standartTextColor))
        yOffset = yOffset + titleLabel.height + app.pad*2
    end
    
    local radioButtons = {}
	
	local line = display.newRect(group,0,yOffset-app.pad,2, #options*(radioSize+app.pad)+app.pad)
	line.anchorY = 0
	line:setFillColor(unpack(app.color.lineColor))
    
    for k = 1, #options do
        local option = options[k]
        local optionValue = option[1]
        local optionText = option[2]
        local optionIcon = option[3]
        
        local radioBtn = display.newGroup()
        group:insert(radioBtn)
        radioBtn.x = app.pad+radioSize/2
        radioBtn.y = yOffset + radioSize/2
        
        local circleBg = display.newCircle(radioBtn, 0, 0, radioSize/2)
        setColor(circleBg, app.color.radioButton.bg)
        circleBg.strokeWidth = app.color.radioButton.strokeWidth
        circleBg:setStrokeColor(app.color.radioButton.strokeColor[1],app.color.radioButton.strokeColor[2],app.color.radioButton.strokeColor[3])
        
        local circleInner = display.newCircle(radioBtn, 0, 0, radioSize/4)
        circleInner:setFillColor(unpack(app.color.radioButton.accentColor))
        circleInner.alpha = (optionValue == currentValue) and 1.0 or 0.0
        
        local iconDisplay = nil
        if optionIcon then
            iconDisplay = display.newImageRect(radioBtn, optionIcon, radioSize, radioSize)
            iconDisplay.x = radioSize + app.pad
            iconDisplay.y = 0
        end
        
        local optionLabel = display.newText({
            parent = radioBtn,
            text = optionText,
            x = radioSize + (iconDisplay and 45 or app.pad),
            y = 0,
            fontSize = fontSize,
            align = "left",
			font = app.font
        })
        optionLabel.anchorX = 0
        optionLabel:setFillColor(unpack(app.color.standartTextColor))
        
        radioBtn.optionValue = optionValue
        radioBtn.circleInner = circleInner
        radioButtons[k] = radioBtn
        
        radioBtn:addEventListener("touch", function(event)
            if event.phase == "ended" then
                for m = 1, group.numChildren do
                    local child = group[m]
                    if child and child.circleInner then
					    transition.to(child.circleInner, {alpha = 0, xScale = 0.5, yScale = 0.5, time = 100})
                        --child.circleInner.alpha = 0.0
                    end
                end
				transition.to(circleInner, {alpha = 1, xScale = 1, yScale = 1, time = 100})
                if callback then
                    callback(optionValue)
                end
            end
            return true
        end)
        
        local btnHeight = math.max(radioSize, optionLabel.height) + app.pad
        yOffset = yOffset + btnHeight
    end
    
    group.getValue = function()
        for m = 1, group.numChildren do
            local child = group[m]
            if child and child.circleInner and child.circleInner.alpha == 1.0 then
                return child.optionValue
            end
        end
        return nil
    end
    
    group.setValue = function(value)
        for m = 1, group.numChildren do
            local child = group[m]
            if child and child.circleInner then
                child.circleInner.alpha = (child.optionValue == value) and 1.0 or 0.0
            end
        end
    end
    
    return group
end

function M.newSlider(func, params)
    local x = params.x or 0
    local y = params.y or 0
    local width = params.width or 400
    local height = params.height or 10
    local min = params.min or 0
    local max = params.max or 100
    local value = params.value or min

    local Slider = display.newGroup()

    local background = display.newRoundedRect(Slider, 0, 0, width, height, height/2)
    background:setFillColor(0.2/2, 0.6/2, 0.9/2)
    background.x = x + width/2
    background.y = y

    local thumbSize = height * 1.3
    local thumb = display.newCircle(Slider, 0, 0, thumbSize)
    thumb:setFillColor(1, 1, 1)
    local thumb2 = display.newRoundedRect(Slider, 0, 0, thumbSize * 2, thumbSize * 2, 999)
    thumb2:setFillColor(1, 1, 1, 0.2)
    thumb2.anchorX = 0.5
    thumb2.anchorY = 0.5

    local function updateThumbPosition(val)
        local ratio = (val - min) / (max - min)
        thumb.x = x + ratio * width
        thumb2.x = x + ratio * width
        thumb.y = y
        thumb2.y = y
        Slider.value = math.floor(val*100)/100
    end

    updateThumbPosition(value)

    Slider.min = min
    Slider.max = max
    Slider.width = width
    Slider.xPos = x
    Slider.func = func
    Slider.value = value

    local delta
    local isAnimating = false

    local function onTouch(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(event.target)
            event.target.isFocus = true
            delta = thumb.x - event.x

                transition.to(thumb2, {
                    time = 100,
                    width = thumbSize * 4,
                    height = thumbSize * 4,

                })

        elseif event.target.isFocus then
            if event.phase == "moved" then
                local rawX = event.x + delta
                local clampedX = math.max(x, math.min(x + width, rawX))
                local ratio = (clampedX - x) / width
                local newVal = min + ratio * (max - min)
                updateThumbPosition(newVal)
                if Slider.func then Slider.func(Slider.value) end
            elseif event.phase == "ended" or event.phase == "cancelled" then
                display.getCurrentStage():setFocus(nil)
                event.target.isFocus = false

                    transition.to(thumb2, {
                        time = 150,
                        width = thumbSize * 2,
                        height = thumbSize * 2,

                    })

            end
        end
        return true
    end

    thumb:addEventListener("touch", onTouch)
	background:addEventListener("touch", onTouch)

    return Slider
end

function M.newScrollView(options)
    options = options or {}
    local mAbs, mMax, mMin, mSin, mPi = math.abs, math.max, math.min, math.sin, math.pi
    local predefinedStyles = {
        default = { thickness = 10, color = { 1, 1, 1, 0.4 }, cornerRadius = 10, strokeWidth = 0, strokeColor = { 0, 0, 0, 0 } }
    }

    local width = options.width or 100
    local height = options.height or 100
    local friction = options.friction or 0.95
    local listener = options.listener

    local padTop = options.topPadding or 0 
    local padBot = options.bottomPadding or 0 
    local padLeft = options.leftPadding or 0 
    local padRight = options.rightPadding or 0 

    local noHScroll = options.horizontalScrollDisabled or false 
    local noVScroll = options.verticalScrollDisabled or false 
    local vVelOffset = options.verticalVel or 0
    local hVelOffset = options.horizontalVel or 0

    local touchThreshold = 0

    local scrollView = display.newGroup()
    scrollView.x, scrollView.y = options.x or 0, options.y or 0
    
    local viewContainer = display.newContainer(width, height)
    viewContainer.anchorChildren = false
    viewContainer.anchorX, viewContainer.anchorY = 0, 0
    viewContainer.x, viewContainer.y = -width / 2, 0
    scrollView:insert(viewContainer)

    local content = display.newGroup()
    content.anchorChildren = false
    viewContainer:insert(content)
    
    local fixed = display.newGroup()
    scrollView:insert(fixed)

    scrollView.content = content
    scrollView.view = viewContainer

    local bgRect = display.newRect(viewContainer, width / 2, height / 2, width, height)
    bgRect:setFillColor(0, 0, 0, 0.01)
    bgRect.isHitTestable = true
    bgRect:toBack()

    content.friction = friction
    content.velocityX, content.velocityY, content.vy = 0, 0, 0
    content.isFocus = false
    content.hasMovedThreshold = false 
    content.upperLimit, content.lowerLimit = 0, 0
    content.leftLimit, content.rightLimit = 0, 0

    local showBars = options.showScrollbars ~= false
    local styleOpt = options.scrollBarStyle or "default"
    local activeStyle = (type(styleOpt) == "string" and predefinedStyles[styleOpt]) or (type(styleOpt) == "table" and styleOpt) or predefinedStyles.default

    local barThick = activeStyle.thickness or 6
    local barCol = activeStyle.color or {0.6, 0.6, 0.6, 0.6}
    local barRad = activeStyle.cornerRadius or (barThick / 2)
    local barStW = activeStyle.strokeWidth or 0
    local barStC = activeStyle.strokeColor or {0, 0, 0, 1}

    local vBar, hBar
    if showBars then
        if not noVScroll then
            vBar = display.newRoundedRect(fixed, width / 2 - barThick / 2 - 2, 0, barThick, 50, barRad)
            vBar:setFillColor(unpack(barCol))
            if barStW > 0 then vBar.strokeWidth = barStW; vBar:setStrokeColor(unpack(barStC)) end
            vBar.anchorY = 0
            vBar.isHitTestable = true
        end
        if not noHScroll then
            hBar = display.newRoundedRect(fixed, -width / 2, height - barThick / 2 - 2, 50, barThick, barRad)
            hBar:setFillColor(unpack(barCol))
            if barStW > 0 then hBar.strokeWidth = barStW; hBar:setStrokeColor(unpack(barStC)) end
            hBar.anchorX = 0
            hBar.isHitTestable = true
        end
    end

    local targetOSX, targetOSY, currOSX, currOSY = 0, 0, 0, 0

    local function updateScrollbars()
        if vBar then
            local range = content.upperLimit - content.lowerLimit
            vBar.isVisible = range > 0
            if range > 0 then
                local ratio = height / (height + range)
                local barH = mMax(20, height * ratio)
                vBar.height = barH
                
                local scrollR = mMax(0, mMin(1, (content.upperLimit - content.y) / range))
                vBar.y = scrollR * (height - barH)
            end
        end

        if hBar then
            local range = content.leftLimit - content.rightLimit
            hBar.isVisible = range > 0
            if range > 0 then
                local ratio = width / (width + range)
                local barW = mMax(20, width * ratio)
                hBar.width = barW
                
                local scrollR = mMax(0, mMin(1, (content.leftLimit - content.x) / range))
                hBar.x = -width / 2 + scrollR * (width - barW)
            end
        end
    end

    local function updateBounds()
        local cW = scrollView._customScrollWidth or (content.width * (content.xScale or 1))
        local cH = scrollView._customScrollHeight or (content.height * (content.yScale or 1))
        
        content.upperLimit = padTop
        content.leftLimit = padLeft
        content.lowerLimit = mMin(padTop, height - cH - padBot - vVelOffset)
        content.rightLimit = mMin(padLeft, width - cW - padRight - hVelOffset)

        updateScrollbars()
    end

    local enterFrameActive = false
    local function onEnterFrame()
        if content.isFocus then return end
        
        content.velocityX = content.velocityX * content.friction
        content.velocityY = content.velocityY * content.friction
        if mAbs(content.velocityX) < 0.1 then content.velocityX = 0 end
        if mAbs(content.velocityY) < 0.1 then content.velocityY = 0 end
        
        if not noVScroll then
            content.y = content.y + content.velocityY
            if content.y > content.upperLimit then content.y, content.velocityY = content.upperLimit, 0
            elseif content.y < content.lowerLimit then content.y, content.velocityY = content.lowerLimit, 0 end
        end

        if not noHScroll then
            content.x = content.x + content.velocityX
            if content.x > content.leftLimit then content.x, content.velocityX = content.leftLimit, 0
            elseif content.x < content.rightLimit then content.x, content.velocityX = content.rightLimit, 0 end
        end
        
        local moving = mAbs(content.velocityX) > 0.1 or mAbs(content.velocityY) > 0.1
        
        if not moving and not content.isFocus then
            Runtime:removeEventListener("enterFrame", onEnterFrame)
            enterFrameActive = false
            if listener then listener({ name="scrollEvent", type="stopped", target=scrollView }) end
        end
        
        content.vy = content.y
    end

    local function ensureEnterFrame()
        if not enterFrameActive then
            Runtime:addEventListener("enterFrame", onEnterFrame)
            enterFrameActive = true
        end
    end

    local function handleTouch(event, isInternal)
        local phase = event.phase
        
        if phase == "began" or phase == "takeFocus" then
            if not isInternal then display.getCurrentStage():setFocus(content, event.id) end
            
            content.isFocus = true
            ensureEnterFrame()
            
            content.velocityX, content.velocityY = 0, 0
            content.startX, content.startY = event.x, event.y
            content.markX, content.markY = event.x, event.y
            content.markTime = event.time
            content.hasMovedThreshold = false 
            content.moveDirection = (phase == "takeFocus") and (event.forcedDirection or "both") or nil
            
            updateBounds()
            if listener then listener({ name="scrollEvent", type="beganScroll", target=scrollView, phase="began" }) end
            return true

        elseif content.isFocus then
            if phase == "moved" then
                local dx = event.x - (content.markX or event.x)
                local dy = event.y - (content.markY or event.y)
                local dt = mMax(event.time - (content.markTime or event.time), 1)
                
                if not content.moveDirection then
                    local tDx, tDy = event.x - content.startX, event.y - content.startY
                    if mAbs(tDx) > touchThreshold or mAbs(tDy) > touchThreshold then
                        content.moveDirection = (mAbs(tDx) > mAbs(tDy)) and "horizontal" or "vertical"
                    end
                end
                
                if not content.hasMovedThreshold then
                    local tDx, tDy = mAbs(event.x - content.startX), mAbs(event.y - content.startY)
                    if (content.moveDirection == "horizontal" and tDx > touchThreshold) or
                       (content.moveDirection == "vertical" and tDy > touchThreshold) or
                       (content.moveDirection == "both" and (tDx > touchThreshold or tDy > touchThreshold)) then
                        content.hasMovedThreshold = true
                        content.markX, content.markY, content.markTime = event.x, event.y, event.time
                    end
                    return true 
                end

                if not noVScroll then
                    local targetY = content.y + dy
                    if targetOSY > 0 then
                        targetOSY = mMax(0, targetOSY + dy)
                        content.y, content.velocityY = content.upperLimit, 0
                    elseif targetOSY < 0 then
                        targetOSY = mMin(0, targetOSY + dy)
                        content.y, content.velocityY = content.lowerLimit, 0
                    else
                        if targetY > content.upperLimit then
                            content.y, content.velocityY, targetOSY = content.upperLimit, 0, targetY - content.upperLimit
                        elseif targetY < content.lowerLimit then
                            content.y, content.velocityY, targetOSY = content.lowerLimit, 0, targetY - content.lowerLimit
                        else
                            content.y, content.velocityY, targetOSY = targetY, (dy / dt) * 16.67, 0
                        end
                    end
                    content.vy = content.y
                end

                if not noHScroll then
                    local targetX = content.x + dx
                    if targetOSX > 0 then
                        targetOSX = mMax(0, targetOSX + dx)
                        content.x, content.velocityX = content.leftLimit, 0
                    elseif targetOSX < 0 then
                        targetOSX = mMin(0, targetOSX + dx)
                        content.x, content.velocityX = content.rightLimit, 0
                    else
                        if targetX > content.leftLimit then
                            content.x, content.velocityX, targetOSX = content.leftLimit, 0, targetX - content.leftLimit
                        elseif targetX < content.rightLimit then
                            content.x, content.velocityX, targetOSX = content.rightLimit, 0, targetX - content.rightLimit
                        else
                            content.x, content.velocityX, targetOSX = targetX, (dx / dt) * 16.67, 0
                        end
                    end
                end

                content.markX, content.markY, content.markTime = event.x, event.y, event.time
                if listener then listener({ name="scrollEvent", type="moving", target=scrollView }) end
                return true

            elseif phase == "ended" or phase == "cancelled" then
                display.getCurrentStage():setFocus(nil, event.id)
                content.isFocus = false
                content.moveDirection = nil
                content.hasMovedThreshold = false
                targetOSX, targetOSY = 0, 0
                ensureEnterFrame()
                if listener then listener({ name="scrollEvent", type="endedScroll", target=scrollView, phase="ended" }) end
                return true
            end
        end
        return true
    end

    local function barTouch(event, isVertical)
        local phase = event.phase
        if phase == "began" then
            display.getCurrentStage():setFocus(event.target, event.id)
            event.target.isFocus = true
            event.target.mark = isVertical and event.y or event.x
            event.target.contentMark = isVertical and content.y or content.x
            Runtime:removeEventListener("enterFrame", onEnterFrame); enterFrameActive = false
            return true
        elseif event.target.isFocus then
            if phase == "moved" then
                local delta = (isVertical and event.y or event.x) - event.target.mark
                local range = isVertical and (content.upperLimit - content.lowerLimit) or (content.leftLimit - content.rightLimit)
                local trackSize = (isVertical and height or width) - (isVertical and event.target.height or event.target.width)
                
                if trackSize > 0 then
                    local newPos = event.target.contentMark - ((delta / trackSize) * range)
                    if isVertical then
                        content.y = mMax(content.lowerLimit, mMin(content.upperLimit, newPos))
                        content.vy = content.y
                    else
                        content.x = mMax(content.rightLimit, mMin(content.leftLimit, newPos))
                    end
                end
            elseif phase == "ended" or phase == "cancelled" then
                display.getCurrentStage():setFocus(nil, event.id)
                event.target.isFocus = false
            end
            return true
        end
        return false
    end

    if vBar then vBar:addEventListener("touch", function(e) return barTouch(e, true) end) end
    if hBar then hBar:addEventListener("touch", function(e) return barTouch(e, false) end) end

    local lastCX, lastCY
    local function scrollbarTracker()
        if content.x ~= lastCX or content.y ~= lastCY then
            lastCX, lastCY = content.x, content.y
            updateScrollbars()
        end
    end
    Runtime:addEventListener("enterFrame", scrollbarTracker)

    local mouseSens = options.mouseScrollSensitivity or 2.5 / (mMax(display.contentWidth, display.contentHeight) / mMin(display.contentWidth, display.contentHeight))
    scrollView.wheelEnable = true
    
    local function onMouseWheel(event)
        if event.type == "scroll" and bgRect.contentBounds and scrollView.wheelEnable then
            local b = bgRect.contentBounds
            if event.x >= b.xMin and event.x <= b.xMax and event.y >= b.yMin and event.y <= b.yMax then
                updateBounds()
                content.velocityY, content.velocityX = 0, 0

                if not noVScroll and event.scrollY ~= 0 then
                    local tY = mMax(content.lowerLimit, mMin(content.upperLimit, content.vy + (event.scrollY * -mouseSens)))
                    if content.wheelYtransition then transition.cancel(content.wheelYtransition) end
                    content.wheelYtransition = transition.to(content, {y = tY, time = 150, transition = easing.outQuad})
                    content.vy = tY
                end

                if not noHScroll and noVScroll and event.scrollY ~= 0 then
                    content.x = mMax(content.rightLimit, mMin(content.leftLimit, content.x + (event.scrollY * -mouseSens)))
                end

                updateScrollbars()
                if listener then listener({ name="scrollEvent", type="moving", target=scrollView }) end
                return true
            end
        end
        return false
    end
    Runtime:addEventListener("mouse", onMouseWheel)

    bgRect:addEventListener("touch", function(e) return handleTouch(e, false) end)
    content:addEventListener("touch", function(e) return handleTouch(e, true) end)

    function scrollView:takeFocus(event)
        if event.target and event.target.isFocus then
            display.getCurrentStage():setFocus(nil, event.id)
            event.target.isFocus = false
        end
        handleTouch({ phase = "takeFocus", x = event.x, y = event.y, id = event.id, forcedDirection = "both", time = system.getTimer() }, false)
    end

    function scrollView:insert(arg1, arg2)
        if arg2 then content:insert(arg1, arg2)
        elseif arg1 == viewContainer or arg1 == fixed then display.Group.insert(self, arg1)
        else content:insert(arg1) end
        updateBounds()
    end

    local function cleanup()
        Runtime:removeEventListener("enterFrame", onEnterFrame)
        Runtime:removeEventListener("enterFrame", scrollbarTracker)
        Runtime:removeEventListener("mouse", onMouseWheel)
    end

    function scrollView:removeSelf()
        cleanup()
        display.remove(self)
    end
    scrollView:addEventListener("finalize", cleanup)

    function scrollView:setScrollHeight(newHeight)
        scrollView._customScrollHeight = newHeight
        updateBounds()
    end
    function scrollView:setScrollWidth(newWidth)
        scrollView._customScrollWidth = newWidth
        updateBounds()
    end

    function scrollView:getContentPosition() return content.x, content.y end
    function scrollView:getMoveDirection() return content.moveDirection end
    function scrollView:stop() content.velocityY, content.velocityX = 0, 0 end 

    function scrollView:upd(animate)
        updateBounds()
        local tX = mMax(content.rightLimit, mMin(content.leftLimit, content.x))
        local tY = mMax(content.lowerLimit, mMin(content.upperLimit, content.y))
        
        if animate then
            transition.to(content, {x = tX, y = tY, time = 180, transition = easing.outQuad})
        else 
            content.x, content.y = tX, tY
        end 
        
        lastCX, lastCY, content.vy = content.x, content.y, content.y
        updateScrollbars()
    end
    
    function scrollView:scrollToPosition(arg1, arg2, arg3)
        local tX, tY, time
        if type(arg1) == "table" then
            tX, tY, time = arg1.x or content.x, arg1.y or content.y, arg2 or 0
        else
            tX, tY, time = arg1 or content.x, arg2 or content.y, arg3 or 0
        end

        tX = noHScroll and content.x or tX
        tY = noVScroll and content.y or tY

        if time > 0 then
            transition.to(content, {x = tX, y = tY, time = time, onComplete = function() 
                content.vy = content.y
                updateScrollbars()
            end})
        else
            content.x, content.y, content.vy = tX, tY, tY
            updateScrollbars()
        end

        if listener then listener({ name="scrollEvent", type="stopped", target=scrollView }) end
    end
    
    scrollView.scrollToPosition2 = scrollView.scrollToPosition

    updateBounds()
    return scrollView
end

function M.newTopBar(group,text,dotsbtn,backfun)
    local topbargroup = display.newGroup()
	local topbar = display.newRect(topbargroup, sw/2,app.topbarheight/2,sw, app.topbarheight)
	topbar:setFillColor(unpack(app.color.topBar1BgColor))
	local leftpad = app.pad
	local title
    title = display.newText({
        x = leftpad,
     	y = app.topbarheight/2,
    	text = text or "",
    	width = sw - leftpad,
		align = "left",
		fontSize = app.fontsize1,
		font = app.font
    })
	title:setFillColor(unpack(app.color.topBar1TextColor))
    title.anchorX = 0
    topbargroup:insert(title)
	
	topbargroup.barheight = app.topbarheight
	
	group:insert(topbargroup)
	
	
	return topbargroup
end

function M.newTopBar2(group,text,btns)
    local topbargroup = display.newGroup()
	
	local bar2height = app.topbarheight/1.18
	
	topbargroup.barheight = bar2height
	
	local topbar2bg = display.newRect(topbargroup, 0, 0, sw, bar2height) 
    topbar2bg:setFillColor(unpack(app.color.topBar2BgColor))
    
    local topbar2 = display.newText({
        parent = topbargroup,
        x = bar2height,
        y = topbar2bg.y,
        width = sw - app.pad - bar2height,
        text = text,
        fontSize = app.fontsize1,
        align = "right",
		font = app.font
    })
    topbar2.height = bar2height
    topbar2.anchorX, topbar2.anchorY, topbar2bg.anchorX, topbar2bg.anchorY = 0, 0, 0, 0
	topbar2:setFillColor(unpack(app.color.topBar2TextColor))
    
    local topbar2btns = btns or {}
    for i = 1, #topbar2btns do
        local id = topbar2btns[i].id
		local callback = topbar2btns[i].callback or function() end
        local btn = PonosUi.newButton(function(e)
            if e.phase == "ended" then
			    callback(e)
            end
            return true
        end, {
            x = -app.pad/2 + bar2height/2 + app.pad + (i-1)*(bar2height+app.pad), 
            y = topbar2bg.y, 
            width = bar2height+app.pad, 
            height = bar2height, 
            icon = {path = topbar2btns[i].icon, size = bar2height-app.pad}, 
            line_width = 0,
			colorBg = app.color.topBar2BgColor,
			colorTxt = app.color.topBar2TextColor
        }, topbargroup)
        btn.anchorY = 0
    end
	
	group:insert(topbargroup)
	
	topbargroup.y = app.topbarheight
	
	return topbargroup
end

function M.newBottomBar(callback, buttons, group, lower, pager)
    local botobuton_group = display.newGroup()
	
	local contentWidth = sw
	if lower then
	    contentWidth = math.min(contentWidth, 400)
	end
	
	local b = display.newRect(botobuton_group, 0, 0, contentWidth, 82)
	b:setFillColor(unpack(app.color.bottomBarBgColor))
	b.alpha = 0.01
	
	
	local currentx = -b.width/2
	local elw = b.width/#buttons
	local btns = {}
	local selecte = display.newImageRect(botobuton_group, "res/widget/ripple.png", elw+app.pad, b.height+app.pad)
	selecte.alpha = 0
	selecte.anchorX = 0
	local last_select = nil
	botobuton_group.select = function(index)
	        if pager then
	        if last_select and last_select~= btns[index] then
			    local obj = last_select
				obj.icon:setFillColor(unpack(obj.colot))
				obj.bg.isVisible = false
		    end
		    last_select = btns[index]
		    last_select.bg.isVisible = true
			last_select.icon:setFillColor(unpack(app.color.bottomBarHighLightColor))
	        selecte.x = btns[index].x-8
		    transition.to(last_select, {alpha = 1, time = 200, transition = easing.outQuad})
		    selecte:toFront()
		    selecte.alpha = 0
		    transition.to(selecte, {alpha = 0, time = 400})
		end
	end
	for i = 1, #buttons do
	    local index = buttons[i].index
		
		if index ~= nil then
		
		local style = buttons[i].style or "nope"
		
		local colob
		local colot
		
		if style == "nope" then
		    colob = app.color.bottomBarBgColor
			colot = app.color.bottomBarIconColor
		elseif style == "green" then
		    colob = {37/255,188/255,63/255}
			colot = {1,1,1}
		elseif style == "nono" then
		    colob = {0.12,0.12,0.12}
		    colot = {0.5,0.5,0.5}
		end
		
		local bgRect = display.newRoundedRect(botobuton_group, currentx+app.pad/2-2,0,elw-app.pad+4, b.height-app.pad+4, b.height/3.2+2)
		bgRect:setFillColor(app.color.bottomBarHighLightColor[1]/2,app.color.bottomBarHighLightColor[2]/2, app.color.bottomBarHighLightColor[3]/2, 0.76)
		bgRect.anchorX = 0
		bgRect.isVisible = false
		
	    local button = PonosUi.newButton(function(event) 
		    if event.phase == "moved" then
			    local delta = math.abs(event.x - event.xStart) + math.abs(event.y - event.yStart)
                if (delta > app.touchDelta) then 
                        display.getCurrentStage():setFocus(event.target, nil)
                        event.target.isFocus = false
                        return false
                end
				return true
			end
		    if event.phase == "ended" then
				botobuton_group.select(i)
			    callback(index)
			end
		end, {rounded = b.height/3.2, x = currentx+app.pad/2, y = 0, width = elw-app.pad, height = b.height-app.pad, text = buttons[i].text, icon = { path = buttons[i].icon or nil }, colorBg = colob, colorTxt = colot }, botobuton_group)
		button.anchorX = 0
		table.insert(btns, button)
		button.bg = bgRect
		
		button.colot = colot
		
		end
		
	    currentx = currentx+elw
	end
	if group then
	    group:insert(botobuton_group)
	end
	
	botobuton_group.y = sh-botobuton_group.height/2 - getBottomNavHeight()
	botobuton_group.x = sw/2
	
	botobuton_group.heheg = botobuton_group.height+getBottomNavHeight()
	
	local delta = botobuton_group.heheg - b.height
	b.height = botobuton_group.heheg
	b.y = delta/2
	
	return botobuton_group
end

function M.newFab1(params, group)
    local g = display.newGroup()
	
	local btnO = display.newRoundedRect(g, 0,0, app.fabsize*2, app.fabsize*2, app.fabsize/1.5)
	btnO:setFillColor(unpack(app.color.btnFabBgColor))
	
	local x = params.x or sw - g.width
	local y = params.y or sh - g.height-getBottomNavHeight()
	
	local list = params.buttons
	local callback = params.callback
	
	local panel = display.newRoundedRect(g, 0,0, app.fabsize*2, app.fabsize*2, app.fabsize/1.2)
	panel:setFillColor(unpack(app.color.btnFabBgColor))
	panel.isVisible = false
	
	panel.strokeWidth = 0
	panel:setStrokeColor(app.color.btnFabOutlineColor[1], app.color.btnFabOutlineColor[2], app.color.btnFabOutlineColor[3])
	
	local icon = display.newImageRect(g, "res/ui/plus.png", app.fabsize*1.2, app.fabsize*1.2)
	
	local openFab
	
	local buttonsg = display.newGroup()
	g:insert(buttonsg)
	buttonsg.alpha = 0
	local bge = {}
	
	local size = app.fabsize*2
	local step = size+app.pad
	local currentx = 0
	for i = 1, #list do
	    local item = list[i]
		local myIndex = item.index or i
		
		local btn = PonosUi.newButton(function(event) 
		    if event.phase == "ended" then
			    openFab()
				callback(myIndex)
			end
		end, {x = currentx, y = 0, width = size, height = size, text = "", rounded = app.fabsize/1.2, colorTxt = {1,1,1}, alpha = 0.01, icon = item.icon}, buttonsg)
		
		btn.myX = btn.x
		
		table.insert(bge, btn)
		
		currentx = currentx - step
	end
	
	local widthFab = math.min(sw-app.pad-app.fabsize, buttonsg.width+app.pad*2)
	
	for i = 1, #bge do
	    bge[i].x = 0
	end
	
    openFab = function()
	    if panel.t then
		    return
		end
	    if panel.isVisible then
		    for i = 1, #bge do
			    transition.to(bge[i] ,{x = 0, time = 300, transition = easing.outQuad})
			end
		    panel.t = transition.to(panel ,{x = 0, y = 0, strokeWidth = 0, width = app.fabsize*2, height = app.fabsize*2, time = 300, onComplete = function() 
			panel.isVisible = false 
			panel.t = nil
			end, transition = easing.outQuad})
			transition.to(icon ,{alpha = 1, time = 300, transition = easing.outQuad})
			transition.to(buttonsg ,{alpha = 0, time = 100, transition = easing.outQuad})
		else
		    panel.isVisible = true
		    panel.t = transition.to(panel ,{x = -widthFab/2+app.fabsize+app.pad, y = 0, width = widthFab, height = app.fabsize*2+app.pad*2, time = 300, strokeWidth = 6, onComplete = function()
                panel.t = nil
			end, transition = easing.outQuad})
			transition.to(icon ,{alpha = 0, time = 300, transition = easing.outQuad})
			transition.to(buttonsg ,{alpha = 1, time = 100})
			for i = 1, #bge do
			    transition.to(bge[i] ,{x = bge[i].myX, time = 300, transition = easing.outQuad})
			end
		end
	end
	
	btnO:addEventListener("touch", function(event)
	    if event.phase == "ended" then
		    openFab()
			display.getCurrentStage():setFocus(nil)
		else
		    display.getCurrentStage():setFocus(event.target, nil)
		end
		return true
	end)
	
	g.x = x 
	g.y = y 
	
	if group then
	    group:insert(g)
	end
	
	return g
end 

function M.newFabs(callback, buttons, group, lower, pager)
 local function onTouch(event)
  if event.phase == 'began' then 
   display.getCurrentStage():setFocus(event.target)
   transition.to(event.target, {xScale = 0.98, yScale = 0.98, time = 80, transition = easing.outQuad})
  elseif event.phase == 'ended' then
   transition.to(event.target, {xScale = 1, yScale = 1, time = 100, transition = easing.outQuad})
   display.getCurrentStage():setFocus(nil)
   if math.abs(event.yDelta+event.xDelta)<30 then callback(event.target.id) end 
   return true
  end
 end
 local gr = display.newGroup()
 for i =1, #buttons do
  local g = display.newGroup()
  local btn = M.newButton( onTouch, {x = 0, y = 0, width = app.fabsize*2, height = app.fabsize*2, rounded = app.fabsize/1.5, text = '', colorBg = app.color.btnFabBgColor},g)
  local icon = display.newImageRect(g, buttons[i].icon, app.fabsize*1.2, app.fabsize*1.2)
  icon:setFillColor(unpack(app.color.btnFabIconColor))
  g.y = (i-1)*(app.fabsize*2+app.pad)
  btn.id = buttons[i].index
  
  gr:insert(g)
 end 
 gr.x = sw-gr.width*0.5-app.fabsize/1.5
 gr.y = sh - gr.height-getBottomNavHeight()-app.fabsize/2
 group:insert(gr)
 return gr
end

function M.newLoader(group, x, y)
    local loaderGroup = display.newGroup()
    loaderGroup.x, loaderGroup.y = x, y
    if group then group:insert(loaderGroup) end
    local dots = {}
    local dotSpacing = app.pad*2
    for i = 1, 3 do
        local dot = display.newCircle(loaderGroup, (i - 2) * dotSpacing, 0, 10)
        dot:setFillColor(unpack(app.color.loaderColor))
        dot.alpha = 0.3
        dots[i] = dot
        local function animateDot(target, delayTime)
            if not target or not target.removeSelf then return end
            transition.to(target, {
                y = -10,
                alpha = 1,
                time = 250,
                delay = delayTime,
                transition = easing.outQuad,
                onComplete = function()
                    if not target.removeSelf then return end
                    transition.to(target, {
                        y = 0,
                        alpha = 0.3,
                        time = 250,
                        transition = easing.inQuad,
                        onComplete = function() 
                            animateDot(target, 400)
                        end
                    })
                end
            })
        end
        animateDot(dot, (i - 1) * 150)
    end

    return loaderGroup
end

function M.newInputBox(params, group)
    local box = display.newGroup()
	if group then group:insert(box) end 
	
	local x = params.x or 0
	local y = params.y or 0
	local width = params.width or 100
	local height = params.height or 100
	local text = params.text or 0
	
	local background = 1
	
	return box
end

return M