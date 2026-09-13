local M = {}

function M.create(group, params)
    local bg = display.newRect(group, sw/2, sh/2, sw, sh)
    bg:setFillColor(app.color.mainBackgroundColor[1],app.color.mainBackgroundColor[2],app.color.mainBackgroundColor[3])
    bg.alpha = 0
    transition.to(bg, {alpha = 1, time = 300})
	
	local panel = PonosUi.newBottomBar(function(index)
            if index == "next" then
			    timer.cancelAll()
                scene.goto("menu" , { transition = "slideLeft" } )
            end
        end,{
            {text = app.words[254], icon = nil, index = "next", style = "green"}
        }, group)
		
	local scrollview = PonosUi.newScrollView({
        x = sw/2,
        y = 0,
        width = sw,
        height = sh-panel.height,
        horizontalScrollDisabled = true,
        showScrollbars = false,
		verticalVel = 100
    })
    group:insert(scrollview)
    
    local elementsTable = {
        {type = "title", text = app.words[256]},
        {type = "text", text = app.words[255]},
        {type = "image-swift", list = {
            "res/unknow/screenshot3.png",
            "res/unknow/screenshot4.jpg",
        }},
    }
    
    local currentY = app.pad + app.topbarheight
    local currentIndex = 1
    
    local function createElement()
        if currentIndex > #elementsTable then return end
        
        local data = elementsTable[currentIndex]
        local elementGroup = display.newGroup()
		elementGroup.y = currentY 
        
        if data.type == "title" then
            local title = display.newText({
                parent = elementGroup,
                x = app.pad,
                y = 0,
                width = sw - app.pad * 2,
                fontSize = app.fontsize3,
                text = data.text,
				font = app.font
            })
            title.anchorY = 0
            title.anchorX = 0
			title:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
			currentY = currentY + app.pad
            
        elseif data.type == "text" then
            local desc = display.newText({
                parent = elementGroup,
                x = app.pad,
                y = 0,
                width = sw - app.pad * 2,
                fontSize = app.fontsize1,
                text = data.text,
				font = app.font
            })
            desc.anchorY = 0
            desc.anchorX = 0
			desc:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
        elseif data.type == "wait" then
		    currentIndex = currentIndex + 1
		    timer.performWithDelay(250, createElement)
		    return true
        elseif data.type == "image-swift" then
            local imgWidth = sw - app.pad * 2
            local picIndex = 1
            
            local currentImage = display.newImageRect(elementGroup, data.list[picIndex], 540, 480)
            if currentImage then
                local scale = imgWidth / currentImage.width
                currentImage.width = currentImage.width * scale
                currentImage.height = currentImage.height * scale
                currentImage.x = sw / 2
                currentImage.y = currentImage.height / 2
            end
            
            local swipeTimer
			
			local deltaX = 0
			
			local points = {}
            
            local function nextImage()
                picIndex = picIndex + 1
                if picIndex > #data.list then
                    picIndex = 1
                end
                
                local newImage = display.newImageRect(elementGroup, data.list[picIndex], 540, 480)
                if newImage then
                    local scale = imgWidth / newImage.width
                    newImage.width = newImage.width * scale
                    newImage.height = newImage.height * scale
                    newImage.x = sw / 2
                    newImage.y = newImage.height / 2
                    newImage.alpha = 0
					
                    transition.to(newImage, {alpha = 1, x = sw/2, time = 300, transition = easing.outQuad})
                    if currentImage then
					    local x = deltaX
                        transition.to(currentImage, {alpha = 0, time = 1000, x = deltaX+sw/2, transition = easing.outQuad, onComplete = function(obj)
                            display.remove(obj)
                        end})
                    end
                    currentImage = newImage
					
                end
				
			    for index = 1, #points do
					local this = points[index]
					if picIndex ~= index then
					    transition.to(this, {alpha = 0.5, time = 150})
					else
					    transition.to(this, {alpha = 1, time = 150})
					end
					this:toFront()
				end
            end
            local function handleTap(event)
			    if event.phase == "moved" then
                    scrollview:takeFocus(event)
				end
			    if event.phase == "ended" then
                    if swipeTimer then
                        timer.cancel(swipeTimer)
                    end
                    nextImage()
                    swipeTimer = timer.performWithDelay(3600, nextImage, 0)
					transition.to(event.target, {alpha = 1, x = 0, time = 300, transition = easing.outQuad})
				end
            end
            
            elementGroup:addEventListener("touch", handleTap)
            swipeTimer = timer.performWithDelay(3600, nextImage, 0)
			
			for index = 1, #data.list do
			    local point = display.newCircle(index*30+sw/2-(#data.list*30)/2-15, elementGroup.height - 20 - app.pad, 10)
				elementGroup:insert(point)
				table.insert(points, point)
				point.alpha = 0.5
				if index == 1 then
				    point.alpha = 1
				end
			end
        end
        
        scrollview:insert(elementGroup)
        currentY = currentY + elementGroup.height + app.pad
        
        elementGroup.alpha = 0
        transition.to(elementGroup, {alpha = 1, time = 300})
        
        currentIndex = currentIndex + 1
        timer.performWithDelay(250, createElement)
    end
    
    createElement()
end

return M