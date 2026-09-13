local M = {}

-- это сцена с СПИСКОМ СКРИПТОВ. Сцена с редактором в другом файлике

function M.create(group, params)
    local bg = display.newRect(group, sw/2, sh/2, sw, sh)
    bg:setFillColor(app.color.mainBackgroundColor[1],app.color.mainBackgroundColor[2],app.color.mainBackgroundColor[3])
    
    local topbar = PonosUi.newTopBar(group, app.words[7], nil, function(e) end)
    local bar2height = topbar.barheight / 1.18
    
    local topbar2bg = display.newRect(group, 0, topbar.barheight, sw, bar2height) 
    topbar2bg:setFillColor(app.color.topBar2BgColor[1],app.color.topBar2BgColor[2],app.color.topBar2BgColor[3])
    
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
    
    local noScripts
    local newBtn
    
    special_back_fun = function(event)
        scene.goto("project", { transition = "slideRight", params = {} })
    end
    
    local topbar2btns = {{id = "back", icon = "res/ui/back.png"}, --[[{id = 'folder', icon = 'res/ui/folder.png'}]]}
    for i = 1, #topbar2btns do
        local id = topbar2btns[i].id
        local btn = PonosUi.newButton(function(e)
            if e.phase == "ended" then
                if id == "back" then 
                    scene.goto("project", { transition = "slideRight", params={} })
                elseif id == "back" then 
                    scene.goto("backpack", {transition = "slideRight", params={key = 'scripts'}})
                end
            end
            return true
        end, {
            x = -app.pad/2 + bar2height/2 + app.pad + (i-1)*(bar2height+app.pad), 
            y = topbar.barheight, 
            width = bar2height+app.pad, 
            height = bar2height, 
            icon = {path = topbar2btns[i].icon, size = bar2height-app.pad}, 
            line_width = 0,
            colorBg = app.color.topBar2BgColor,
            colorTxt = app.color.topBar2TextColor
        }, group)
        btn.anchorY = 0
    end
    
    local scrollview = PonosUi.newScrollView({
        x = sw/2,
        y = topbar.barheight + bar2height,
        width = sw, 
        height = sh - topbar.barheight - bar2height, 
        hideBackground = true, 
        horizontalScrollDisabled = true,
        verticalVel = 100
    }) 
    group:insert(scrollview)
	
	local panel = PonosUi.newFabs(function(index)
        newBtn()
    end,{
        {icon = "res/ui/plus.png", index = "add_script"}
    }, group)
    
    local projects_group = display.newGroup()
    scrollview:insert(projects_group)
    
    local function updatelist()
        for i = projects_group.numChildren, 1, -1 do
            projects_group[i]:removeSelf()
        end
        
        projectslist = ponosFile["получить список скриптов"](project_data.project_name)
        local tabheight = 106
        
        local step = tabheight + app.pad
        
        local blocksObjects = {}
        local isDragging = false
        local dragTimer = nil
        
        noScripts.y = sh/1.8
        noScripts.alpha = 0
        if #projectslist == 0 then
            noScripts.isVisible = true
        else 
            noScripts.isVisible = false
        end
        transition.to(noScripts, { alpha = 1, y = sh/2, time = 380, transition = easing.outQuad })
        
        local function recalculatePositions()
            local currentY = app.pad
            for i = 1, #blocksObjects do
                blocksObjects[i].id = i
                blocksObjects[i].yGoalPos = currentY
                currentY = currentY + step
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
						transition.to(target_b, {x = 50, time = 200, transition = easing.inOutQuad})
                        recalculatePositions()
                        
                        local _, currentLocalY = target_b.parent:contentToLocal(event.x, event.y)
                        target_b.y = currentLocalY + (target_b.touchOffsetY or 0)
                    end
                end)
                
            elseif event.phase == "moved" then
                if not isDragging and target.markEventY or target_b.touchOffsetY == nil then
				    if not target.markEventY then return end
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
                        
                        nextObj.yGoalPos = nextObj.yGoalPos - step
                        transition.to(nextObj, {transition = easing.inOutQuad, time=300, y = nextObj.yGoalPos})
                        target_b.yGoalPos = target_b.yGoalPos + step
                        
                    elseif target_b.id > 1 and target_b.y < blocksObjects[target_b.id - 1].yGoalPos then
                        local prevObj = blocksObjects[target_b.id - 1]
                        
                        projectslist[target_b.id], projectslist[target_b.id - 1] = projectslist[target_b.id - 1], projectslist[target_b.id]
                        blocksObjects[target_b.id], blocksObjects[target_b.id - 1] = prevObj, target_b
                        
                        target_b.id = target_b.id - 1
                        prevObj.id = prevObj.id + 1
                        
                        prevObj.yGoalPos = prevObj.yGoalPos + step
                        transition.to(prevObj, {transition = easing.inOutQuad, time=300, y = prevObj.yGoalPos})
                        target_b.yGoalPos = target_b.yGoalPos - step
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
                    scene.goto("script", {transition = "slideLeft", params={ fileName = projectslist[target_b.id].file, data = target_b.data} }) 
                end
                
                if isDragging then
                    isDragging = false
                    transition.to(target_b, {transition = easing.inOutQuad, time=300, x = 0, y = target_b.yGoalPos})
                    
                    local newOrder = {}
                    for i = 1, #projectslist do
                        table.insert(newOrder, projectslist[i])
                    end
                    ponosFile["сохранить порядок скриптов"](project_data.project_name, newOrder)
                end
            end 
            return true
        end
        
        for i = 1, #projectslist do
            local mygroup = display.newGroup()
            projects_group:insert(mygroup)
            
            mygroup.y = (i-1) * step + app.pad
            mygroup.yGoalPos = mygroup.y
            mygroup.id = i
            
            local data = projectslist[i]
            local btnOutline = display.newRoundedRect(mygroup, sw/2, tabheight/2, sw-app.pad*2+4, tabheight+4, 30+2)
            btnOutline:setFillColor( unpack(app.color.listOutlineColor) )
            local btnBg = PonosUi.newButton(touchEl, {
                x = sw/2,
                y = tabheight/2,
                width = sw-app.pad*2,
                height = tabheight,
                alpha = 1,
                style = "list",
                line_width = 0,
                rounded = 30
            }, mygroup)
            btnBg.group = mygroup
            mygroup.data = data
            
            local icon = display.newRoundedRect((tabheight/2)/2 + app.pad*2, btnBg.y, tabheight/2, tabheight/2, 9) 
            mygroup:insert(icon)        
            icon.fill = { type = "image", filename = "res/ui/dragable.png" }
			icon:setFillColor(1,1,1,0.3)
            
            local menu2 = PonosUi.newButton(function(e) 
                if e.phase == "moved" then 
                    local delta = math.abs(e.x - e.xStart) + math.abs(e.y - e.yStart)
                    if (delta > app.touchDelta) then 
                        display.getCurrentStage():setFocus(e.target, nil)
                        e.target.isFocus = false
                        scrollview:takeFocus(e)
                    end
                elseif e.phase == "ended" then
                    dropdown(group, {{app.words[13], "delete"},{app.words[14],"copy"},{app.words[15],"rename"},--[[{'упаковать', 'pack'}]]}, function(a,b) 
                        if a == false then return false end
                        if b[2] == "rename" then
                            local dialog = new_input_alert( {header = app.words[15], description = app.words[22]}, function(newName)
                                if newName and newName ~= "" then
                                    ponosFile["переименовать скрипт"](newName, data.file, project_data.project_name)
                                    updatelist()
                                end
                            end, true)
                            dialog.text(data.title)
                        elseif b[2] == "delete" and not ponosSettings.offDeleteWaringAlert then
                            local check = false
                            local dialog = new_dialog({header = app.words[33], description=app.words[24], buttons = {
                                {text = app.words[25]},
                                {text = app.words[26], callback = function()
                                    ponosSettings.offDeleteWaringAlert = check
                                    app.ponosSttSave()
                                    ponosFile["удалить скрипт"](data.file, project_data.project_name)
                                    updatelist()
                                end}
                            }})
                            local checkBox = PonosUi.newCheckBox(function(event) check = event.active end,{x = -dialog.contentWidth/2 + app.pad*1.5 + 35/2, y = app.pad/2, size = 35})
                            dialog:insert(checkBox)
                            local text = display.newText({
                             x = checkBox.x +35/2 +app.pad*2,
                             y = checkBox.y,
                             align = "center",
                             width = dialog.contentWidth - 35 - app.pad*6,
                             fontSize = app.fontsize1/1.1,
                             text = app.words[495],
                             font = app.font
                            })
                            text.anchorX = 0
                            text:setFillColor(unpack(app.color.standartTextColor))
							local hitZone = PonosUi.newButton(function(event) 
							    if event.phase == "ended" then 
								    checkBox.click() 
								end
							end, {x = 0, y = checkBox.y, width = dialog.contentWidth-app.pad*2, height = math.max(text.height, checkBox.height)+app.pad*2, alpha = 0.01}, dialog)
							--hitZone.anchorX, hitZone.anchorY = 0,0
                            dialog:insert(text)
                            dialog.customUserContentHeight = 35
                            dialog:recalc()
                        elseif b[2] == "delete" and ponosSettings.offDeleteWaringAlert then
                            ponosFile["удалить скрипт"](data.file, project_data.project_name)
                            updatelist()
                        elseif b[2] == "copy" then
                            ponosFile["дублировать скрипт"](data.file, project_data.project_name)
                            updatelist()
                        elseif b[2] == 'pack' then 
                            local dialog = new_input_alert({header = string.format('упаковать "%s" в...', data.title), description = 'введите название пакета"'}, function(name)
                                local dat = json.decode(ponosFile['читать путь']('Backpack/scripts.json') or '{}')
                                if not dat or type(dat) ~= 'table' then 
                                    dat = {}
                                end
                                dat[name] = data
                                ponosFile['писать путь']('back', json.encode(dat))
                            end, true)
                        end
                    end, {x = sw-app.pad*2, y = e.y})
                end
                return true
            end, {
                x = sw-tabheight/4-app.pad*2,
                y = btnBg.y,
                width = tabheight/2,
                height = tabheight/2,
                icon = {path = "res/ui/menu.png"},
                alpha = 0.01,
                rounded = tabheight/2,
				colorTxt = app.color.listTextColor,
            }, mygroup)
			local text = deep_copy(data.title)
            if utf8.len(text)>16 then text = utf8.sub(text, 1, 16) .. '...' end
            local name = display.newText({
                x = icon.x + icon.width/2 + app.pad,
                y = btnBg.y,
                text = text,
                width = sw - app.pad*6 - icon.width - tabheight/2,
                align = "left",
                fontSize = app.fontsize1,
                font = app.font
            })
            mygroup:insert(name)
            name.anchorX = 0
            name:setFillColor(unpack(app.color.listTextColor))
            
            blocksObjects[i] = mygroup
        end
        scrollview:upd(true)
    end
    
    noScripts = display.newText({
        x = sw/2, y = sh, text = app.words[234],
        width = sw-app.pad*2, fontSize = app.fontsize2,
        align = "center", parent = group, font = app.font
    })
    noScripts:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
    
    updatelist()
    
    newBtn = function(event)
        local dialog
        dialog = new_input_alert({
            header = app.words[34],
            description = app.words[17]
        }, function(name) 
            ponosFile["создать скрипт"](name, project_data.project_name)
            updatelist() 
        end, true)
    end
end
 
return M