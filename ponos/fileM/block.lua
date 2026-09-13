-- Функция для построения блока. Принимаем крязные таблички, а строим красивый блок :))

function create_block(block, BLOCK_WIDTH)

    if block.index == nil then
        block.index = {index = "test"}
    end
	local BLOCK_WIDTH = BLOCK_WIDTH or sw

    local info_block = all_blocks[block.index]

    if all_blocks[block.index] == nil then
        info_block = {
            index = "block", 
            color = {0.87,0.87,0.87}, 
            params = {
                {"text", "Неизвестный блок "}
            },
        }
    end
    
    local group = display.newGroup()
    
    group.cells = {}
    
    local color = info_block.color
    local bg
    local top
    local bottom
    local top_fill
    local bottom_fill
    local currenty = 0
    
    if info_block.type == "event" then
        bg = display.newImageRect("res/block/event_fill.png",BLOCK_WIDTH,0)
        top = display.newImage("res/block/event_top.png")
        bottom = display.newImage("res/block/event_bottom.png")
        top_fill = display.newImage("res/block/event_top_fill.png")
        bottom_fill = display.newImage("res/block/event_bottom_fill.png")
        top_fill.width = BLOCK_WIDTH-top.width
        bottom_fill.width = BLOCK_WIDTH-bottom.width
        top_fill.x = top.width
        bottom_fill.x = bottom.width
        top_fill.anchorX = 0
        bottom_fill.anchorX = 0
        top.anchorX = 0
        bottom.anchorX = 0
        bg.anchorX = 0
        currenty = 30
    else
        bg = display.newImageRect("res/block/fill.png",BLOCK_WIDTH,0)
        top = display.newImage("res/block/top.png")
        bottom = display.newImage("res/block/bottom.png")
        top_fill = display.newImage("res/block/top_fill.png")
        bottom_fill = display.newImage("res/block/bottom_fill.png")
        top_fill.width = BLOCK_WIDTH-top.width
        bottom_fill.width = BLOCK_WIDTH-bottom.width
        top_fill.x = top.width
        bottom_fill.x = bottom.width
        top_fill.anchorX = 0
        bottom_fill.anchorX = 0
        top.anchorX = 0
        bottom.anchorX = 0
        bg.anchorX = 0
        currenty = 4
    end
    
    bottom_fill:setFillColor(color[1],color[2],color[3])
    top_fill:setFillColor(color[1],color[2],color[3])
    top:setFillColor(color[1],color[2],color[3])
    bottom:setFillColor(color[1],color[2],color[3])
    bg:setFillColor(color[1],color[2],color[3])
    
    group:insert(top_fill)
    group:insert(bottom_fill)
    group:insert(bg)
    group:insert(top)
    group:insert(bottom)
    
    group.image1 = top 
    group.image2 = bottom
    
    local menu = display.newImage("res/block/menu.png") 
    menu.x = 45
    group:insert(menu)
    
    local params = info_block.params
    
    local content = display.newGroup()
    group:insert(content)
    
    local start_y = currenty 
    
    function group:rebuild(newData)
        if newData then
            block.params = newData
        end
        
        for i = content.numChildren, 1, -1 do
            if content[i] then
                content[i]:removeSelf()
            end
        end
        
        group.cells = {}
        
        local size = 28
        local leftwall = 90
        local rightwall = BLOCK_WIDTH-app.pad
        local currentx = leftwall
        local widthel = 0
        local pad = size/2
        local cy = start_y + pad/4
		local curII = 1
        
        local function enterpage()
            currentx = leftwall
            cy = cy + size + 4
			curII = 1
        end
        
        local i2 = 1
        for i = 1, #params do
            local parameter = display.newGroup()
            content:insert(parameter)
            local t = params[i]
            parameter.dataI = i2
            
            if t[1] == "text" then
                local text = display.newText({
                    parent = parameter,
                    text = t[2],
                    x = 0,
                    y = 0,
                    fontSize = app.fontsizeB,
					font = app.fontMedium
                })
                text.anchorX = 0
                widthel = text.width + app.pad
                if currentx + text.width > rightwall then
				    if curII == 1 then
					    local w = utf8.len(text.text)
						local origw = w
					    while currentx + text.width > rightwall do
						    text.text = utf8.sub(t[2], 1, w, 1)..".."
							w = w-1
						end
					else
					    enterpage()
					end
                    --enterpage()
                end
                parameter.x, parameter.y = currentx, cy
                
            elseif t[1] == "cell" then
                local rect = display.newRect(parameter, 0, size/2, size, 2)
                local cellValue = display.newText({
                    parent = parameter,
                    x = 0,
                    y = 0,
                    text = utf8.sub(make_formula(block.params[i2]), 1, 14, 1),
                    fontSize = app.fontsizeB/1.2,
					font = app.font
                })
                i2 = i2 + 1
                rect.anchorX = 0
                rect.width = cellValue.width
                cellValue.anchorX = 0
                widthel = rect.width + app.pad
                
                if currentx + rect.width > rightwall then
                    enterpage()
                end
                parameter.x, parameter.y = currentx, cy
                
                table.insert(group.cells, { "cell", parameter, rect, cellValue })
                
                parameter.idParameter = #group.cells
                parameter.block = group
                parameter.typeParameter = "cell"
                
                
            elseif t[1] == "choose" then
                local rect = display.newRoundedRect(parameter, 0, 0, size*6+8, size+8, 4)
                local drop_open = display.newImageRect("res/ui/triangle.png", size/1.3, size/1.3)
                parameter:insert(drop_open)
                drop_open.x = rect.width - 4 - size/2
                drop_open.rotation = 90
                drop_open.state = function(data)
                   
                end
                rect.alpha = 0.18
                rect:setFillColor(color[1]*1.5, color[2]*1.5, color[3]*1.5)
				print(json.encode(blocks_choose[t[2]]))
				local resu
				for find = 1, #blocks_choose[t[2]] do
				    if blocks_choose[t[2]][find][2] == block.params[i2] then resu = blocks_choose[t[2]][find][1]; break end
				end
                local cellValue = display.newText({
                    parent = parameter,
                    x = 4,
                    y = 0,
                    text = resu or "ничего",
                    fontSize = app.fontsizeB/1.2,
                    width = rect.width-size,
					font = app.font
                })
                i2 = i2 + 1
                rect.anchorX = 0
                cellValue.anchorX = 0
                widthel = rect.width + app.pad
                
                if currentx + rect.width > rightwall then
                    enterpage()
                end
                parameter.x, parameter.y = currentx, cy
                
                table.insert(group.cells, { "choose", parameter, rect, cellValue })
                
                parameter.idParameter = #group.cells
				parameter.idChoose = t[2]
                parameter.block = group
                parameter.typeParameter = "choose"
                
            elseif t[1] == "slider" then
                local object = PonosUi.newSlider(function(event) 
				    block.params[i2] = event
				end, {x = 0, y = 0, width = size*6, height = 8, min = 0, max = 1, value = block.params[i2]})
				parameter:insert(object)
				widthel = object.width
				if currentx + widthel > rightwall then
                    enterpage()
                end
				parameter.x, parameter.y = currentx, cy
                parameter.idParameter = #group.cells
                parameter.block = group
                parameter.typeParameter = "slider"
			
			elseif t[1] == "editText" then
			    if curII ~= 1 then
					enterpage()
				end
				local text = display.newText({
                    parent = parameter,
                    text = block.params[i2],
                    x = 0,
                    y = 0,
					width = rightwall-leftwall,
					height = size,
                    fontSize = app.fontsizeB,
					font = app.font
                })
				text:setFillColor(48/255,169/255,209/255) --grgrg blue
                text.anchorX = 0
                widthel = text.width + app.pad
                local object = display.newRect(parameter, 0, 0, text.width, size)
				object.alpha = 0.01
				object.anchorX = 0
				table.insert(group.cells, { "editText", parameter, object, text })
				parameter.x, parameter.y = currentx, cy
                parameter.idParameter = #group.cells
                parameter.block = group
                parameter.typeParameter = "editText"
                
            elseif t[1] == "enter" then
                enterpage()
            end
			
			curII = curII+1
            
            currentx = currentx + widthel
            widthel = 0
        end
        
        top.y = -size/2
        bottom.y = cy + size + pad/3
        bg.height = bottom.y - top.y - top.height - bottom.height + size*1.3
        
        bg.y = bottom.y/2 - size/4
        if info_block.type == "event" then
            bg.y = bottom.y/2 - size/4 + 14/2
        end
        
        top_fill.y = top.y
        bottom_fill.y = bottom.y
		
        
        menu.y = bg.y - app.pad/4
    end

    group:rebuild(block.params)
    
    return group
end