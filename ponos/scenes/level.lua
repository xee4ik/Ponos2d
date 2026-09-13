local M = {}

function M.create(group, params)
    local level
    params = params or {}
    
    if params.fileName then 
        level = json.decode( ponosFile["читать путь"](project_path.."/levels/"..params.fileName) )
    else
        level = {
            title = "нету уровня",
            objects = {},
            settings = {}
        }
    end
	
	local params_words = {
	    x = "позиция X",
		y = "позиция Y",
		width = "ширина",
		height = "высота",
		scale = "размер",
		xScale = "растяжение X",
		yScale = "растяжение Y",
		rotation = "направление",
		texture = "изображение"
	}
    
    local level_objects = level.objects
    project_data = project_data or default_project
    
    -- Главная группа для камеры (мира)
    local worldGroup = display.newGroup()
    group:insert(worldGroup)
    
    local bg = display.newRect(worldGroup, sw/2, sh/2, sw * 5, sh * 5)
    bg:setFillColor(app.color.mainBackgroundColor[1],app.color.mainBackgroundColor[2],app.color.mainBackgroundColor[3])
    
    local lvlg = display.newGroup()
    worldGroup:insert(lvlg)
    
    -- Группа для Gizmo (всегда поверх объектов)
    local gizmoGroup = display.newGroup()
    worldGroup:insert(gizmoGroup)
    gizmoGroup.isVisible = false

    -- UI элементы (остаются статичными на экране)
    local uiGroup = display.newGroup()
    group:insert(uiGroup)
    
    local topbar = PonosUi.newTopBar(uiGroup, level.title, nil, function(e) end)
    local bar2height = topbar.barheight / 1.18
    local topbar2bg = display.newRect(uiGroup, 0, topbar.barheight, sw, bar2height) 
    topbar2bg:setFillColor(app.color.topBar2BgColor[1], app.color.topBar2BgColor[2], app.color.topBar2BgColor[3])
    local topbar2 = display.newRect(uiGroup, bar2height, topbar.barheight, sw, bar2height)
    topbar2.alpha = 0.01
    topbar2.anchorX, topbar2.anchorY, topbar2bg.anchorX, topbar2bg.anchorY = 0, 0, 0, 0
	topbar2:setFillColor(app.color.topBar2TextColor[1],app.color.topBar2TextColor[2],app.color.topBar2TextColor[3])
    
    local grid_enable = false
    
    local tbtn = { }
    tbtn.g = display.newGroup()
    uiGroup:insert(tbtn.g)
	
	local topbar2btns = {{id = "back", icon = "res/ui/back.png"}}
    for i = 1, #topbar2btns do
        local id = topbar2btns[i].id
        local btn = PonosUi.newButton(function(e)
            if e.phase == "ended" and id == "back" then
			    ponosFile["писать путь"](project_path.."/levels/"..params.fileName, json.encode(level))
                scene.goto("levels", { transition = "slideRight", params={} })
            end
            return true
        end, {
            x = -app.pad/2 + bar2height/2 + app.pad + (i-1)*(bar2height+app.pad), 
            y = topbar.barheight, 
            width = bar2height+app.pad, 
            height = bar2height, 
            icon = {path = topbar2btns[i].icon, size = bar2height-app.pad}, 
            line_width = 0
        }, uiGroup)
        btn.anchorY = 0
    end
    
    local function switch_grid_enable()
        if grid_enable then
            grid_enable = false
            tbtn.gridE.setIcon({path = "res/editor/grid_off.png"})
        else
            grid_enable = true
            tbtn.gridE.setIcon({path = "res/editor/grid_on.png"})
        end
    end
    
    tbtn.gridE = PonosUi.newButton(function(event)
        if event.phase == "ended" then
            switch_grid_enable()
        end
    end, {alpha = 0.01, x = 0, width = bar2height, height = bar2height, text = "", icon = {path = "res/editor/grid_off.png"}}, tbtn.g)
    
    tbtn.g.x = sw - tbtn.g.width/2
    tbtn.g.y = topbar2.y + tbtn.g.height/2

    -- ==========================================
    -- КАМЕРА
    -- ==========================================
	
	local posText = display.newText({
	    parent = uiGroup,
		x = 0,
		y = topbar.barheight+bar2height,
		width = sw,
		fontSize = app.fontsize1,
		text = "X: "..worldGroup.x..", ".."Y: "..worldGroup.y,
		font = app.font
	})
	posText.anchorX = 0
	posText.anchorY = 0
    
    local function moveCamera(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(bg)
            bg.isFocus = true
            bg.markX = worldGroup.x - event.x
            bg.markY = worldGroup.y - event.y
            
            -- Скрываем Gizmo при клике в фон (Deselect)
            gizmoGroup.isVisible = false
            gizmoGroup.targetObj = nil
        elseif bg.isFocus then
            if event.phase == "moved" then
                worldGroup.x = math.floor(event.x + bg.markX)
                worldGroup.y = math.floor(event.y + bg.markY)
            elseif event.phase == "ended" or event.phase == "cancelled" then
                display.getCurrentStage():setFocus(nil)
                bg.isFocus = false
            end
        end
		posText.text = "X: "..worldGroup.x..", ".."Y: "..worldGroup.y
        return true
    end
    bg:addEventListener("touch", moveCamera)
	
	local is_context_open = false
    local context_group = nil
    local open_context
	
    local function set_object_param(dataRef, key, value)
        if not dataRef or not dataRef.value then return end
        
        local found = false
        for i = 1, #dataRef.value do
            if dataRef.value[i][1] == key then
                dataRef.value[i][2] = value
                found = true
                break
            end
        end
        
        -- Если такого параметра в массиве еще не было — инициализируем его
        if not found then
            table.insert(dataRef.value, {key, value})
        end
    end

    local function syncZOrder()
        for i = 1, #level.objects do
            if level.objects[i].displayObject then
                level.objects[i].displayObject:toFront()
            end
        end
        gizmoGroup:toFront()
    end

local gizmoBox = display.newRect(gizmoGroup, 0, 0, 100, 100)
    gizmoBox:setFillColor(0, 0.9, 0.3, 0.28)
    gizmoBox.strokeWidth = 2
    gizmoBox:setStrokeColor(0.4, 0.4, 0.4, 0.4)

    local gizmoControls = display.newGroup()
    gizmoGroup:insert(gizmoControls)

    local gizmoCenter = display.newRect(gizmoControls, 0, 0, 28, 28)
    gizmoCenter:setFillColor(1, 1, 1, 0.6)

    local axisXGroup = display.newGroup()
    gizmoControls:insert(axisXGroup)
    local axisXLine = display.newRect(axisXGroup, 45, 0, 60, 6)
    axisXLine:setFillColor(1, 0.2, 0.2)
    local axisXHead = display.newPolygon(axisXGroup, 80, 0, {-10, -12, 12, 0, -10, 12})
    axisXHead:setFillColor(1, 0.2, 0.2)

    local axisYGroup = display.newGroup()
    gizmoControls:insert(axisYGroup)
    local axisYLine = display.newRect(axisYGroup, 0, -45, 6, 60)
    axisYLine:setFillColor(0.2, 1, 0.2)
    local axisYHead = display.newPolygon(axisYGroup, 0, -80, {-12, 10, 0, -12, 12, 10})
    axisYHead:setFillColor(0.2, 1, 0.2)
    
    local contextGroup = display.newGroup()
    gizmoGroup:insert(contextGroup)
    
    local btnEditContext = PonosUi.newButton(function(event)
        if event.phase == "ended" then
            open_context(gizmoGroup.targetObj.dataRef)
        end
    end, {x = -80, y = 0, width = 40, height = 40, alpha = 0.8, icon = {path = "res/ui/menu.png"}, rounded = 20}, contextGroup)

    local function updateGizmo()
        if gizmoGroup.targetObj then
            local obj = gizmoGroup.targetObj
            gizmoGroup.x, gizmoGroup.y = obj.x, obj.y
            gizmoBox.rotation = obj.rotation
            gizmoBox.width = (obj.width or 100) * obj.xScale
            gizmoBox.height = (obj.height or 100) * obj.yScale
        end
    end

    local function gizmoTouch(event)
        local target = event.target
        local obj = gizmoGroup.targetObj
        if not obj then return false end

        if event.phase == "began" then
            display.getCurrentStage():setFocus(target)
            target.isFocus = true
            
            target.startX = event.x
            target.startY = event.y
            target.startObjX = obj.x
            target.startObjY = obj.y
            
            if target.mode == "x" then target.alpha = 0.5
            elseif target.mode == "y" then target.alpha = 0.5
            else target:setFillColor(1, 1, 0, 0.8) end
            
        elseif event.phase == "moved" and target.isFocus then
            local dx = (event.x) - target.startX
            local dy = (event.y) - target.startY

            if target.mode == "free" then
                obj.x = target.startObjX + dx
                obj.y = target.startObjY + dy
            elseif target.mode == "x" then
                obj.x = target.startObjX + dx
            elseif target.mode == "y" then
                obj.y = target.startObjY + dy
            end
            
            updateGizmo()
            
        elseif event.phase == "ended" or event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
            target.isFocus = false
            
            set_object_param(obj.dataRef, "x", obj.x)
            set_object_param(obj.dataRef, "y", obj.y)
            
            if target.mode == "x" then target.alpha = 1
            elseif target.mode == "y" then target.alpha = 1
            else target:setFillColor(1, 1, 1, 0.6) end
        end
        return true
    end

    gizmoCenter.mode = "free"; gizmoCenter:addEventListener("touch", gizmoTouch)
    axisXGroup.mode = "x"; axisXGroup:addEventListener("touch", gizmoTouch)
    axisYGroup.mode = "y"; axisYGroup:addEventListener("touch", gizmoTouch)
	
	local function get_index_obj_by_name(object)
	    local list = level.objects
		local index = nil
		for i =1, #list do
		    if list[i].name == object then
			    index = i
			    break
			end
		end
		return index
	end
	
	local function delete_object(object)
	    local i = get_index_obj_by_name(object)
		if i == nil then
		    print("нету объекта "..i.." "..object )
			return false
		end
	    local displayObject = level.objects[i].displayObject
	    table.remove(level.objects, get_index_obj_by_name(object))
		display.remove(displayObject)
		gizmoGroup.isVisible = false
        gizmoGroup.targetObj = nil
		return true
	end
	
    local function apply_object(object, list, type)
        type = type or "unknow"
        local simple = {x = true, y = true, rotation = true, xScale = true, yScale = true, WHsuport = { rect = true }}
        for i = 1, #list do
            local this = list[i]
            local id = this[1]
            local value = this[2]
            if simple[id] then
                object[id] = value
            else
                if id == "width" or id == "height" then
                    if simple.WHsuport[type] then object[id] = value end
                elseif id == "scale" then
                    object.xScale = value
                    object.yScale = value
                end
            end
        end
    end
    
    local function objectTouch(event)
        local target = event.target
        local phase = event.phase

        if phase == "began" then
            display.getCurrentStage():setFocus(target)
            target.isFocus = true
            target.startX = event.x
            target.startY = event.y
            target.moved = false
            
        elseif target.isFocus then
            if phase == "moved" then
                local dx = math.abs(event.x - target.startX)
                local dy = math.abs(event.y - target.startY)
                
                if (dx > 10 or dy > 10) and not target.moved then
                    target.moved = true
                    
                    display.getCurrentStage():setFocus(nil)
                    target.isFocus = false
                    
                    display.getCurrentStage():setFocus(bg)
                    bg.isFocus = true
                    bg.markX = worldGroup.x - event.x
                    bg.markY = worldGroup.y - event.y
                    
                    gizmoGroup.isVisible = false
                    gizmoGroup.targetObj = nil
                end
                
            elseif phase == "ended" or phase == "cancelled" then
                display.getCurrentStage():setFocus(nil)
                target.isFocus = false
                
                if not target.moved then
                    gizmoGroup.targetObj = target
					gizmoGroup.targetIndex = target.id
                    gizmoGroup.isVisible = true
                    updateGizmo()
                end
            end
        end
        return true
    end

    local function create_object(data)
        local type = data.id
        local object
        if type == "rect" then
            object = display.newRoundedRect(0, 0, 100, 100, data.rounded or 0)
        elseif type == "circle" then
            object = display.newCircle(0, 0, 100)
        elseif type == "image" then
            object = display.newImage("res/splash.png")
        end
            
        apply_object(object, data.value, type)
        object.dataRef = data
        data.displayObject = object
        
        if data.parent then
            objects[data.parent]:insert(object)
        end
            
        return object
    end
    
    local function reload_scene()
        gizmoGroup.isVisible = false
        gizmoGroup.targetObj = nil
        
        -- Очищаем группу уровня
        for i = lvlg.numChildren, 1, -1 do
            if lvlg[i] then 
                lvlg[i]:removeSelf() 
            end
        end
        
        -- Пересоздаем все объекты из данных уровня
        for i = 1, #level.objects do
            local object = create_object(level.objects[i])
            object:addEventListener("touch", objectTouch)
            lvlg:insert(object)
        end
        
        syncZOrder()
    end
    
    local fab = PonosUi.newFab1( {buttons={ {icon = {path = "res/editor/rectangle.png"}, index = "rect"},{icon = {path = "res/editor/circle.png"}, index = "circle"},{icon = {path = "res/editor/image.png"}, index = "image"}, }, callback = function(e)
        local result = {}
        local name = "object_"..(#level.objects+1)
        if e == "rect" then
            result = {
                id = "rect", rounded = 15, name = name,
                value = { {"x", sw/2}, {"y", sh/2}, {"width", 100}, {"height", 100} }
            }
        elseif e == "circle" then
            result = {
                id = "circle", name = name,
                value = { {"x", sw/2}, {"y", sh/2}, {"scale", 1} }
            }
		elseif e == "image" then
            result = {
                id = "image", name = name,
                value = { {"x", sw/2}, {"y", sh/2}, {"scale", 1}, {"texture", ""} }
            }
        end
        table.insert(level.objects, result)
        
        -- Теперь при добавлении объекта просто перестраиваем всю сцену
        reload_scene()
    end}, uiGroup )
    
    -- Список объектов ыы
    local is_objlist_open = false
    local objlist_group = nil
    local open_objlist
    
    open_objlist = function()
        if is_objlist_open then
            is_objlist_open = false
            if objlist_group then
                transition.to(objlist_group.content, { 
                    x = -objlist_group.dialogW/8, y = -objlist_group.dialogW/8, 
                    xScale = 0.8, yScale = 0.8, 
                    alpha = 0, 
                    transition = easing.inBack, 
                    time = 250,
                    onComplete = function()
                        if objlist_group and objlist_group.group then
                            objlist_group.group:removeSelf()
                        end
                        objlist_group = nil
                    end
                })
            end
        else
            is_objlist_open = true
            
            local dialogW = math.min(sw / 1.08, 540)
            local g = display.newGroup()
            uiGroup:insert(g)
            g.x = sw/2
            g.y = sh/2
            
            local fade = display.newRect(g, 0, 0, sw, sh)
            fade:setFillColor(0, 0, 0, 0.5)
            fade:addEventListener("touch", function(event) 
                if event.phase == "began" then open_objlist() end
                return true
            end)
            
            local content = display.newGroup()
            g:insert(content)
            
            local bgl = display.newRoundedRect(content, 0, 0, dialogW, 380, 15)
            bgl:setFillColor(53/255, 53/255, 53/255)
            
            local scrollview = PonosUi.newScrollView({
                x = 0, y = -bgl.height/2, width = dialogW, height = bgl.height,   
                horizontalScrollDisabled = true, verticalVel = 150
            })
            content:insert(scrollview)
            local objects_group = display.newGroup()
            scrollview:insert(objects_group)
            
            content.x = -dialogW/8
            content.y = -dialogW/8
            content.alpha = 0.3
            content.xScale = 0.8
            content.yScale = 0.8
            
            transition.to(content, { x = 0, y = 0, xScale = 1, yScale = 1, alpha = 1, transition = easing.outBack, time = 350 })

            objlist_group = { group = g, content = content, dialogW = dialogW }

            local tabheight = 75
            local blocksObjects = {}
            local isDragging = false
            local dragTimer = nil

            local function recalculatePositions()
                local currentY = app.pad/2
                for i = 1, #blocksObjects do
                    blocksObjects[i].id = i
                    blocksObjects[i].yGoalPos = currentY
                    currentY = currentY + tabheight
                end
            end
            
            local points
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
                            if dragTimer then timer.cancel(dragTimer); dragTimer = nil end
                            scrollview:takeFocus(event)
                        end
                    else
                        local _, localY = target_b.parent:contentToLocal(event.x, event.y)
                        target_b.y = localY + target_b.touchOffsetY
                        
                        if target_b.id < #blocksObjects and target_b.y > blocksObjects[target_b.id + 1].yGoalPos then
                            local nextObj = blocksObjects[target_b.id + 1]
                            
                            level.objects[target_b.id], level.objects[target_b.id + 1] = level.objects[target_b.id + 1], level.objects[target_b.id]
                            blocksObjects[target_b.id], blocksObjects[target_b.id + 1] = nextObj, target_b
                            
                            target_b.id = target_b.id + 1
                            nextObj.id = nextObj.id - 1
                            
                            nextObj.yGoalPos = nextObj.yGoalPos - tabheight
                            transition.to(nextObj, {transition = easing.inOutQuad, time=300, y = nextObj.yGoalPos})
                            target_b.yGoalPos = target_b.yGoalPos + tabheight
                            
                        elseif target_b.id > 1 and target_b.y < blocksObjects[target_b.id - 1].yGoalPos then
                            local prevObj = blocksObjects[target_b.id - 1]
                            
                            level.objects[target_b.id], level.objects[target_b.id - 1] = level.objects[target_b.id - 1], level.objects[target_b.id]
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
                    
                    if dragTimer then timer.cancel(dragTimer); dragTimer = nil end
                    
                    if isDragging then
                        isDragging = false
                        transition.to(target_b, {transition = easing.inOutQuad, time=300, y = target_b.yGoalPos})
                        syncZOrder()
                    end
                end 
                return true
            end

            local function updatelist()
                for i = objects_group.numChildren, 1, -1 do
                    objects_group[i]:removeSelf()
                end
                blocksObjects = {}

                for i = 1, #level.objects do
                    local mygroup = display.newGroup()
                    objects_group:insert(mygroup)
                    mygroup.x = dialogW/2
                    mygroup.y = (i-1) * tabheight + app.pad/2
                    mygroup.yGoalPos = mygroup.y
                    mygroup.id = i
                    
                    local data = level.objects[i]
                    local btnBg = PonosUi.newButton(touchEl, {
                        x = 0, y = tabheight/2, width = dialogW-app.pad*2, height = tabheight-app.pad,
                        alpha = 1, rounded = tabheight/4, colorBg = {0.3,0.3,0.3}
                    }, mygroup)
                    btnBg.group = mygroup
                    
                    local name = display.newText({
                        x = -dialogW/2 + 20 + app.pad + tabheight, y = tabheight/2,
                        text = data.name or ("object_"..i), width = dialogW - 40 - app.pad*2,
                        align = "left", fontSize = app.fontsize1, font = app.font
                    })
					name:setFillColor(app.color.textAcentLightColor[1], app.color.textAcentLightColor[2], app.color.textAcentLightColor[3])
                    mygroup:insert(name)
                    name.anchorX = 0
                    
                    local objg = display.newGroup()
                    local objectPreview = display.newRect(0, 0, tabheight/2, tabheight/2) 
                    if data.id == "circle" then objectPreview = display.newCircle(0, 0, tabheight/4) end
                    
                    objectPreview.anchorX, objectPreview.anchorY = 0.5, 0.5
                    local bgog = display.newRect(objg, 0, 0, tabheight-app.pad*2, tabheight-app.pad*2)
                    bgog:setFillColor(0.15, 0.15, 0.15)
                    objg:insert(objectPreview)
                    objg.width = tabheight-app.pad*2
                    objg.height = tabheight-app.pad*2
                    objg.y = tabheight/2
                    objg.x = -dialogW/2+tabheight/2+app.pad
                    mygroup:insert(objg)
                    
                    local menu2 = PonosUi.newButton(function(e) 
                        if e.phase == "moved" then 
                            local delta = math.abs(e.x - e.xStart) + math.abs(e.y - e.yStart)
                            if (delta > app.touchDelta) then 
                                display.getCurrentStage():setFocus(e.target, nil)
                                e.target.isFocus = false
                                scrollview:takeFocus(e)
                            end
                        elseif e.phase == "ended" then
                            points(e.x, e.y)
                        end
                        return true
                    end, {
                        x = dialogW/2-tabheight/2-app.pad/2, y = btnBg.y,
                        width = tabheight/2, height = tabheight/2,
                        icon = {path = "res/ui/menu.png"}, alpha = 0, rounded = tabheight/2
                    }, mygroup)
                    
                    blocksObjects[i] = mygroup
                end
                
                if #level.objects == 0 then
                    local niList = display.newText({
                        x = dialogW/2, y = scrollview.height/2, width = dialogW,
                        text = "Здесь еще нет объектов!", align = "center", fontSize = app.fontsize1, font = app.font
                    })
					niList:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
                    scrollview:insert(niList)
                end
            end
            
            points = function(x, y)
                x = x or 0
                y = y or 0
                local items = { {"переименовать", "rename"}, {"выделить", "select"} }
                dropdown(nil, items, function(b) end, {x = x, y = y})
            end

            updatelist()
        end
    end
	
open_context = function(data)
    if is_context_open then
        is_context_open = false
        if context_group then
            transition.to(context_group.content, {
                xScale = 0.8, yScale = 0.8, 
                alpha = 0, 
                transition = easing.inBack, 
                time = 250,
                onComplete = function()
                    if context_group and context_group.group then
                        context_group.group:removeSelf()
                    end
                    context_group = nil
                end
            })
        end
    else
        if not data then return end
        is_context_open = true
        
        local dialogW = math.min(sw / 1.08, 540)
        local g = display.newGroup()
        uiGroup:insert(g)
        g.x = sw/2
        g.y = sh/2
        
        -- Базовая позиция контента (без клавиатуры)
        local baseContentY = sh/2 - 380/2 - app.pad - getBottomNavHeight()
        
        -- Переменная для хранения текущего активного поля
        local activeInputField = nil
        
        -- Функция закрытия активного редактирования (исправлено имя)
        local function closeActivePad()
            if activeInputField and activeInputField.closePad then
                activeInputField:closePad()
            end
            -- Сбрасываем ссылку, так как closePad внутри себя уже вызывает onPadClose, 
            -- который обнуляет activeInputField, но для надежности продублируем логику здесь, 
            -- если вызов идет извне (например, при свайпе или нажатии кнопки)
            activeInputField = nil
        end
        
        local fade = display.newRect(g, 0, 0, sw, sh)
        fade:setFillColor(0, 0, 0, 0.5)
        fade:addEventListener("touch", function(event) 
            if event.phase == "began" then 
                if activeInputField then
                    closeActivePad()
                else
                    open_context() 
                end
            end
            return true
        end)
        
        local content = display.newGroup()
        g:insert(content)
        
        local bgl = display.newRoundedRect(content, 0, 0, dialogW, 380, 15)
        bgl:setFillColor(app.color.panelBgColor[1],app.color.panelBgColor[2],app.color.panelBgColor[3])
        
        local scrollview = PonosUi.newScrollView({
            x = 0, y = -bgl.height/2, 
            width = dialogW, 
            height = bgl.height,
            horizontalScrollDisabled = true, 
            verticalVel = 100
        })
        content:insert(scrollview)
        
        -- При скролле тоже закрываем пад
        scrollview:addEventListener("touch", function(e)
            if e.phase == "began" then
                closeActivePad()
            end
        end)
        
        local params_group = display.newGroup()
        scrollview:insert(params_group)
        
        content.y = baseContentY
        content.alpha = 0.3
        content.xScale = 0.8
        content.yScale = 0.8
        
        transition.to(content, { x = 0, xScale = 1, yScale = 1, alpha = 1, transition = easing.outBack, time = 350 })
        
        local tabheight = 75
        local params = data.value
        local type = data.id
        
        local blocksParams = {}
        local isDragging = false
        local dragTimer = nil
    
        local function recalculatePositions()
            local currentY = app.pad/2
            for i = 1, #blocksParams do
                blocksParams[i].id = i
                blocksParams[i].yGoalPos = currentY
                currentY = currentY + tabheight
            end
        end

        local function syncZOrder()
            for i = 1, #blocksParams do
                if blocksParams[i] and blocksParams[i].toFront then
                    blocksParams[i]:toFront()
                end
            end
            if params_group.addBtnGroup then
                params_group.addBtnGroup:toFront()
            end
        end

        local function touchEl(event)
            local target = event.target
            local target_b = target.group
            
            if event.phase == "began" then
                closeActivePad() -- Закрываем активный пад при начале перетаскивания
                scrollview:stop()
                display.getCurrentStage():setFocus(target, event.id)
                target.isFocus = true
                target.markEventY = event.y
                
                local _, localY = target_b.parent:contentToLocal(event.x, event.y)
                target_b.touchOffsetY = target_b.y - localY
                
                isDragging = false
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
                        if dragTimer then timer.cancel(dragTimer); dragTimer = nil end
                        scrollview:takeFocus(event)
                    end
                else
				    if target_b.touchOffsetY == nil then return true  end
                    local _, localY = target_b.parent:contentToLocal(event.x, event.y)
                    target_b.y = localY + target_b.touchOffsetY
                    
                    if target_b.id < #blocksParams and target_b.y > blocksParams[target_b.id + 1].yGoalPos then
                        local nextObj = blocksParams[target_b.id + 1]
                        params[target_b.id], params[target_b.id + 1] = params[target_b.id + 1], params[target_b.id]
                        blocksParams[target_b.id], blocksParams[target_b.id + 1] = nextObj, target_b
                        target_b.id = target_b.id + 1
                        nextObj.id = nextObj.id - 1
                        nextObj.yGoalPos = nextObj.yGoalPos - tabheight
                        transition.to(nextObj, {transition = easing.inOutQuad, time=300, y = nextObj.yGoalPos})
                        target_b.yGoalPos = target_b.yGoalPos + tabheight
                        
                    elseif target_b.id > 1 and target_b.y < blocksParams[target_b.id - 1].yGoalPos then
                        local prevObj = blocksParams[target_b.id - 1]
                        params[target_b.id], params[target_b.id - 1] = params[target_b.id - 1], params[target_b.id]
                        blocksParams[target_b.id], blocksParams[target_b.id - 1] = prevObj, target_b
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
                if dragTimer then timer.cancel(dragTimer); dragTimer = nil end
                
                if isDragging then
                    isDragging = false
                    if data.displayObject then
                        apply_object(data.displayObject, data.value, type)
                        updateGizmo()
                    end
                    transition.to(target_b, {transition = easing.inOutQuad, time=300, y = target_b.yGoalPos, onComplete = syncZOrder})
                end
            end 
            return true
        end
        
        local function update_params_list()
            for i = params_group.numChildren, 1, -1 do
                params_group[i]:removeSelf()
            end
            blocksParams = {}
            
            for i = 1, #params do
                local mygroup = display.newGroup()
                params_group:insert(mygroup)
                mygroup.x = dialogW/2
                mygroup.y = (i-1) * tabheight + app.pad/2
                mygroup.yGoalPos = mygroup.y
                mygroup.id = i
                
                local this = params[i]
                local id = this[1]
                local value = tostring(this[2])
                
                local btnBg = display.newRoundedRect(mygroup, 0, tabheight/2, dialogW-app.pad*2, tabheight-app.pad, tabheight/4)
                btnBg:setFillColor(app.color.mainBackgroundColor[1],app.color.mainBackgroundColor[2],app.color.mainBackgroundColor[3])
                btnBg.group = mygroup
                
                local label = display.newText({
                    x = -dialogW/2 + 20 + app.pad, y = tabheight/2,
                    text = params_words[id] .. ":", width = 150,
                    align = "left", fontSize = app.fontsize1, font = app.font
                })
				label:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
                mygroup:insert(label)
                label.anchorX = 0
                
                local inputField = newNumInput({
                    x = btnBg.x + btnBg.width/2 - 140/2 - app.pad, 
                    y = tabheight/2, 
                    width = 140, 
                    height = 45,
                    fontSize = app.fontsize1,
                    text = value,
                    
                    -- Когда этот конкретный пад открывается:
                    onPadOpen = function(padH)
                        -- Если уже есть активное поле (другое), закрываем его принудительно
                        if activeInputField then
                            return false
                        end
                        activeInputField = inputField
                        
                        -- Поднимаем диалог
                        transition.to(content, { y = baseContentY - padH, time = 250, transition = easing.outQuad })
                    end,
                    
                    -- Когда этот конкретный пад закрывается:
                    onPadClose = function()
                        if activeInputField == inputField then
                            activeInputField = nil
                        end
                        -- Опускаем диалог
                        transition.to(content, { y = baseContentY, time = 250, transition = easing.outQuad })
                    end,
                    
                    -- Сохранение значения
                    onClose = function(newText)
                        local numVal = tonumber(newText)
                        local finalVal = numVal or newText
                        this[2] = finalVal
                        set_object_param(data, id, finalVal)
                        
                        if data.displayObject then
                            apply_object(data.displayObject, data.value, type)
                            updateGizmo()
                        end
                        if gizmoGroup and gizmoGroup.targetObj and gizmoGroup.targetObj.dataRef == data then
                            updateGizmo()
                        end
                    end
                })
                mygroup:insert(inputField)
                
                btnBg:addEventListener("touch", touchEl)
                blocksParams[i] = mygroup
            end
            
            local addBtnGroup = display.newGroup()
            params_group:insert(addBtnGroup)
            params_group.addBtnGroup = addBtnGroup
            addBtnGroup.x = dialogW/2
            addBtnGroup.y = #params * tabheight + app.pad/2
            
            -- Кнопка добавления параметра
            local btnBgAdd = PonosUi.newButton(function(e)
                if e.phase == "moved" then
                    scrollview:takeFocus(e)
                    return true
                end
                if e.phase == "ended" then
                    closeActivePad() -- ИСПРАВЛЕНО: вызываем правильную функцию
                    local items = { 
                        {params_words["x"], "x", nil, 0 }, {params_words["y"], "y", nil, 0 },
                        {params_words["width"], "width", nil, 100 }, {params_words["height"], "height", nil, 100 },
                        {params_words["rotation"], "rotation", nil, 0 }, {params_words["scale"], "scale", nil, 1 },
                        {params_words["xScale"], "xScale", nil, 0.5 }, {params_words["yScale"], "yScale", nil, 0.5 },
                    }
                    dropdown(nil, items, function(b) 
					    if b == false then return false end
                        table.insert(params, {items[b][2], items[b][4]})
                        set_object_param(data, items[b][2], items[b][4])
                        update_params_list()
                        if data.displayObject then
                            apply_object(data.displayObject, data.value, type)
                            updateGizmo()
                        end
                    end, {x = e.x, y = e.y})
                end
                return true
            end, {x = 0, y = tabheight/2, width = dialogW-app.pad*2, height = tabheight-app.pad, rounded = tabheight/4, text = "создать параметр" }, addBtnGroup )
            
            -- Кнопка удаления
            local btnBgDel = PonosUi.newButton(function(e)
                if e.phase == "moved" then scrollview:takeFocus(e); return true end
                if e.phase == "ended" then
                    delete_object(data.name)
                    open_context()
                end
                return true
            end, {x = -dialogW/4+app.pad/3, y = tabheight/2+tabheight, width = dialogW/2-app.pad*1.5, height = tabheight-app.pad, rounded = tabheight/4, icon = {path = "res/ui/trash.png"}, style = "del"}, addBtnGroup )
            
            -- Кнопка копирования
            local btnBgCopy = PonosUi.newButton(function(e)
                if e.phase == "moved" then scrollview:takeFocus(e); return true end
                if e.phase == "ended" then end
                return true
            end, {x = dialogW/4-app.pad/3, y = tabheight/2+tabheight, width = dialogW/2-app.pad*1.5, height = tabheight-app.pad, rounded = tabheight/4, icon = {path = "res/ui/copy.png"}, style = "copy"}, addBtnGroup )
        end
        
        update_params_list()
        
        context_group = { group = g, content = content, dialogW = dialogW }
    end
end
    
    local btn_open_obj_list = PonosUi.newButton(function(event) 
        if event.phase == "ended" then
            open_objlist()
        end
    end, {x = sw-app.pad, y = topbar2.y+bar2height+app.pad, width = app.fabsize*1.5, height = app.fabsize*1.5, icon = {path = "res/editor/interests.png"}, alpha = 0.5, rounded = 20 }, uiGroup)
    btn_open_obj_list.anchorX, btn_open_obj_list.anchorY = 1, 0
	
    reload_scene()
end

return M