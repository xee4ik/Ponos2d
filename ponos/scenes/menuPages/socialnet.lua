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
		showScrollbars = false,
		verticalVel = bounds.height/2
	})
	group:insert(scrollview)
	
	local function onInputQuestion(data, parent)
	    local header = data.header or "Вопрос"
		local description = data.description
		
		local qGroup = display.newGroup()
		if parent then
		parent:insert(qGroup)
		end
		
		local text1 = display.newText({
		    x = 0,
			y = 0,
			width = sw-app.pad*3.5,
			fontSize = app.fontsize1,
			text = header,
			font = app.fontBold,
		})
		local text2 = display.newText({
		    x = 0,
			y = 0,
			width = sw-app.pad*4,
			fontSize = app.fontsize1/1.1,
			text = description,
			font = app.font
		})
		text1.anchorY = 0
		text2.anchorY = 0
		text1.y = app.pad
		text2.y = text1.height + app.pad *1.25
		local bg = PonosUi.newButton(function(event)
			if event.phase == "moved" then
			    scrollview:takeFocus(event)
			end
		end, {x = 0, y = 0, width = sw-app.pad, height = text2.height+text1.height+app.pad*2.5+40, rounded = 20}, qGroup)
		bg.anchorY = 0
		qGroup:insert(text1)
		qGroup:insert(text2)
		local upBtn = PonosUi.newButton(nil, {x = -sw/2+app.pad+40, y = text2.height+text1.height+app.pad*2+20, width = 80, height = 40, rounded = 20, alpha = 0.5, colorBg = {0.3,0.3,0.3}}, qGroup)
		local up = display.newImageRect(qGroup,"res/ui/right.png", 30,30)
		up.rotation = -90
		up.x = upBtn.x -35/2
		up.y = upBtn.y
		local upText = display.newText({
		    parent = qGroup,
			x = upBtn.x +15 ,
			y = up.y ,
			text = data.rate,
			fontSize = app.fontsize1/1.25,
			font = app.font
		})
		local dnBtn = PonosUi.newButton(nil, {x = -sw/2+app.pad*1.5+40+60, y = text2.height+text1.height+app.pad*2+20, width = 40, height = 40, rounded = 20, alpha = 0.3, colorBg = {0.3,0.3,0.3}}, qGroup)
		local dn = display.newImageRect(qGroup,"res/ui/right.png", 30,30)
		dn.rotation = 90
		dn.x = dnBtn.x
		dn.y = dnBtn.y
		return qGroup
	end

	local projects_group = display.newGroup()
	scrollview:insert(projects_group)
	
	local loading = PonosUi.newLoader(group, sw/2,sh/2)
	
	local function offlinePage()
		local messeges = {
			{header = app.words[277], description = app.words[278], rate = 0} 
		}
		
		local currenty = app.pad
		for i = 1, #messeges do
			local object = onInputQuestion(messeges[i], scrollview)
			object.y = currenty
			object.x = sw/2
			currenty = currenty+object.height + app.pad
		end
	end
	
	timer.performWithDelay(500, function() loading:removeSelf()
	--new_dialog({header = "Q&A в разработке!", description = "Следите за обновлениями, чтобы не пропустить"})
	offlinePage()
	end, 1)
	
	return group
end

return M