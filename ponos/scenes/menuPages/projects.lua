local M = {}

function M.create(bounds)
	local group = display.newGroup()
	
	local scrollview = PonosUi.newScrollView({
		x = sw/2,
		y = bounds.y,
		width = sw,
		height = bounds.height,
		hideBackground = true,
		horizontalScrollDisabled = true,
		verticalVel = app.content/4
	})
	group:insert(scrollview)

	local projects_group = display.newGroup()
	scrollview:insert(projects_group)

	local function updatelist()
		for i = projects_group.numChildren, 1, -1 do
			projects_group[i]:removeSelf()
		end

		local projectslist = ponosFile["получить список проектов"]()


		local minCardWidth = 150
		if sw < 400 then minCardWidth = sw * 0.4 end
		local cols = math.max(1, math.floor((sw - app.pad) / (minCardWidth + app.pad)))
		local cardWidth = (sw - app.pad * (cols + 1)) / cols
		local cardHeight = cardWidth * 1.3
		local cornerRadius = 30

		for i = 1, #projectslist + 1 do
			local col = (i - 1) % cols
			local row = math.floor((i - 1) / cols)
			local cardX = app.pad + col * (cardWidth + app.pad) + cardWidth / 2
			local cardY = app.pad + row * (cardHeight + app.pad) + cardHeight / 2

			local cardGroup = display.newGroup()
			projects_group:insert(cardGroup)
			cardGroup.x = cardX
			cardGroup.y = cardY
			
		if i == #projectslist + 1 then
		
		local cardBg = display.newRoundedRect(cardGroup, 0, 0, cardWidth, cardHeight, cornerRadius)
		cardBg:setFillColor(unpack(app.color.projectCardBgcolor), 0.5)
		cardBg.strokeWidth = 2
		cardBg:setStrokeColor(unpack(app.color.projectCardOutlineColor))
			
		local fabSize = app.fabsize*2
		local new_project_btn = PonosUi.newButton(function(event)
			if event.phase == "ended" then
				local dialog
				local inputBox
				local opt = {orientation = 'portrait'}
				dialog = new_dialog({
					header = app.words[1],
					description = app.words[2],
					buttons = { {text = app.words[493], callback = function() ponosFile['создать проект'](inputBox.text, opt); updatelist(); display.remove(inputBox) end} }
				})
				    local pad = app.pad*1.5
				    local input = display.newGroup()
	                dialog:insert(input)
	                local inputHeight = 75
	                local inputRect = display.newRoundedRect(input, 0, 0, dialog.contentWidth-pad*2, inputHeight, 8)
                    inputRect.alpha = 0.4
	                inputRect:setFillColor(0,0,0)
	                local inputLine = display.newRect(input, 0, inputRect.height/2-pad/2, inputRect.width- pad,4)
	                inputBox = native.newTextField(0, 0, inputRect.width- pad, inputRect.height-pad)
	                inputBox.isEditable = true
                    inputBox.hasBackground = false
	                inputBox.size = 25
	                if utils.isSim or utils.isWin then
                        inputBox:setTextColor(0, 0, 0)
                        inputBox.size = 25
                    else
                        inputBox:setTextColor(1, 1, 1)
                    end
					inputBox.text = app.words[3]
	                input:insert(inputBox)
					input.y = -input.height+pad/2
					
					local orientation = PonosUi.newRadioGroup({x = -dialog.contentWidth/2+pad, y = 0, options = { {'portrait', app.words[291], "res/ui/vertical.png"}, {'landscape', app.words[292], "res/ui/horizontal.png"} }, parent = dialog, value = 'portrait', callback = function(key) 
					    opt.orientation = key
					end })
					
					dialog:recalc()
			elseif event.phase == "moved" then 
			    local delta = math.abs(event.x - event.xStart) + math.abs(event.y - event.yStart)
                if (delta > app.touchDelta) then 
                    scrollview:takeFocus(event)
                end
			end
		end, {
			x = 0,
			y = 0,
			width = fabSize,
			height = fabSize,
			icon = {path = "res/ui/plus.png", size = (fabSize/2)*1.2},
			rounded = fabSize/3,
			colorBg = app.color.btnFabBgColor,
			colorTxt = app.color.btnFabIconColor,
		}, cardGroup)
		
		else
			local data = projectslist[i][1]
			local metadata = projectslist[i][2]
			
			local cardBg = display.newRoundedRect(cardGroup, 0, 0, cardWidth, cardHeight, cornerRadius)
			cardBg:setFillColor(unpack(app.color.projectCardBgcolor))
			cardBg.strokeWidth = 2
			cardBg:setStrokeColor(unpack(app.color.projectCardOutlineColor))

			local touchTimer = nil
			local isLongPress = false

			local cardBtn = PonosUi.newButton(function(e)
				if e.phase == "began" then
				    scrollview:stop()
					isLongPress = false
					touchTimer = timer.performWithDelay(250, function()
						isLongPress = true
						display.getCurrentStage():setFocus(nil)
						cardBg.strokeWidth = 4
						cardBg:setStrokeColor(0.3,0.3,0.3)
					end)
				elseif e.phase == "moved" then
					local delta = math.abs(e.x - e.xStart) + math.abs(e.y - e.yStart)
					if (delta > app.touchDelta) then
						if touchTimer then 
							timer.cancel(touchTimer) 
							touchTimer = nil 
						end
						display.getCurrentStage():setFocus(e.target, nil)
						e.target.isFocus = false
						scrollview:takeFocus(e)
						cardBg.strokeWidth = 2
		                cardBg:setStrokeColor(unpack(app.color.projectCardOutlineColor))
					end
				elseif e.phase == "ended" or e.phase == "cancelled" then
					if touchTimer then 
						timer.cancel(touchTimer) 
						touchTimer = nil 
					end
					
					if not isLongPress then
						scene.goto("project", {params={ project_path = metadata.path, project_data = data }})
					else
						cardBg.strokeWidth = 2
		                cardBg:setStrokeColor(unpack(app.color.projectCardOutlineColor))
						dropdown(nil, {{'', 'delete', 'res/ui/trash.png'}, {'', 'rename', 'res/ui/edit.png'}}, function(b) 
						    if b == 1 then 
							    local dialog = new_dialog({header = app.words[299], description = app.words[24], buttons = { {text = app.words[300]}, {text = app.words[301], callback = function() ponosFile['удалить папку'](P_DIR..data.project_name); updatelist(); new_warning(string.format(app.words[302], "'"..data.project_name.."'")) end} } })
							end
							if b == 2 then 
							    local dialog = new_input_alert({header = app.words[29]}, function(text) 
									ponosFile["переименовать папку"](P_DIR..data.project_name, text)
									data.project_name = text
								    ponosFile['писать путь'](P_DIR..data.project_name..'/project.json', json.encode(data) )
									updatelist()
								end, true)
								dialog.text(data.project_name)
							end
						end, {x = e.x+80/2, y = e.y, width = 80, height = 80})
					end
				end
			end, {
				x = 0,
				y = 0,
				width = cardWidth,
				height = cardHeight,
				alpha = 0.01,
				rounded = cornerRadius,
			}, cardGroup)

			local iconSize = cardWidth -app.pad*3
			local icon = display.newRoundedRect(cardGroup, 0, -cardHeight/2 + app.pad*1.5 + iconSize/2, iconSize, iconSize, cornerRadius)
			icon.fill = {
				type = "image",
				baseDir = system.DocumentsDirectory,
				filename = metadata.path..'/icon.png'
			}
			print(metadata.path..'/icon.png')
			icon.strokeWidth = 2
			icon:setStrokeColor(0, 0, 0, 0.6)
			
			local nameContainer = display.newContainer(cardWidth, cardHeight-iconSize)
			nameContainer.y = icon.y + iconSize/2 + app.pad/2
			
			cardGroup:insert(nameContainer)
			
			local name = display.newText({
				parent = nameContainer,
				x = 0,
				y = 0,
				text = data.project_name,
				width = cardWidth - app.pad * 2,
				align = "center",
				fontSize = app.fontsize1,
				font = app.font
			})
			name.anchorY = 0
			name:setFillColor(app.color.projectCardTextColor[1],app.color.projectCardTextColor[2],app.color.projectCardTextColor[3])

			if not metadata.iscorrect then
				local invalid_project = PonosUi.newButton(function(e)
					if e.phase == "ended" then
						local dialog = new_dialog({
							header = app.words[4],
							description = app.words[5]
						})
					end
				end, {
					x = cardBg.x - cardBg.width/2+(cardWidth/5)/2,
					y = cardBg.y - cardBg.width/2,
					width = cardWidth/5,
					height = cardWidth/5,
					icon = {path = "res/ui/warning.png", size = cardWidth/5},
					alpha = 1,
					rounded = cardWidth/10,
					colorTxt = {1, 0.2, 0}
				}, cardGroup)
			end
		end
		
		end

		local bottomPadding = display.newRect(projects_group, sw/2, (math.ceil(#projectslist / cols) * (cardHeight + app.pad)) + app.fabsize*2.5, sw, 10)
		bottomPadding.isVisible = false
		
		scrollview:upd(true)
	end

	updatelist()

	return group
end

return M