local M = {}

-- Это сцена с нопциями проекта. Тут есть система типо с разделами, они создаютяся из таблички там внизу и обрабатываются в if elseif своего типа [что я выдал ххапхахпха]

function M.create(group, params)
    local bg = display.newRect(group, sw/2, sh/2, sw, sh)
    bg:setFillColor(app.color.mainBackgroundColor[1],app.color.mainBackgroundColor[2],app.color.mainBackgroundColor[3])
    
    local topbar = PonosUi.newTopBar(group, app.words[27], nil, function(e) end)
    local bar2height = topbar.barheight / 1.18
    
    local topbar2bg = display.newRect(group, 0, topbar.barheight, sw, bar2height) 
    topbar2bg:setFillColor(app.color.topBar2BgColor[1],app.color.topBar2BgColor[2],app.color.topBar2BgColor[3])
    
	local containerbar = display.newContainer(sw, bar2height)
	group:insert(containerbar)
	containerbar.y = topbar.barheight+bar2height/2
	
    local topbar2 = display.newText({
        parent = containerbar,
        x = 0,
        y = 0,
        text = project_data.project_name,
        fontSize = app.fontsize1,
		font = app.font,
    })
    topbar2bg.anchorX, topbar2bg.anchorY = 0, 0
	topbar2:setFillColor(app.color.topBar2TextColor[1],app.color.topBar2TextColor[2],app.color.topBar2TextColor[3])
    
    local scrollview = PonosUi.newScrollView({
        x = sw/2,
        y = topbar.barheight + bar2height,
        width = sw, 
        height = sh - topbar.barheight - bar2height, 
        hideBackground = true, 
        horizontalScrollDisabled = true
    }) 
    group:insert(scrollview) 

    local categoryGroups = {} 
    local buttonObjects = {}  
    local currentCategory = nil

    local categoryOrder = {
        category_main = 1,
        category_display = 2,
        category_build = 3
    }

    local function switchCategory(id)
        if currentCategory == id then return end

        local direction = 1 
        if currentCategory and categoryOrder[currentCategory] and categoryOrder[id] then
            if categoryOrder[id] < categoryOrder[currentCategory] then
                direction = -1
            else
                direction = 1
            end
        end
        
        if currentCategory and categoryGroups[currentCategory] then
            local oldGroup = categoryGroups[currentCategory]
            local targetX = -sw * 0.15 * direction 

            transition.to(oldGroup, {
                time = 180,
                alpha = 0,
                x = targetX, 
                transition = easing.outQuad,
                onComplete = function()
                    oldGroup.isVisible = false
                end
            })
        end

        for btnId, btnObj in pairs(buttonObjects) do
            if btnId ~= "back" then
                btnObj.alpha = (btnId == id) and 1.0 or 0.4
            end
        end

        currentCategory = id

        if categoryGroups[id] then
            local newGroup = categoryGroups[id]
            local startX = sw * 0.15 * direction

            newGroup.isVisible = true
            newGroup.alpha = 0
            newGroup.x = startX 
            
            transition.to(newGroup, {
                time = 220,
                alpha = 1,
                x = 0, 
                transition = easing.outCubic
            })
        end
    end

    local categories = {"category_main", "category_display", "category_build"}
    for i = 1, #categories do
        local catId = categories[i]
        local catGroup = display.newGroup()
        scrollview:insert(catGroup)
        catGroup.isVisible = false 
        categoryGroups[catId] = catGroup
		
		local title = ""
		local content = {}
		
		local function save_dat(id, dat)
		
		end
		
		if catId == "category_main" then
		    title = app.words[28]
			content = {
			    {type = "input", id = "project_name", text = app.words[29], value = project_data.project_name, key = "project_name"},
				{type = "button", id = "setProjectIcon", text = 'Установить иконку', description = "после установки иконки автоматические скриншоты будут отключены"},
				{type = "button", id = "deleteProject", text = app.words[30]},
			}
		elseif catId == "category_display" then
		    title = app.words[31]
		    content = {
			    --{type = "input", id = "screen_width", text = "ширина экрана", value = project_data.display_config.width},
				--{type = "input", id = "screen_height", text = "высота экрана", value = project_data.display_config.height},
				{type = "radio", key = "orientation", text = app.words[290], group = { {'portrait', app.words[291], "res/ui/vertical.png"}, {'landscape', app.words[292], "res/ui/horizontal.png"} }}
		    }
		elseif catId == "category_build" then
		    title = app.words[32]
		    content = {
				--{type = "header", text = "Модули запуска"},
				--{type = "checkBox", key = "module.utf8", text = "модуль utf8 для текста"},
				--{type = "checkBox", key = "module.behavior", text = "заготовленные поведения"},
				--{type = "checkBox", key = "module.ui", text = "XKit для интерфейса"},
				--{type = "text", text = "выключите ненужные модули для оптимизации размера собираемого кода"},
				{type = "button", id = "exportProjectFile", text = 'Экспортировать проект'},
				{type = "button", id = "getCode", text = app.words[293], description = app.words[294], color_text = {1, 1, 1}, locked = true },
				{type = "button", id = "getSolar2dProject", text = app.words[295], description = app.words[296], color_text = {1, 1, 1}, locked = true },
		    }
		end
        
        local ttitle = display.newText({
            parent = catGroup,
            text = title,
            x = sw / 2,
            y = 0,
            fontSize = app.fontsize1 * 1.1,
			align = "center",
			font = app.font
        })
		ttitle.y = ttitle.y + ttitle.height/2 + app.pad
		ttitle:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
		
		local line = display.newRect(catGroup, ttitle.x, ttitle.y + ttitle.height/2 + app.pad, math.max(sw/4, math.min(ttitle.width+app.pad*2, sw-app.pad*2)), 2)
		line:setFillColor(app.color.lineColor[1],app.color.lineColor[2],app.color.lineColor[3], app.color.lineColor[4])
		
		local yOffset = line.y + line.height/2+ app.pad
		
		for j = 1, #content do
		    local item = content[j]
			
			local id = item.id
		    
		    if item.type == "header" then
		        local headerText = display.newText({
		            parent = catGroup,
		            text = item.text,
		            x = sw / 2,
		            y = yOffset+app.pad,
		            fontSize = app.fontsize3,
		            align = "left",
					width = sw - app.pad * 2,
					font = app.font
		        })
				headerText.anchorY = 0
		        headerText:setFillColor(0.8, 0.8, 0.8)
		        yOffset = yOffset + headerText.height + (app.pad * 2)
				headerText:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
		        
		    elseif item.type == "text" then
		        local descText = display.newText({
		            text = item.text,
		            x = sw / 2,
		            y = yOffset+app.pad*2,
		            width = sw - (app.pad * 6),
		            fontSize = app.fontsize1 * 0.85,
		            align = "center",
					font = app.font
		        })
				local bgRect = display.newRoundedRect(catGroup, descText.x, descText.y-app.pad, descText.width+app.pad*2, descText.height+app.pad*2, app.pad*2)
				bgRect.anchorY = 0
				bgRect:setFillColor(0.15, 0.15, 0.15)
		        descText:setFillColor(app.color.textDescColor[1],app.color.textDescColor[2],app.color.textDescColor[3])
				descText.anchorY = 0
				catGroup:insert(descText)
		        yOffset = yOffset + descText.height + (app.pad * 4)
		        
		    elseif item.type == "input" then
			    local inputHeight = app.fontsize1 * 2.5
				local test = display.newText({
		            text = item.text,
		            x = app.pad,
		            y = 0,
		            fontSize = app.fontsize1,
		            align = "left",
					font = app.font
		        })
				local inputWidth = math.max(inputHeight*4, app.content/1.5, sw-test.width-app.pad*3)
				display.remove(test)
				local test = display.newText({
		            text = item.text,
		            x = app.pad,
		            y = 0,
		            fontSize = app.fontsize1,
		            align = "left",
					font = app.font,
					width = sw-inputWidth-app.pad*2
		        })
				inputHeight = math.max(app.fontsize1 * 2.5, test.height)
				display.remove(test)
				local key = item.key
				local inputLabel = display.newText({
		            parent = catGroup,
		            text = item.text,
		            x = app.pad,
		            y = 0,
		            fontSize = app.fontsize1,
					width = sw-inputWidth-app.pad*2,
		            align = "left",
					font = app.font,
					--height = inputHeight
		        })
		        inputLabel.anchorX = 0
				inputLabel:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
		        local input = display.newGroup()
	            catGroup:insert(input)
				input.x = sw - (inputWidth)/2
	            local inputRect = display.newRoundedRect(input, 0, 0, inputWidth-app.pad*2, inputHeight, 0)
                inputRect.alpha = 0.4
	            inputRect:setFillColor(0,0,0)
				local inputBoxContainer = display.newContainer(inputRect.width, inputRect.height)
	            local inputBox = display.newText({
				    text = item.value or 'ERROR',
				    x = 0,
					y = 0,
					width = inputRect.width- app.pad,
					fontSize = app.fontsize1*0.98,
					font = app.font
				})
				-- native.newTextField(0, 0, inputRect.width- app.pad, inputRect.height-app.pad) 
				if inputBox.height > inputRect.height then
				 inputBox.y = inputBox.height/2 - inputRect.height
				end
	            input:insert(inputBoxContainer)
				inputBoxContainer:insert(inputBox)
				
				input.y = yOffset+input.height/2
				
				inputLabel.y = yOffset+inputHeight/2
				
				inputRect:addEventListener("touch", function(event)
				if event.phase == "ended" then
				    local dialog = new_input_alert( {header = item.text, description = ""}, function(text)
						inputBox.text = text
						if inputBox.height > inputRect.height then
				         inputBox.y = inputBox.height/2 - inputRect.height
						else
						 inputBox.y = 0
				        end
						if key == "project_name" then
						    ponosFile["переименовать папку"](P_DIR..project_data.project_name, text)
						end
						project_data[key] = text
					end, true )
					dialog.text(inputBox.text)
					end
				end
				)
		        
		        yOffset = input.y + inputRect.height/2 + (app.pad * 2)
		        
		    elseif item.type == "button" then
		        local btnColor = item.color_text or {1, 1, 1} 
				local id = item.id
				
				local mute = item.locked
		        
				local g = display.newGroup()
				local up = display.newRect(g, 0,0, sw, app.pad)
				up.anchorX, up.anchorY = 0, 0
				up.alpha = 0
				local header = display.newText({
				    x = app.pad*2, y = up.height, width = sw-app.pad*4, parent = g,
					fontSize = app.fontsize1, text = item.text, font = app.font
				})
				header.anchorX, header.anchorY = 0, 0
				header:setFillColor(app.unpack(app.color.standartTextColor))
				
				local desc 
				if item.description then
				desc = display.newText({
				    x = app.pad*2, y = header.y+header.height+app.pad, width = sw-app.pad*4, parent = g,
					fontSize = math.floor(app.fontsize1*0.95), text = item.description, font = app.font
				})
				desc:setFillColor(app.unpack(app.color.textDescColor))
				else 
				desc = {height = header.height, y = header.y}
				end
				desc.anchorX, desc.anchorY = 0, 0
				
				local btn = PonosUi.newButton(function(event)
				    if mute then if event.phase == 'began' then new_warning('Функция в разработке') end return end
                    if event.phase == "ended" then
                        if id == "getCode" then
						    local dialog
							dialog = new_dialog({header = app.words[297], description = app.words[298] })
							local scroll = widget.newScrollView({
							    x = 0,
								y = 0,
								width = dialog.contentWidth,
								height = sh/1.5,
								hideBackground = true
							})
							dialog:insert(scroll)
							local lua = load_game(project_data, nil, true)
							local code = display.newText({
                                x = 25,
                            	y = 25,
                            	width = nil,
                                text = lua or "ERROR",
                            	fontSize = app.fontsize1
                            })
							code.anchorX = 0
							code.anchorY = 0
							scroll:insert(code)
							copy_pasteboard(lua)
							ponosFile["писать путь"]('build/'..project_data.project_name..'/main.lua', lua)
							
							dialog.recalc()
						end
						if id == "getSolar2dProject" then
							buildProjectFolder(project_data)
						end
						if id == "deleteProject" then
				            local dialog = new_dialog({header = app.words[299], description = app.words[24], buttons = { {text = app.words[300]}, {text = app.words[301], callback = function() ponosFile['удалить папку'](P_DIR..project_data.project_name); scene.goto("menu", {}); new_warning(string.format(app.words[302], "'"..project_data.project_name.."'")) end} } })
				        end
						if id == "setProjectIcon" then
				            local elements = { {'', 'default', 'res/ProjectIcons/Standart.png', true}, {'', 'importIcon', 'res/ui/add_photo.png'} }
							dropdown(nil, elements, function(b) 
							    if b then
							        local el = elements[b] 
							        local icon = P_DIR..project_data.project_name..'/icon.png'
							        ponosFile['удалить файл'](icon)
							        if el[2] == 'default' then 
							        	ponosFile["копировать из ресурсов"](el[3], icon)
							        elseif el[2] == "importIcon" then 
							            ponosFile["импортировать формат"](icon, 'image/*', function() end)
							        end
									
									if ponosFile["проверить существование"](icon) then 
									    project_data.automatic_screenshot = false
									end
							    end
							end, {x = event.x+80/2, y = event.y, width = 80, height = 80})
				        end
					elseif event.phase == "moved" then
					    scrollview:takeFocus(event)
                    end
                    return true
                end, {
                    x = app.pad, 
                    y = 0, 
                    width = sw-app.pad*2, 
                    height = desc.y+desc.height+app.pad,
					alpha = 1,
					text = '',
					rounded = 30,
					colorBg = app.color.settingsCardBgColor,
                }, g)
				btn.anchorX, btn.anchorY = 0, 0
				if desc.text then desc:toFront() end
				if header.text then header:toFront() end
				
				catGroup:insert(g)
				
				if mute then 
				 g.alpha = 0.86
				 
				 local lockSize = 45
				 local lock = display.newImageRect("res/lock.png", lockSize, lockSize)
                 if lock then
                     lock.x = sw/2
                     lock.y = yOffset+g.height/2
                     catGroup:insert(lock)
                 end
				end
				
				g.y = yOffset
                yOffset = yOffset + g.height + app.pad
			elseif item.type == "checkBox" then
			    local elHeight = 35+app.pad
				local check = PonosUi.newCheckBox(function(p) end, {x = sw-20-app.pad, y = yOffset+elHeight/2, size = 35} )
				catGroup:insert(check)
				
				local label = display.newText({
				    x = app.pad,
					y = yOffset + elHeight/2,
					width = sw-app.pad*2-check.width,
					text = item.text,
					fontSize = app.fontsize1*1.05,
					font = app.font
				})
				label.anchorX = 0
				catGroup:insert(label)
				label:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
				
				yOffset = yOffset + elHeight
			elseif item.type == "radio" then
			    local radioGroupa = item.group
			    local key = item.key
			    
			    local currentValue = project_data[key] or (radioGroupa[1] and radioGroupa[1][1])
			    
			    local radioWidget = PonosUi.newRadioGroup({
			        parent = catGroup,
			        options = radioGroupa,
			        key = key,
			        value = currentValue,
			        title = item.text,
			        x = app.pad,
			        y = yOffset,
			        fontSize = app.fontsize1,
			        titleFontSize = app.fontsize1 * 1.1,
			        callback = function(selectedValue)
			            project_data[key] = selectedValue
			            if save_dat then
			                save_dat(key, selectedValue)
			            end
			        end
			    })
			    
			    yOffset = yOffset + radioWidget.height + app.pad*2
		    end
		end
	end

    local topbar2btns = {
        {id = "back", icon = "res/ui/back.png"}, 
        {id = "category_main", icon = "res/ui/edit.png"}, 
        {id = "category_display", icon = "res/ui/vertical.png"}, 
        {id = "category_build", icon = "res/ui/cog.png"}
    }

    for i = 1, #topbar2btns do
        local id = topbar2btns[i].id
        local btn = PonosUi.newButton(function(e)
            if e.phase == "ended" then
                if id == "back" then
                    special_back_fun()
                else
                    switchCategory(id)
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
        buttonObjects[id] = btn
    end
	
	containerbar.width = sw-#topbar2btns*(bar2height+app.pad)
	containerbar.x = sw-containerbar.width/2
	topbar2.x = containerbar.width/2-topbar2.width/2 - app.pad
	
	special_back_fun = function(event)
	    project_path = P_DIR..project_data.project_name.."/"
	    ponosFile["писать путь"](project_path.."project.json", json.encode(project_data))
		scene.goto("project", { transition = "slideRight", params = {} })
	end
    
    switchCategory("category_main")
end
 
return M