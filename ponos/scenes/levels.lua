local M = {}

-- ЭТО СПИСОК УРОВНЕЙ, а не редактор

function M.create(group, params)
    local bg = display.newRect(group, sw/2, sh/2, sw, sh)
    bg:setFillColor(app.color.mainBackgroundColor[1],app.color.mainBackgroundColor[2],app.color.mainBackgroundColor[3])
    
    local topbar = PonosUi.newTopBar(group, app.words[225], nil, function(e) end)
    local bar2height = topbar.barheight / 1.18
    
    local topbar2bg = display.newRect(group, 0, topbar.barheight, sw, bar2height) 
    topbar2bg:setFillColor(app.color.topBar2BgColor[1], app.color.topBar2BgColor[2], app.color.topBar2BgColor[3])
    
    local topbar2 = display.newText({
        parent = group,
        x = bar2height,
        y = topbar.barheight,
        width = sw - app.pad - bar2height,
        text = project_data.project_name,
        fontSize = app.fontsize1,
        align = "right",
		font = app.font
    })
    topbar2.height = bar2height
    topbar2.anchorX, topbar2.anchorY, topbar2bg.anchorX, topbar2bg.anchorY = 0, 0, 0, 0
	topbar2:setFillColor(app.color.topBar2TextColor[1],app.color.topBar2TextColor[2],app.color.topBar2TextColor[3])
    
    local topbar2btns = {{id = "back", icon = "res/ui/back.png"}}
    for i = 1, #topbar2btns do
        local id = topbar2btns[i].id
        local btn = PonosUi.newButton(function(e)
            if e.phase == "ended" and id == "back" then
                scene.goto("project", { transition = "slideRight", params={} })
            end
            return true
        end, {
            x = -app.pad/2 + bar2height/2 + app.pad + (i-1)*(bar2height+app.pad), 
            y = topbar.barheight, 
            width = bar2height+app.pad, 
            height = bar2height, 
            icon = {path = topbar2btns[i].icon, size = bar2height-app.pad}, 
            line_width = 0
        }, group)
        btn.anchorY = 0
    end
	
	local newBtn
	
	local panel = PonosUi.newBottomBar(function(index)
        newBtn()
    end,{
        {text = "", icon = "res/ui/plus.png", index = "add_script"}
    }, group)
    
    local scrollview = PonosUi.newScrollView({
        x = sw/2,
        y = topbar.barheight + bar2height,
        width = sw, 
        height = sh - topbar.barheight - bar2height - panel.height, 
        hideBackground = true, 
        horizontalScrollDisabled = true
    }) 
    group:insert(scrollview) 
    
    local projects_group = display.newGroup()
    scrollview:insert(projects_group)
    
    local function updatelist()
        for i = projects_group.numChildren, 1, -1 do
            projects_group[i]:removeSelf()
        end
        
        projectslist = ponosFile["получить список уровней"](project_data.project_name)
        local tabheight = math.max(math.min(75, (sh-topbar.barheight) / #projectslist), 106)
        local blocksObjects = {}
        local isDragging = false
        local dragTimer = nil
        
        local function recalculatePositions()
            local currentY = 0
            for i = 1, #blocksObjects do
                blocksObjects[i].id = i
                blocksObjects[i].yGoalPos = currentY
                currentY = currentY + tabheight
            end
        end
        
        local function touchEl(event)
            local target = event.target
            local target_b = event.target.group
            
            if event.phase == "began" then
			    scrollview:stop()
                display.getCurrentStage():setFocus(target, event.id)
                target.isFocus = true
                target.markEventY = event.y
                
                local _, localY = target_b.parent:contentToLocal(event.x, event.y)
                target_b.touchOffsetY = target_b.y - localY
                
                dragTimer = timer.performWithDelay(220, function()
                    if target and target.removeSelf and target.markEventY == event.y then
                        isDragging = true
                        dragTimer = nil
                        
                        target_b:toFront()
                        recalculatePositions()
                        
                        local _, currentLocalY = target_b.parent:contentToLocal(event.x, event.y)
                        target_b.y = currentLocalY + (target_b.touchOffsetY or 0)
                    end
                end)
                
            elseif event.phase == "moved" then
                if not isDragging and target.markEventY then
                    if math.abs(event.y - target.markEventY) > 10 then 
                        if dragTimer then
                            timer.cancel(dragTimer)
                            dragTimer = nil 
                        end
                        scrollview:takeFocus(event)
                    end
                else
                    local _, localY = target_b.parent:contentToLocal(event.x, event.y)
                    target_b.y = localY + target_b.touchOffsetY
                    
                    if target_b.id < #blocksObjects and target_b.y > blocksObjects[target_b.id + 1].yGoalPos then
                        local nextObj = blocksObjects[target_b.id + 1]
                        
                        projectslist[target_b.id], projectslist[target_b.id + 1] = projectslist[target_b.id + 1], projectslist[target_b.id]
                        blocksObjects[target_b.id], blocksObjects[target_b.id + 1] = nextObj, target_b
                        
                        target_b.id = target_b.id + 1
                        nextObj.id = nextObj.id - 1
                        
                        nextObj.yGoalPos = nextObj.yGoalPos - tabheight
                        transition.to(nextObj, {transition = easing.inOutQuad, time=300, y = nextObj.yGoalPos})
                        target_b.yGoalPos = target_b.yGoalPos + tabheight
                        
                    elseif target_b.id > 1 and target_b.y < blocksObjects[target_b.id - 1].yGoalPos then
                        local prevObj = blocksObjects[target_b.id - 1]
                        
                        projectslist[target_b.id], projectslist[target_b.id - 1] = projectslist[target_b.id - 1], projectslist[target_b.id]
                        blocksObjects[target_b.id], blocksObjects[target_b.id - 1] = prevObj, target_b
                        
                        target_b.id = target_b.id - 1
                        prevObj.id = prevObj.id + 1
                        
                        prevObj.yGoalPos = prevObj.yGoalPos + tabheight
                        transition.to(prevObj, {transition = easing.inOutQuad, time=300, y = prevObj.yGoalPos})
                        target_b.yGoalPos = target_b.yGoalPos - tabheight
                    end
                end
                
            elseif event.phase == "ended" or event.phase == "cancelled" then
                if target.isFocus then
                    display.getCurrentStage():setFocus(target, nil)
                    target.isFocus = false
                end
                
                if dragTimer then
                    timer.cancel(dragTimer)
                    dragTimer = nil
					scene.goto("level", {transition = "slideLeft", params={ fileName = projectslist[target_b.id].file } })
                end
                
                if isDragging then
                    isDragging = false
                    transition.to(target_b, {transition = easing.inOutQuad, time=300, y = target_b.yGoalPos})
                    
                    local newOrder = {}
                    for i = 1, #projectslist do
                        table.insert(newOrder, projectslist[i])
                    end
                    ponosFile["сохранить порядок уровней"](project_data.project_name, newOrder)
                end
            end 
            return true
        end
        
        for i = 1, #projectslist do
            local mygroup = display.newGroup()
            projects_group:insert(mygroup)
            
            mygroup.y = (i-1) * tabheight
            mygroup.yGoalPos = mygroup.y
            mygroup.id = i
            
            local data = projectslist[i]
            local btnBg = PonosUi.newButton(touchEl, {
                x = sw/2,
                y = tabheight/2,
                width = sw,
                height = tabheight,
                alpha = 1,
                style = "list",
				line_width = 0,
            }, mygroup)
            btnBg.group = mygroup
            
            local icon = display.newRoundedRect((tabheight/2)/2 + app.pad, btnBg.y, tabheight/2, tabheight/2, 9) 
            mygroup:insert(icon)        
            icon.fill = { type = "image", filename = "res/block/menu.png" }
            
            local menu2 = PonosUi.newButton(function(e) 
                if e.phase == "moved" then 
local delta = math.abs(e.x - e.xStart) + math.abs(e.y - e.yStart)
if (delta > app.touchDelta) then 
    display.getCurrentStage():setFocus(e.target, nil)
    e.target.isFocus = false
    scrollview:takeFocus(e)
end
                elseif e.phase == "ended" then
                    dropdown(group, {{app.words[13], "delete"},{app.words[14],"copy"},{app.words[15],"rename"}}, function(a,b) 
					    if a == false then return false end
					    if b[2] == "rename" then
						    local dialog = new_input_alert( {header = "переименовать", description = "введите новое название уровня"}, function(newName)
                                if newName and newName ~= "" then
                                    ponosFile["переименовать уровень"](newName, data.file, project_data.project_name)
                                    updatelist()
                                end
                            end, true)
							dialog.text(data.title)
						elseif b[2] == "delete" then
						    local dialog = new_dialog({header = "Вы действительно хотите удалить уровень?", description="вы не сможете это отменить.", buttons = {
							    {text = "отмена"},
								{text = "да, удалить", callback = function()
                                    ponosFile["удалить уровень"](data.file, project_data.project_name)
                                    updatelist()
                                end}
							}})
                        elseif b[2] == "copy" then
                            ponosFile["дублировать уровень"](data.file, project_data.project_name)
                            updatelist()
						end
					end, {x = sw, y = e.y})
                end
                return true
            end, {
                x = sw-tabheight/4-app.pad,
                y = btnBg.y,
                width = tabheight/2,
                height = tabheight/2,
                icon = {path = "res/ui/menu.png"},
                alpha = 0,
                rounded = tabheight/2
            }, mygroup)
            
            local name = display.newText({
                x = icon.x + icon.width/2 + app.pad,
                y = btnBg.y,
                text = data.title,
                width = sw - app.pad*4 - icon.width,
                align = "left",
                fontSize = app.fontsize1,
				font = app.font
            })
            mygroup:insert(name)
            name.anchorX = 0
			name:setFillColor(app.color.textAcentLightColor[1], app.color.textAcentLightColor[2], app.color.textAcentLightColor[3])
            
            blocksObjects[i] = mygroup
        end
    end
    
    updatelist()
    
    local actiongroup = display.newGroup()
    group:insert(actiongroup)
    
    newBtn = function(event)
        local dialog
        dialog = new_input_alert({
            header = app.words[16],
            description = app.words[17]
        }, function(name) 
            ponosFile["создать уровень"](name, project_data.project_name)
            updatelist() 
        end, true)
    end
	
	
	special_back_fun = function(event)
		scene.goto("project", { transition = "slideRight", params = {} })
	end
	
end
 
return M