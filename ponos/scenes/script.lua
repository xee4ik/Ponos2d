local M = {}

M.backStart = false

function M.create(group, params)
    local pad = -4 
    local scriptPath = project_path.."/scripts/"..params.fileName
    local script_data = json.decode( ponosFile["читать путь"](scriptPath) )
    local currentScript = script_data.script
    M.script = currentScript
	
    local history = {}
    local historyIdx = 0
    local undoBtn, redoBtn

    local function updateUndoRedoUI()
        if undoBtn and redoBtn then
            undoBtn.alpha = (historyIdx > 0) and 1 or 0.3
            redoBtn.alpha = (historyIdx < #history) and 1 or 0.3
        end
    end

    local function pushAction(action)
        for i = #history, historyIdx + 1, -1 do history[i] = nil end
        table.insert(history, action)
        historyIdx = #history
        updateUndoRedoUI()
    end
	
	local scrollview
	
	local function saveFile()
	    script_data.script = currentScript
		if ponosSettings.blocksEditorSaveScrollPosition then
		 local _, scrolly = scrollview:getContentPosition()
		 script_data.user.current_scroll = scrolly
		end
        ponosFile["писать путь"](scriptPath, json.encode(script_data))
	end
	
    local function saveAndExit()
        saveFile()
        scene.goto("scripts", { transition = "slideRight", params={} })
    end
    special_back_fun = saveAndExit
	
    local bg = display.newRect(group, sw / 2, sh / 2, sw, sh)
    bg:setFillColor(app.color.mainBackgroundColor[1],app.color.mainBackgroundColor[2],app.color.mainBackgroundColor[3])

    local topbar = PonosUi.newTopBar(group, app.words[35], nil, function(e) end)
    local bar2height = topbar.barheight / 1.18
    
    local topbar2bg = display.newRect(group, 0, topbar.barheight, sw, bar2height) 
    topbar2bg:setFillColor(app.color.topBar2BgColor[1],app.color.topBar2BgColor[2],app.color.topBar2BgColor[3])
    topbar2bg.anchorX, topbar2bg.anchorY = 0, 0
    
    local block_input, pasteBlocks, recalculatePositions, touchBlock, touchParameter, setupBlockObject

    local function createHistoryBtn(x, y, isRight, callback)
        local grp = display.newGroup()
        grp.x, grp.y = x, y
        local bgHit = display.newRect(grp, 0, 0, bar2height, bar2height)
        bgHit.isVisible, bgHit.isHitTestable = false, true
        local arrow = display.newPolygon(grp, 0, 0, {
            isRight and -6 or 6, -9, isRight and 6 or -6, 0, isRight and -6 or 6, 9
        })
        arrow:setFillColor(0.8, 0.8, 0.8)
        
        grp:addEventListener("touch", function(e)
            if e.phase == "ended" then 
			    if grp.alpha == 1 then app.popSound("click2") else app.popSound("click1") end
				callback()
			end
            return true
        end)
        group:insert(grp)
        return grp
    end
    
    local topbar2btns = {{id = "back", icon = "res/ui/back.png"}}
    for i = 1, #topbar2btns do
        local btn = PonosUi.newButton(function(e)
            if e.phase == "ended" and topbar2btns[i].id == "back" then saveAndExit() end
            return true
        end, {
            x = -app.pad/2 + bar2height/2 + app.pad, 
            y = topbar.barheight, width = bar2height+app.pad, height = bar2height, 
            icon = {path = topbar2btns[i].icon, size = bar2height-app.pad}, line_width = 0,	colorBg = app.color.topBar2BgColor,colorTxt = app.color.topBar2TextColor
        }, group)
        btn.anchorY = 0
    end

    local startX = bar2height + app.pad
    undoBtn = createHistoryBtn(startX + bar2height/2, topbar.barheight + bar2height/2, false, function() M.performUndo() end)
    redoBtn = createHistoryBtn(startX + bar2height*1.5, topbar.barheight + bar2height/2, true, function() M.performRedo() end)

    local topbar2 = display.newText({
        parent = group,
        x = startX + bar2height * 2, y = topbar.barheight,
        width = sw - app.pad - (startX + bar2height * 2),
        text = params.data.title, fontSize = app.fontsize1, 
		align = "right", font = app.font,
    })
    topbar2.height = bar2height
    topbar2.anchorX, topbar2.anchorY = 0, 0
	topbar2:setFillColor(app.color.topBar2TextColor[1],app.color.topBar2TextColor[2],app.color.topBar2TextColor[3])
    
    updateUndoRedoUI()

    scrollview = PonosUi.newScrollView({
        x = sw/2, y = app.topbarheight+bar2height,
        width = sw, height = sh-app.topbarheight-bar2height,    
        horizontalScrollDisabled = true, verticalVel = sh/2,
    })
    group:insert(scrollview)
	
	local panel = PonosUi.newFabs(function(index)
        if index == "add_block" then
            group.isVisible = false
            open_blocks_category(function(selected)
                block_input(selected)
                special_back_fun = saveAndExit 
            end)
        end
		if index == "start_project" then
            --group.isVisible = false
			saveFile()
			M.backStart = true
			scene.goto("simulator", {transition = "slideLeft", params = {project_data = project_data, back_scene = {name = "script", params = params}}})
        end
    end, {{icon = "res/ui/play.png", index = "start_project"},{icon = "res/ui/plus.png", index = "add_block", continue=true}}, group)
	
	script_data.user = script_data.user or {}
	
	if (script_data.user.current_scroll and ponosSettings.openScriptInSaveScrollPosition) or M.backStart then
	scrollview:scrollToPosition(0, script_data.user.current_scroll)
	else
	script_data.user.current_scroll = 0
	end
	
	M.backStart = false
    
    local blocksObjects, totalheight, currentDragY, bgDim = {}, 0, 0, nil
    local isDragging, dragTimer = false, nil
    local noScripts = display.newText({
        x = sw/2, y = sh, text = app.words[168],
        width = sw-app.pad*2, fontSize = app.fontsize2, align = "center", parent = group, font = app.font
    })
	noScripts:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
	
    local function instantiateBlock(data, width)
        local blockData = all_blocks[data.index] or {type = "block"}
        local blockObj = create_block(data, width)
        blockObj.blockData = blockData
        return blockObj
    end

    local function getNestedBounds(startIndex)
        local bData = blocksObjects[startIndex].blockData
        if not bData then return startIndex end
        if bData.type == "event" then
            for i = startIndex + 1, #blocksObjects do
                if blocksObjects[i].blockData.type == "event" then return i - 1 end
            end
            return #blocksObjects
        elseif bData.special == "cycle" then
            local depth = 1
            for i = startIndex + 1, #blocksObjects do
                local special = blocksObjects[i].blockData.special
                if special == "cycle" then depth = depth + 1
                elseif special == "end" then depth = depth - 1 end
                if depth == 0 then return i end
            end
        end
        return startIndex
    end

    setupBlockObject = function(blockObj)
        blockObj.updateParams = function()
            blockObj:rebuild(currentScript[blockObj.id].params)
            for j = 1, #blockObj.cells do blockObj.cells[j][2]:addEventListener("touch", touchParameter) end
        end
        blockObj:addEventListener("touch", touchBlock)
        for j = 1, #blockObj.cells do blockObj.cells[j][2]:addEventListener("touch", touchParameter) end
    end

    recalculatePositions = function(animate, showing)
        noScripts.alpha = 0
        noScripts.isVisible = (#currentScript == 0)
        noScripts.y = sh/1.8
        transition.to(noScripts, { alpha = 1, y = sh/2, time = 380, transition = easing.outQuad })
        
        local currentY = 30
        totalheight = -scrollview.height - currentY
        for i = 1, #blocksObjects do
            local obj = blocksObjects[i]
            local h = obj.height
            obj.id = i
            
            if obj.blockData.type == "event" then currentY = currentY + 24 end
            obj.yGoalPos = currentY
            if obj.blockData.type == "event" then currentY = currentY - 12 end
            
            if animate and not obj.isDragging then
                if obj.timer then transition.cancel(obj.timer) end
                obj.timer = transition.to(obj, {y = obj.yGoalPos, time = 150})
            else
                obj.y = obj.yGoalPos
            end
			
			if showing then
			    obj.isVisible = true 
			end
            
            currentY = currentY + h + pad
            totalheight = totalheight + h
        end
    end
	
    function M.performUndo()
        if historyIdx <= 0 then return end
        local action = history[historyIdx]
        historyIdx = historyIdx - 1
        
        if action.type == "add" then
            for i = action.index + #action.dataList - 1, action.index, -1 do
                local obj = table.remove(blocksObjects, i)
                table.remove(currentScript, i)
                display.remove(obj)
            end
        elseif action.type == "delete" then
            for i, data in ipairs(action.dataList) do
                local blockObj = instantiateBlock(data)
                local idx = action.index + i - 1
                table.insert(currentScript, idx, deep_copy(data))
                table.insert(blocksObjects, idx, blockObj)
                scrollview:insert(blockObj)
                setupBlockObject(blockObj)
            end
        elseif action.type == "modify" then
            currentScript[action.index].params = deep_copy(action.oldParams)
            blocksObjects[action.index].updateParams()
        elseif action.type == "move" then
            local cData, cObjs = {}, {}
            for i = 1, action.count do
                table.insert(cData, table.remove(currentScript, action.newIdx))
                table.insert(cObjs, table.remove(blocksObjects, action.newIdx))
            end
            for i = 1, action.count do
                table.insert(currentScript, action.oldIdx + i - 1, cData[i])
                table.insert(blocksObjects, action.oldIdx + i - 1, cObjs[i])
            end
        end
        
        recalculatePositions(true)
        updateUndoRedoUI()
    end

    function M.performRedo()
        if historyIdx >= #history then return end
        historyIdx = historyIdx + 1
        local action = history[historyIdx]
        
        if action.type == "add" then
            for i, data in ipairs(action.dataList) do
                local blockObj = instantiateBlock(data)
                local idx = action.index + i - 1
                table.insert(currentScript, idx, deep_copy(data))
                table.insert(blocksObjects, idx, blockObj)
                scrollview:insert(blockObj)
                setupBlockObject(blockObj)
            end
        elseif action.type == "delete" then
            for i = action.index + #action.dataList - 1, action.index, -1 do
                local obj = table.remove(blocksObjects, i)
                table.remove(currentScript, i)
                display.remove(obj)
            end
        elseif action.type == "modify" then
            currentScript[action.index].params = deep_copy(action.newParams)
            blocksObjects[action.index].updateParams()
        elseif action.type == "move" then
            local cData, cObjs = {}, {}
            for i = 1, action.count do
                table.insert(cData, table.remove(currentScript, action.oldIdx))
                table.insert(cObjs, table.remove(blocksObjects, action.oldIdx))
            end
            for i = 1, action.count do
                table.insert(currentScript, action.newIdx + i - 1, cData[i])
                table.insert(blocksObjects, action.newIdx + i - 1, cObjs[i])
            end
        end
        
        recalculatePositions(true)
        updateUndoRedoUI()
    end
	
    touchParameter = function(event)
        if isDragging then return false end
        local obj = event.target
        local blockGroup = obj.block
        local paramData = blockGroup.cells[obj.idParameter]
        
        if event.phase == "began" then
            if paramData and paramData[1] == "cell" then paramData[3].yScale = 1.6 end
			if paramData and paramData[1] == "editText" then paramData[3].alpha = 0.2 end
            display.getCurrentStage():setFocus(obj, event.id)
        elseif event.phase == "moved" then
            local delta = math.abs(event.x - event.xStart) + math.abs(event.y - event.yStart)
            if (delta > app.touchDelta) then 
                display.getCurrentStage():setFocus(obj, nil)
                obj.isFocus = false
                scrollview:takeFocus(event)
                if paramData and paramData[1] == "cell" then paramData[3].yScale = 1 end
				if paramData and paramData[1] == "editText" then paramData[3].alpha = 0.01 end
            end
        elseif event.phase == "ended" or event.phase == "cancelled" then
            local oldParams = deep_copy(currentScript[blockGroup.id].params)

            if paramData and paramData[1] == "cell" then 
                paramData[3].yScale = 1
                group.isVisible = false
                
                scene_formula_editor({block = currentScript[blockGroup.id], parameter = obj.idParameter}, function(newdata)
                    special_back_fun = saveAndExit
                    group.isVisible = true
                    currentScript[blockGroup.id].params = deep_copy(newdata.block.params)
                    
                    pushAction({ type = "modify", index = blockGroup.id, oldParams = oldParams, newParams = deep_copy(newdata.block.params) })
                    blockGroup.updateParams()
					recalculatePositions(false)
                end)
            elseif paramData and paramData[1] == "choose" then 
			    scrollview.wheelEnable = false
                dropdown(group, blocks_choose[obj.idChoose], function(a, b) 
				    scrollview.wheelEnable = true
				    if a == false then return false end
                    currentScript[blockGroup.id].params[obj.dataI] = b[2]
                    pushAction({ type = "modify", index = blockGroup.id, oldParams = oldParams, newParams = deep_copy(currentScript[blockGroup.id].params) })
					
                    blockGroup.updateParams()
                    recalculatePositions()
                end, {x = obj.x+obj.width, y = event.y})
			elseif paramData and paramData[1] == "editText" then 
			    local value = currentScript[blockGroup.id].params[obj.idParameter]
				local dialog = new_input_alert({header = value}, function(t) 
				    currentScript[blockGroup.id].params[obj.idParameter] = t 
					blockGroup.updateParams()
					pushAction({ type = "modify", index = blockGroup.id, oldParams = oldParams, newParams = deep_copy(currentScript[blockGroup.id].params) })
				end, true)
				dialog.text(value)
            end
            display.getCurrentStage():setFocus(obj, nil)
        end
        return true
    end

    local function onEnterFrameAutoScroll(event)
        if not isDragging then return end
        
        local edgeZone = sh/6
        local maxSpeed = 34
        
        local _, scrolly = scrollview:getContentPosition()
        
        if currentDragY < edgeZone+scrollview.y then
            local factor = 1 - (currentDragY / (edgeZone+scrollview.y))
            local speed = maxSpeed * factor
            scrollview:scrollToPosition(0, math.min(0, math.max(scrolly + speed, -totalheight-sh/2)))
        elseif currentDragY > sh - edgeZone - panel.height - getBottomNavHeight() then
            local factor =  1 - ((sh - currentDragY) / (edgeZone+panel.height+getBottomNavHeight()))
            local speed = maxSpeed * factor
            scrollview:scrollToPosition(0, math.min(0, math.max(scrolly - speed, -totalheight-sh/2)))
        end
    end

    touchBlock = function(event)
        local target = event.target
        if not target or not target.blockData then return false end
        local _, scrolly = scrollview:getContentPosition()
        currentDragY = event.y

        if event.phase == "began" then
            display.getCurrentStage():setFocus(target, event.id)
            target.isFocus = true
            scrollview.stop()
            
            target.markEventY = event.y
            local _, localY = target.parent:contentToLocal(event.x, event.y)
            target.touchOffsetY = target.y - localY
			
            dragTimer = timer.performWithDelay(220, function()
                if target.removeSelf and target.markEventY == event.y then
                    isDragging = true
                    target.isDragging = true
                    
                    target.dragStartIdx = target.id
                    local endIndex = getNestedBounds(target.id)
                    target.dragCount = endIndex - target.id + 1

                    group:insert(target)
                    Runtime:addEventListener("enterFrame", onEnterFrameAutoScroll)
                    
					if bgDim then display.remove(bgDim); bgDim = nil end
                    bgDim = display.newRect(sw/2, sh/2, sw, sh)
                    bgDim:setFillColor(0, 0, 0, 0.5)
                    bgDim.isHitTestable = true
                    group:insert(bgDim) 
                    bgDim:addEventListener("touch", function(e) display.getCurrentStage():setFocus(target, e.id); return true end)

                    target:toFront()
                    target.nestedBlocks = {}
                    
                    for i = target.id + 1, endIndex do
                        local child = blocksObjects[target.id + 1]
                        child.alpha = 0
                        table.insert(target.nestedBlocks, {data = currentScript[target.id + 1], obj = child})
                        table.remove(currentScript, target.id + 1)
                        table.remove(blocksObjects, target.id + 1)
                    end
                    
                    recalculatePositions(true)
                    local _, currentLocalY = target.parent:contentToLocal(event.x, event.y)
                    target.y = currentLocalY + target.touchOffsetY
                end
            end)
            
        elseif event.phase == "moved" then
            if dragTimer and math.abs(event.y - target.markEventY) > 10 then timer.cancel(dragTimer); dragTimer = nil end
            
            if isDragging then
                local _, localY = target.parent:contentToLocal(event.x, event.y)
                target.y = localY + target.touchOffsetY
                local targety = target.y - scrolly - scrollview.y
                local swapped = false
                
                if target.id < #blocksObjects and targety > blocksObjects[target.id + 1].yGoalPos then
                    local nextObj = blocksObjects[target.id + 1]
                    currentScript[target.id], currentScript[target.id + 1] = currentScript[target.id + 1], currentScript[target.id]
                    blocksObjects[target.id], blocksObjects[target.id + 1] = nextObj, target
                    target.id, nextObj.id = target.id + 1, nextObj.id - 1
                    swapped = true
                elseif target.id > 1 and targety < blocksObjects[target.id - 1].yGoalPos then
                    local prevObj = blocksObjects[target.id - 1]
                    currentScript[target.id], currentScript[target.id - 1] = currentScript[target.id - 1], currentScript[target.id]
                    blocksObjects[target.id], blocksObjects[target.id - 1] = prevObj, target
                    target.id, prevObj.id = target.id - 1, prevObj.id + 1
                    swapped = true
                end
                
                if swapped then
                    recalculatePositions(true)
                    target.y = target.yGoalPos + (localY + target.touchOffsetY - target.yGoalPos) 
                end
            else
                local delta = math.abs(event.x - event.xStart) + math.abs(event.y - event.yStart)
                if (delta > app.touchDelta) then 
                    display.getCurrentStage():setFocus(target, nil)
                    target.isFocus = false
                    scrollview:takeFocus(event)
                    if dragTimer then timer.cancel(dragTimer); dragTimer = nil end
                end
            end
            
        elseif event.phase == "ended" or event.phase == "cancelled" then
            if dragTimer then timer.cancel(dragTimer); dragTimer = nil end
            scrollview:insert(target)
            target.isDragging = false
            
            if isDragging then
                isDragging = false
                Runtime:removeEventListener("enterFrame", onEnterFrameAutoScroll)
                if bgDim then display.remove(bgDim); bgDim = nil end
                
                if target.nestedBlocks then
                    for k, inv in ipairs(target.nestedBlocks) do
                        table.insert(currentScript, target.id + k, inv.data)
                        table.insert(blocksObjects, target.id + k, inv.obj)
                        inv.obj.id = target.id + k
                        inv.obj.alpha = 1
                    end
                    target.nestedBlocks = nil
                end

                if target.dragStartIdx and target.dragStartIdx ~= target.id then
                    pushAction({ type = "move", oldIdx = target.dragStartIdx, newIdx = target.id, count = target.dragCount })
                end
                target.dragStartIdx, target.dragCount = nil, nil

                recalculatePositions(false)
				scrollview:upd()
            else
                local dialog = new_dialog({})
                local dialogCC = display.newGroup()
                local block = instantiateBlock(currentScript[target.id], dialog.contentWidth-app.pad*2)
                block.x, block.y = -(dialog.contentWidth)/2+app.pad, -7
                dialogCC:insert(block)
                
				local btnHeight = 60
                local buttons = {{"delete", app.words[36]}, {"copy", app.words[37]}}
                for j, item in ipairs(buttons) do
                    PonosUi.newButton(function(e)
                        if e.phase == "ended" then
						    display.getCurrentStage():setFocus(nil)
							if math.abs(e.yDelta+e.yDelta)>30 then
							   return true
				            end
							dialog.close()
                            if item[1] == "delete" then
                                local startIndex = target.id
                                local endIndex = getNestedBounds(startIndex)

                                local deletedDatas = {}
                                for k = startIndex, endIndex do
                                    table.insert(deletedDatas, deep_copy(currentScript[k]))
                                end
                                pushAction({ type = "delete", index = startIndex, dataList = deletedDatas })

                                for i = endIndex, startIndex, -1 do
                                    local objToDelete = blocksObjects[i]
                                    table.remove(currentScript, i)
                                    table.remove(blocksObjects, i)
                                    transition.to(objToDelete, {
                                        x = sw/2, time = 300, alpha = 0, transition = easing.inOutQuad, 
                                        onComplete = function() display.remove(objToDelete) end
                                    })
                                end
                                recalculatePositions(true)
                            elseif item[1] == "copy" then
                                local startIndex = target.id
                                local endIndex = getNestedBounds(startIndex)
                                
                                local copiedBlocks = {}
                                for i = startIndex, endIndex do
                                    table.insert(copiedBlocks, deep_copy(currentScript[i]))
                                end
                                
                                pasteBlocks(copiedBlocks)
                            end
						elseif e.phase == 'began' then
						    display.getCurrentStage():setFocus(e.target)
                        end
                    end, {
                        x = 0, y = (j - 1) * (btnHeight + app.pad)+block.height, width = dialog.contentWidth-app.pad*2, height = btnHeight,
                        text = item[2], fontSize = app.fontsize1, colorBg = {0,0,0}, alpha = 0.2, rounded = 10, text_align = "left"
                    }, dialogCC)
                end
                dialog:insert(dialogCC)
                dialogCC.y = -dialogCC.height/2+app.pad/2+btnHeight/2
                dialog:recalc()
            end
            
            display.getCurrentStage():setFocus(target, nil)
            target.isFocus = false
        end
        return true
    end
	
    pasteBlocks = function(copiedDatas)
        if not copiedDatas or #copiedDatas == 0 then return end
        group.isVisible = true
        
        local contentOffsetY = scrollview.content and scrollview.content.y or select(2, scrollview:getContentPosition())
        local insertPos = 1
        while insertPos <= #blocksObjects and blocksObjects[insertPos].y < -contentOffsetY + scrollview.height / 2 do
            insertPos = insertPos + 1
        end
        
        local initialInsertPos = insertPos
        local addedDatas = {}
        local firstBlockObj = nil
        
        for i, data in ipairs(copiedDatas) do
            local obj = instantiateBlock(data)
            
            table.insert(addedDatas, deep_copy(data))
            table.insert(currentScript, insertPos, data)
            table.insert(blocksObjects, insertPos, obj)
            scrollview:insert(obj)
            setupBlockObject(obj)
            
            if i == 1 then firstBlockObj = obj end
            insertPos = insertPos + 1
        end
        
        pushAction({ type = "add", index = initialInsertPos, dataList = addedDatas })
        recalculatePositions(false)
        
        if firstBlockObj then
            local _, absY = firstBlockObj:localToContent(0, 0)
            touchBlock({target = firstBlockObj, phase = "began", id = 1, x = sw / 2, y = absY, autoMove = true})
        end
    end

    block_input = function(selectedBlockData)
        group.isVisible = true
        if not selectedBlockData then return end
        
        local blockInfo = all_blocks[selectedBlockData.index]
        if not blockInfo then return end
        
        local contentOffsetY = scrollview.content and scrollview.content.y or select(2, scrollview:getContentPosition())
        local initialInsertPos = 1
        while initialInsertPos <= #blocksObjects and blocksObjects[initialInsertPos].y < -contentOffsetY + scrollview.height / 2 do
            initialInsertPos = initialInsertPos + 1
        end
        
        local addedDatas = {}
        local insertPos = initialInsertPos
        
        local blockObj = instantiateBlock(selectedBlockData)
        blockObj.xScale, blockObj.yScale, blockObj.alpha = 0.3, 0.3, 0
        transition.to(blockObj, {time = 500, xScale = 1, yScale = 1, alpha = 1, transition = easing.inOutQuad})
        
        table.insert(addedDatas, deep_copy(selectedBlockData))
        table.insert(currentScript, insertPos, selectedBlockData)
        table.insert(blocksObjects, insertPos, blockObj)
        
        scrollview:insert(blockObj)
        setupBlockObject(blockObj)
        
        insertPos = insertPos + 1
        
        if special_blocks[selectedBlockData.index] then
            local special_list = special_blocks[selectedBlockData.index]
            for j = 1, #special_list do
                local s_block = special_blocks_struct[special_list[j]] or {index = "end", params = {}}
                local s_obj = instantiateBlock(s_block)
                
                table.insert(addedDatas, deep_copy(s_block))
                table.insert(currentScript, insertPos, s_block)
                table.insert(blocksObjects, insertPos, s_obj)
                
                scrollview:insert(s_obj)
                setupBlockObject(s_obj)
                insertPos = insertPos + 1
            end
        end
        
        pushAction({ type = "add", index = initialInsertPos, dataList = addedDatas })
        
        recalculatePositions(false)
        
        local _, absY = blockObj:localToContent(0, 0)
        touchBlock({target = blockObj, phase = "began", id = 1, x = sw / 2, y = absY, autoMove = true})
    end
	
    local totalBlocks = #currentScript
    
    if totalBlocks > 50 then
	    local old_back = special_back_fun
		special_back_fun = function() end
        local loadingGroup = display.newGroup()
        local loadingBg = display.newRect(loadingGroup, sw/2, sh/2, sw, sh)
        loadingBg.isVisible = false
        loadingBg.isHitTestable = true
        loadingBg:addEventListener("touch", function() return true end)
        
		local loading = PonosUi.newLoader(loadingGroup, sw/2, sh/2)
		
        local loadingText = display.newText({
            parent = loadingGroup,
            text = string.format("Загрузка блоков... %d%%", 0),
            x = sw/2, y = sh/2+60,
            font = app.font,
            fontSize = app.fontsize1,
            align = "center"
        })
		loadingText:setFillColor(unpack(app.color.standartTextColor))
        group:insert(loadingGroup)

        local currentIndex = 1
        local chunkSize = 10

        local function loadChunk()
            local endIndex = math.min(currentIndex + chunkSize - 1, totalBlocks)
            
            for i = currentIndex, endIndex do
                local blockObj = instantiateBlock(currentScript[i])
                blocksObjects[i] = blockObj
                scrollview:insert(blockObj)
                setupBlockObject(blockObj)
				blockObj.isVisible = false
            end
            
            currentIndex = endIndex + 1
            
            local percent = math.floor(((currentIndex - 1) / totalBlocks) * 100)
            loadingText.text = string.format("Загрузка блоков... %d%%", tostring(percent))
            
            if currentIndex <= totalBlocks then
                timer.performWithDelay(1, loadChunk)
            else
                display.remove(loadingGroup)
				special_back_fun = old_back
                recalculatePositions(false, true)
            end
        end
        
        loadChunk()
    else
        for i = 1, totalBlocks do
            local blockObj = instantiateBlock(currentScript[i])
            blocksObjects[i] = blockObj
            scrollview:insert(blockObj)
            setupBlockObject(blockObj)
        end
        recalculatePositions(false)
    end
    
    recalculatePositions(false)
    
    local actiongroup = display.newGroup()
    group:insert(actiongroup)
end

return M