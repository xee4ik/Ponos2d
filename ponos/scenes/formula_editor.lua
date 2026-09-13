local copied_elements = {}

function scene_formula_editor(data, callback)
    local group = display.newGroup()
    
    local bg = display.newRect(group, 0, 0, sw, sh)
    bg.anchorX, bg.anchorY = 0, 0
    bg:setFillColor(unpack(app.color.mainBackgroundColor))
    
    local topbar = PonosUi.newTopBar(group, app.words[38], nil, function(e) end)
    local bar2height = topbar.barheight / 1.18
    
    local new_data = data or {}
    local currentParamIdx = new_data.parameter or 1
    local params = new_data.block.params or {}
    
    local function saveAndExit()
        new_data.parameter = currentParamIdx
        callback(new_data)
        transition.to(group, {transition = easing.outQuad, time = 300, x = app.content / 5, y = 0, alpha = 0})
    end

    PonosUi.newTopBar2(group, '', {{
        id = "back", 
        icon = "res/ui/back.png", 
        callback = saveAndExit
    }})
    
    local blockObj = create_block(new_data.block or { index = "aboba", params = {} })
    local h = blockObj.height

    local block_scrollview = PonosUi.newScrollView({
        x = sw / 2,
        y = app.topbarheight + bar2height,
        width = sw,
        height = math.max(50, math.min(h, 150)),
        horizontalScrollDisabled = true,
    })

    group:insert(block_scrollview)
    block_scrollview:insert(blockObj)
    
    local function getFormula(i)
        return new_data.block.params[i]
    end

    local formula_scrollview
    local current_formula = {}
    local cursor_pos = 1
    local open_i = currentParamIdx
    local formulachoose = false
    local back_choose_fn = nil
    
    local elements_group = display.newGroup()
    local rendered_elements = {}
    
    local cursor_rect = display.newRect(elements_group, 0, 0, 4, app.fontsize2 + 5)
    cursor_rect.anchorY = 0
    cursor_rect.anchorX = 1
    cursor_rect:setFillColor(unpack(app.color.cursorColor))
    transition.blink(cursor_rect, {time = 2000})
    
    local function get_color(type)
        if type == "number" then return app.color.redactorFormulaBgElementsCode.numberColor
        elseif type == "function" then return app.color.redactorFormulaBgElementsCode.functionColor
        elseif type == "string" then return app.color.redactorFormulaBgElementsCode.stringColor
        else return app.color.redactorFormulaBgElementsCode.defaultColor end
    end
    
    local pad = app.pad / 2

    local function updateTextEl(el, text, type)
        el.color = get_color(type)
        el.type = type
        el.txt.text = text or "ERROR"
        el.bg.width = el.txt.width + app.pad
        el.bg.height = el.txt.height
        
        el.nonvisiblerect.width = el.bg.width + pad
        el.nonvisiblerect.height = el.txt.height + pad
        el.nonvisiblerect.x = -pad
        
        if el.selected then
            el.bg:setFillColor(el.color[1] / 1.5, el.color[2] / 1.5, el.color[3] / 1.5, 1)
            el.txt:setFillColor(unpack(app.color.formulaTextColor))
        else
            el.bg:setFillColor(el.color[1] / 2, el.color[2] / 2, el.color[3] / 2, 0.95)
            el.txt:setFillColor(
                app.color.formulaTextColor[1] * 0.9,
                app.color.formulaTextColor[2] * 0.9,
                app.color.formulaTextColor[3] * 0.9
            )
        end
    end
    
    local function newTextEl(text, type)
        local el = display.newGroup()
        
        local nonvisiblerect = display.newRect(el, 0, 0, 0, 0)
        nonvisiblerect.alpha = 0.01
        nonvisiblerect.anchorX, nonvisiblerect.anchorY = 0, 0

        local bg = display.newRoundedRect(el, 0, 0, 0, 0, app.fontsize3 / 4)
        bg.anchorX, bg.anchorY = 0, 0
        bg.x = 0
        el.bg = bg
        
        local txt = display.newText({
            parent = el,
            x = app.pad / 2,
            y = 0,
            text = "",
            fontSize = app.fontsize2,
            font = app.font
        })
        txt.anchorX, txt.anchorY = 0, 0
        el.txt = txt
        el.nonvisiblerect = nonvisiblerect
        bg.height = txt.height
        
        el.selected = false
        el.select = function(item)
            el.selected = item
            updateTextEl(el, el.txt.text, el.type)
        end
        
        updateTextEl(el, text, type)
        return el
    end
    
    local function clear_all_selections()
        for _, el in ipairs(rendered_elements) do
            if el then el.select(false) end
        end
    end
    
    local formula_text_update
    formula_text_update = function(formula)
        formula = formula or {}
        current_formula = formula
        
        local currenty = 0
        local currentx = pad
        local cursor_coords = {{x = currentx, y = currenty}}

        for i = 1, #formula do
            local type = formula[i][1]
            local f_text = binini_formula and binini_formula(formula[i]) or formula[i][2]
            local text = rendered_elements[i]
            
            if not text then
                text = newTextEl(f_text, type)
                elements_group:insert(text)
                rendered_elements[i] = text
                
                text.x = cursor_rect.x
                text.y = cursor_rect.y
                text.alpha = 1
                
                text:addEventListener("touch", function(event)
                    local scrollx = formula_scrollview:getContentPosition()
                    if event.phase == "ended" then
                        local localX = event.x - scrollx - text.x
                        cursor_pos = (localX < text.bg.width / 2) and text.idx or (text.idx + 1)
                        
                        local isOffsetOutOfBounds = math.abs(localX - text.bg.width / 2) > (text.bg.width / 6)
                        clear_all_selections()
                        
                        if not isOffsetOutOfBounds then
                            local isClickingSelection = text.selected
                            if not isClickingSelection then
                                local startIdx, endIdx = text.idx, text.idx
                                if current_formula[startIdx][1] == "func" then
                                    local nextEl = current_formula[startIdx + 1]
                                    if nextEl and nextEl[1] == "function" and nextEl[2] == "(" then
                                        local openBrackets = 1
                                        endIdx = startIdx + 1
                                        while endIdx < #current_formula and openBrackets > 0 do
                                            endIdx = endIdx + 1
                                            local nEl = current_formula[endIdx]
                                            if nEl[1] == "function" and nEl[2] == "(" then
                                                openBrackets = openBrackets + 1
                                            elseif nEl[1] == "function" and nEl[2] == ")" then
                                                openBrackets = openBrackets - 1
                                            end
                                        end
                                    end
                                end

                                for k = startIdx, endIdx do
                                    if rendered_elements[k] and rendered_elements[k].select then
                                        rendered_elements[k].select(true)
                                    end
                                end
                            end
                        end
                        formula_text_update(current_formula)
                    elseif event.phase == "moved" then
                        local delta = math.abs(event.x - event.xStart) + math.abs(event.y - event.yStart)
                        if delta > (app.touchDelta or 10) then
                            display.getCurrentStage():setFocus(event.target, nil)
                            event.target.isFocus = false
                            if formula_scrollview then formula_scrollview:takeFocus(event) end
                        end
                    end
                    return true
                end)
            else
                updateTextEl(text, f_text, type)
            end
            
            text.idx = i
            text.x, text.y = currentx, currenty
            currentx = currentx + text.bg.width + pad
            cursor_coords[i + 1] = {x = currentx, y = currenty}
        end
        
        while #rendered_elements > #formula do
            local el = table.remove(rendered_elements)
            el.xScale, el.yScale = 0.5, 0.5
            display.remove(el)
        end

        cursor_pos = math.max(1, math.min(cursor_pos, #formula + 1))
        local active_coord = cursor_coords[cursor_pos] or {x = pad, y = 0}
        transition.to(cursor_rect, {x = active_coord.x, y = active_coord.y, time = 300, transition = easing.outQuart})
    end

    local function open_cell(i)
        local f = getFormula(i)
        open_i = i
        cursor_pos = #(f or {}) + 1
        formula_text_update(f)
        return f
    end

    local function touchParameter(event)
        local obj = event.target
        local blockGroup = obj.block
        local paramData = blockGroup.cells[obj.idParameter]
        
        if event.phase == "began" then
            currentParamIdx = obj.idParameter or currentParamIdx
            if paramData and paramData[1] == "cell" then paramData[3].yScale = 1.6 end
            display.getCurrentStage():setFocus(obj, event.id)
        elseif event.phase == "moved" then
            local delta = math.abs(event.x - event.xStart) + math.abs(event.y - event.yStart)
            if delta > app.touchDelta then
                display.getCurrentStage():setFocus(obj, nil)
                obj.isFocus = false
                block_scrollview:takeFocus(event)
                if paramData and paramData[1] == "cell" then paramData[3].yScale = 1 end
            end
            return true
        elseif event.phase == "ended" or event.phase == "cancelled" then
            if paramData and paramData[1] == "cell" then
                paramData[3].yScale = 1
                open_cell(obj.dataI)
            end
            display.getCurrentStage():setFocus(obj, nil)
        end
        return true
    end
    
    blockObj.blockData = new_data
    blockObj:addEventListener("touch", function(e) block_scrollview:takeFocus(e) end)
    for j = 1, #blockObj.cells do
        blockObj.cells[j][2]:addEventListener("touch", touchParameter)
    end
    blockObj.y = 30
    
    local function insertElement(el_type, el_value)
        local hasSelection = false
        local insert_idx = cursor_pos

        for i = #rendered_elements, 1, -1 do
            if rendered_elements[i].selected then
                table.remove(current_formula, i)
                insert_idx = i
                hasSelection = true
            end
        end
        if hasSelection then cursor_pos = insert_idx end
        
        clear_all_selections()
        local canMerge = false
        if el_type == "number" or el_value == "." and cursor_pos > 1 then
            local prevElement = current_formula[cursor_pos - 1]
            if prevElement and prevElement[1] == "number" then
                prevElement[2] = tostring(prevElement[2]) .. tostring(el_value)
                canMerge = true
            end
        end
        
        if not canMerge then
            table.insert(current_formula, cursor_pos, {el_type, el_value})
            cursor_pos = cursor_pos + 1
        end
        
        formula_text_update(current_formula)
    end

    local function touchButtonErase()
        local hasSelection = false
        for i = #rendered_elements, 1, -1 do
            if rendered_elements[i].selected then
                table.remove(current_formula, i)
                if cursor_pos > i then cursor_pos = cursor_pos - 1 end
                hasSelection = true
            end
        end
        
        clear_all_selections()
        
        if not hasSelection and cursor_pos > 1 then
            local targetIdx = cursor_pos - 1
            local el = current_formula[targetIdx]
            
            if el[1] == "number" then
                local strVal = tostring(el[2])
                if #strVal > 1 then
                    el[2] = strVal:sub(1, -2)
                else
                    table.remove(current_formula, targetIdx)
                    cursor_pos = cursor_pos - 1
                end
            else
                table.remove(current_formula, targetIdx)
                cursor_pos = cursor_pos - 1
            end
        end
        
        formula_text_update(current_formula)
    end

    local function touchButtonBack()
        if cursor_pos > 1 then
            cursor_pos = cursor_pos - 1
            formula_text_update(current_formula)
        end
    end

    local function touchButtonFront()
        if cursor_pos <= #current_formula then
            cursor_pos = cursor_pos + 1
            formula_text_update(current_formula)
        end
    end
    
    local function touchButtonABC()
        local selectedIndices = {}
        for i, el in ipairs(rendered_elements) do
            if el.selected then
                table.insert(selectedIndices, i)
            end
        end

        local editTarget = nil
        if #selectedIndices == 1 then
            local idx = selectedIndices[1]
            if current_formula[idx] and current_formula[idx][1] == "string" then
                editTarget = current_formula[idx][2]
            end
        end

        local dialog = new_input_alert({header = app.words[39], description = app.words[479]}, function(text)
            if text and text ~= "" then
                insertElement("string", text)
            end
        end)

        if editTarget and dialog.text then
            dialog.text(editTarget)
        end
    end
    
    local function touchButtonKEY()
        new_input_alert({header = app.words[477], description = app.words[478]}, function(text)
            insertElement("key", text)
        end, true)
    end
    
    local function touchButtonColor()
        native.setKeyboardFocus(nil)
        
        local isEdit = cursor_pos > 1 and current_formula[cursor_pos - 1][1] == "string"
        local currentColor = isEdit and utils.hexToRgb(current_formula[cursor_pos - 1][2]) or {0, 0, 0}
        local tempR, tempG, tempB = unpack(currentColor)

        local picker
        local dialog

        local function formatHex()
            return utils.rgbToHex({
                math.floor(tempR * 255 + 0.5), 
                math.floor(tempG * 255 + 0.5), 
                math.floor(tempB * 255 + 0.5)
            })
        end

        local dialogButtons = {
            { text = app.words[25], callback = function() dialog.close() end },
            { text = app.words[480], callback = function()
                insertElement("string", formatHex())
                dialog.close()
            end}
        }

        dialog = new_dialog({
            description = app.words[481],
            buttons = dialogButtons
        })

        dialog.anchorY = 0
        local example = {}
        
        picker = display.newPickerColor(function(rgb)
            tempR, tempG, tempB = rgb[1], rgb[2], rgb[3]
            example.rect:setFillColor(tempR, tempG, tempB)
            local maxColor = math.max(tempR, tempG, tempB)
            example.text:setFillColor((1 - maxColor <= 0.5) and 0 or 1, (1 - maxColor <= 0.5) and 0 or 1, (1 - maxColor <= 0.5) and 0 or 1)
            example.text.text = formatHex()
        end)
        
        picker.xScale, picker.yScale = 0.65, 0.65
        picker.y = -40 - app.pad
        dialog:insert(picker)

        example.rect = display.newRoundedRect(0, (picker.height * 0.68) / 2, picker.width * 0.68 - app.pad * 2, 80, 32)
        example.rect:setFillColor(tempR, tempG, tempB)
        
        example.text = display.newText({
            x = example.rect.x,
            y = example.rect.y,
            width = example.rect.width,
            text = formatHex(),
            fontSize = app.fontsize1 * 2,
            align = "center",
            font = app.font
        })
        
        dialog:insert(example.rect)
        dialog:insert(example.text)
        dialog.customUserContentHeight = picker.height * 0.68 + 80 + app.pad * 2
        
        picker:setRGB(tempR, tempG, tempB)
        dialog.recalc()
    end

    local function touchButtonCopy()
        new_s_warning(app.words[40])
        copied_elements = {}
        local hasSelection = false
        
        for i, el in ipairs(rendered_elements) do
            if el.selected then
                hasSelection = true
                table.insert(copied_elements, {current_formula[i][1], current_formula[i][2]})
            end
        end
        
        if not hasSelection then
            for _, f in ipairs(current_formula) do
                table.insert(copied_elements, {f[1], f[2]})
            end
        end
        
        clear_all_selections()
    end

    local function touchButtonPaste()
        clear_all_selections()
        if #copied_elements > 0 then
            for _, item in ipairs(copied_elements) do
                table.insert(current_formula, cursor_pos, {item[1], item[2]})
                cursor_pos = cursor_pos + 1
            end
            formula_text_update(current_formula)
        end
    end
    
    local function scene_formula_choose(key, title)
        formulachoose = true
        local groupa = display.newGroup()
        local bga = display.newRect(groupa, 0, 0, sw, sh)
        bga.anchorX, bga.anchorY = 0, 0
        bga:setFillColor(unpack(app.color.mainBackgroundColor))
        bga:addEventListener("touch", function() return true end)
        
        PonosUi.newTopBar(groupa, title or "", nil, function() end)
        
        local formulas = all_formulas[key] or {}
        local currenty = 0
        local elheight = 62
        
        local scrollviewa = PonosUi.newScrollView({
            x = sw / 2,
            y = app.topbarheight,
            width = sw,
            height = sh - app.topbarheight,
            horizontalScrollDisabled = true,
            verticalVel = 100,
        })
        groupa:insert(scrollviewa)
        
        for i = 1, #formulas do
            local text = display.newText({
                x = sw / 2, y = currenty + elheight / 2 + app.pad, width = sw - app.pad * 2,
                text = formulas[i][1], fontSize = app.fontsize2, font = app.font
            })
            scrollviewa:insert(text)
            text:setFillColor(unpack(app.color.standartTextColor))
            currenty = currenty + elheight + app.pad * 2
            
            local list = formulas[i][2]
            for j = 1, #list do
                local btn = PonosUi.newButton(function(event)
                    if event.phase == "began" then
                        scrollviewa:stop()
                    elseif event.phase == "moved" then
                        local delta = math.abs(event.x - event.xStart) + math.abs(event.y - event.yStart)
                        if delta > app.touchDelta then
                            display.getCurrentStage():setFocus(event.target, nil)
                            event.target.isFocus = false
                            scrollviewa:takeFocus(event)
                        end
                        return true
                    elseif event.phase == "ended" then
                        for f = 1, #list[j] do
                            insertElement(list[j][f][1], list[j][f][2])
                        end
                        formulachoose = false
                        transition.to(groupa, {alpha = 0, time = 100, onComplete = function()
                            display.remove(groupa)
                        end})
                    end
                end, {
                    x = sw / 2, y = currenty, width = sw - app.pad * 2, height = elheight,
                    text = make_formula and make_formula(list[j]) or "F",
                    fontSize = app.fontsize1, rounded = elheight, text_align = "left"
                }, scrollviewa)
                btn.anchorY = 0
                currenty = currenty + btn.height + app.pad
            end
        end
        
        back_choose_fn = function()
            transition.to(groupa, {alpha = 0, x = -sw / 2, time = 100, onComplete = function()
                display.remove(groupa)
            end})
            formulachoose = false
        end
        
        PonosUi.newButton(function(event)
            if event.phase == "moved" then
                local delta = math.abs(event.x - event.xStart) + math.abs(event.y - event.yStart)
                if delta > app.touchDelta then
                    display.getCurrentStage():setFocus(event.target, nil)
                    event.target.isFocus = false
                    scrollviewa:takeFocus(event)
                end
                return true
            elseif event.phase == "ended" then
                back_choose_fn()
            end
        end, {x = sw / 2, y = currenty + 40 + elheight, height = 80, width = 80, text = "", rounded = 30, icon = {path = "res/ui/back.png", position = "center"}}, scrollviewa)
    end
    
    local function properties_f() scene_formula_choose("properties", app.words[41]) end
    local function logic_f() scene_formula_choose("logic", app.words[42]) end
    local function func_f() scene_formula_choose("func", app.words[43]) end
    local function device_f() scene_formula_choose("device", app.words[44]) end
    local function proj_f() scene_formula_choose("project", app.words[45]) end
    local function data_f() scene_formula_choose("data", app.words[46]) end
    
    local key_space = { x = sw, y = math.min(sh - block_scrollview.height - app.topbarheight - bar2height - 50, sh / 2) }
    local keys_group = display.newGroup()
    group:insert(keys_group)
    
    local keys_bg = display.newRect(keys_group, sw / 2, 0, sw, key_space.y)
    keys_bg.fill = app.color.formulaEditorNumPadGradient
    
    local color = app.color.formulaEditorButtonsColours
    local tableButtons = {
        { {id="space"}, {id="space"}, {id="copy", fn=touchButtonCopy, color=color.action, type="action", ic = "res/ui/copy.png"}, {id="paste", fn=touchButtonPaste, color=color.action, type="action", ic = 'res/ui/paste.png'} },
        { {id=app.words[47], fn=func_f, color=color.default, type="menu"}, {id=app.words[48], fn=properties_f, color=color.default, type="menu"} },
        { {id=app.words[49], fn=device_f, color=color.default, type="menu"}, {id=app.words[50], fn=logic_f, color=color.default, type="menu"}, {id=app.words[51], fn=proj_f, color=color.default, type="menu"}, {id=app.words[52], fn=data_f, color=color.default, type="menu"} },
        { {id="(", fn="(", color=color.default, type="function"}, {id=7, fn=7, color=color.default, type="number"}, {id=8, fn=8, color=color.default, type="number"}, {id=9, fn=9, color=color.default, type="number"}, {id=")", fn=")", color=color.default, type="function"}, {id="⌫", fn=touchButtonErase, spam=true, color=color.default, type="action", ic = 'res/ui/backspace.png'} },
        { {id="ABC", fn=touchButtonABC, color=color.default, type="action", ic = 'res/editor/text.png'}, {id=4, fn=4, color=color.default, type="number"}, {id=5, fn=5, color=color.default, type="number"}, {id=6, fn=6, color=color.default, type="number"}, {id="÷", fn="/", color=color.default, type="function"}, {id="×", fn="*", color=color.default, type="function"} },
        { {id="color", fn=touchButtonColor, color=color.default, type="action", ic="res/ui/palette.png", sc = true}, {id=1, fn=1, color=color.default, type="number"}, {id=2, fn=2, color=color.default, type="number"}, {id=3, fn=3, color=color.default, type="number"}, {id="-", fn="-", color=color.default, type="function"}, {id="+", fn="+", color=color.default, type="function"} },
        { {id="<-", fn=touchButtonBack, spam=true, color=color.default, type="action", ic = 'res/ui/back.png'}, {id="->", fn=touchButtonFront, spam=true, color=color.default, type="action", ic = 'res/ui/continue.png'}, {id=0, fn=0, color=color.default, type="number"}, {id=".", fn=".", color=color.default, type="function"}, {id="=", fn="=", color=color.default, type="function"}, {id="key", fn=touchButtonKEY, color=color.default, type="action", ic='res/ui/key.png'} },
    }

    local function touchButton(event)
        local target = event.target
        if event.phase == "began" then
            display.getCurrentStage():setFocus(target, event.id)
        elseif event.phase == "ended" or event.phase == "cancelled" then
            display.getCurrentStage():setFocus(target, nil)
            if event.phase == "ended" then
                local btnType = target.buttonType
                local btnFn = target.functional
                if btnType == "number" or btnType == "string" or btnType == "function" then
                    insertElement(btnType, btnFn)
                elseif type(btnFn) == "function" then
                    btnFn()
                end
            end
        end
        return true
    end

    local numRows = #tableButtons
    local heightButton = (key_space.y - pad) / numRows

    for i = 1, numRows do
        local numCols = #tableButtons[i]
        local widthButton = (key_space.x - (numCols + 1) * pad) / numCols

        for i2 = 1, numCols do
            local b = tableButtons[i][i2]
            if b.id ~= "space" then
                local btnX = pad + (i2 - 1) * (widthButton + pad)
                local btnY = -keys_group.height / 2 + (i - 1) * heightButton + pad
                local btnT = b.ic and "" or tostring(b.id)
                
                local button = PonosUi.newButton(touchButton, {
                    x = btnX, y = btnY, width = widthButton, height = heightButton - pad, 
                    text = btnT, colorBg = b.color, fontSize = 24, line_width = 0, 
                    rounded = heightButton / 2.5, icon = {path = b.ic, size = 24 * 1.4, saveColor = b.sc}
                }, keys_group)
                
                button.anchorX, button.anchorY = 0, 0
                button.functional = b.fn
                button.buttonType = b.type
                button.isSpam = b.spam
            end
        end
    end
    
    keys_group.y = sh - key_space.y / 2 - (getBottomNavHeight and getBottomNavHeight() or 0)
    
    formula_scrollview = PonosUi.newScrollView({
        x = sw / 2,
        y = topbar.barheight + bar2height + block_scrollview.height,
        width = sw,
        height = sh - (topbar.barheight + bar2height + block_scrollview.height + key_space.y) - (getBottomNavHeight and getBottomNavHeight() or 0),
        horizontalVel = 100
    })
    
    formula_scrollview:insert(elements_group)
    open_cell(data.parameter)
    group:insert(formula_scrollview)
    
    special_back_fun = function()
        if formulachoose and back_choose_fn then
            back_choose_fn()
        else
            saveAndExit()
        end
    end
end