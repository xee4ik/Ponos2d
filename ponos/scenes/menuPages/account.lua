local M = {}

function M.create(bounds)
	local group = display.newGroup()

	local scrollview = PonosUi.newScrollView({
		x = sw/2,
		y = bounds.y,
		width = sw,
		height = bounds.height,
		hideBackground = true,
		horizontalScrollDisabled = true
	})
	group:insert(scrollview)

	local projects_group = display.newGroup()
	scrollview:insert(projects_group)
	
	local user_stroke = display.newCircle(group, app.pad, app.topbarheight+app.pad, 54)
	user_stroke.anchorX = 0
	user_stroke.anchorY = 0
	user_stroke:setFillColor({
		type = "gradient",
		color1 = {0.8, 0.81, 0.84},
		color2 = {0.6, 0.6, 0.6},
		direction = "down"
	})
	
	local user = display.newCircle(group, app.pad+4, app.topbarheight+app.pad+4, 50)
	user.fill = {
	    type = "image",
	    filename = "res/user.png"
	}
	user.anchorX = 0
	user.anchorY = 0
	user:setFillColor(ponosSettings.user.color[1], ponosSettings.user.color[2], ponosSettings.user.color[3])
	
	local name = display.newText({
	    x = user_stroke.width + app.pad*2,
		y = user_stroke.y + user_stroke.height/2-app.fontsize1/1.8,
		width = sw - user_stroke.width - app.pad*4 - app.topbarheight,
		text = "unknow user",
		parent = group,
		fontSize = app.fontsize1,
		font = app.fontBold,
	})
	name.anchorX = 0
	name:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
	
	local userid = display.newText({
	    x = user_stroke.width + app.pad*2,
		y = user_stroke.y + user_stroke.height/2+app.fontsize1/1.8,
		width = sw - user_stroke.width - app.pad*4 - app.topbarheight,
		text = "@"..ponosSettings.user.id,
		parent = group,
		fontSize = app.fontsize1/1.2,
		font = app.font,
	})
	userid.anchorX = 0
	userid:setFillColor(app.color.textDescColor[1],app.color.textDescColor[2],app.color.textDescColor[3])
	userid:setFillColor(app.color.textDescColor[1],app.color.textDescColor[2],app.color.textDescColor[3])
	
	if ponosSettings.user.inSystem then
		local edit_name = PonosUi.newButton(function(event)
			
		end, {x = sw-app.pad, y = user_stroke.y + user_stroke.height/2, width = app.topbarheight, height = app.topbarheight, text = "", 	rounded = app.topbarheight/2.3, icon = {path = "res/ui/edit.png"}, alpha = 0.01 }, group)
		edit_name.anchorX = 1
		
	end
	
	local buttons = { {isNext = true, id = "login", icon = "res/ui/account.png", text = app.words[275], isLogin = true}, {isNext = true, icon = "res/ui/cog.png", text = app.words[276], id = "settings"} }
	
	local line = display.newRect(scrollview.width/2, user_stroke.height-2+app.pad*3, scrollview.width-app.pad*4, 4)
	line:setFillColor(app.unpack(app.color.lineColor))
	scrollview:insert(line)
	
	local tabHeight = 76
	
	for i = 1, #buttons do
	    local this = buttons[i]
		
		if this.isLogin then
		    if ponosSettings.user.isLogin then
			    this.text = "Я"
				this.reg = true
			else
			    this.reg = false
			end
		end
		
		local bg = display.newRoundedRect(sw/2, i*(tabHeight+app.pad)+line.y-tabHeight/2+app.pad, scrollview.width-app.pad*2, tabHeight, tabHeight/2)
		bg:setFillColor(app.color.btnBgColor[1],app.color.btnBgColor[2],app.color.btnBgColor[3])
		scrollview:insert(bg)
		
		local leftPad = 0
		local rightPad = 0
		if this.icon then
		    leftPad = tabHeight-app.pad
			local icon = display.newImageRect(this.icon, tabHeight-app.pad*2, tabHeight-app.pad*2)
			icon.y = bg.y
			icon.x = bg.x-bg.width/2+tabHeight/2
			icon:setFillColor(app.color.btnTextColor[1],app.color.btnTextColor[2],app.color.btnTextColor[3])
			scrollview:insert(icon)
		end
		if this.isNext then
		    rightPad = tabHeight+app.pad + rightPad
			local icon = display.newImageRect("res/ui/right.png", tabHeight/2, tabHeight/2)
			icon.y = bg.y
			icon.x = bg.x+bg.width/2-tabHeight/2
			icon:setFillColor(app.color.btnTextColor[1],app.color.btnTextColor[2],app.color.btnTextColor[3])
			scrollview:insert(icon)
		end 
		
		local text = display.newText({
		    x = bg.x - bg.width/2+leftPad+app.pad,
			y = bg.y,
			width = bg.width-app.pad*2-rightPad,
			text = this.text,
			fontSize = app.fontsize1,
			font = app.font
		})
		text.anchorX = 0
		text:setFillColor(app.color.btnTextColor[1],app.color.btnTextColor[2],app.color.btnTextColor[3])
		scrollview:insert(text)
		
		local rippleBtn = PonosUi.newButton(function(event) 
		    if event.phase == "ended" then
				if this.id == "settings" then
				    scene.goto("ponos_settings", {})
				end
			end
		end, {x = scrollview.width/2, y = bg.y, width = scrollview.width-app.pad*2, height = tabHeight, rounded = tabHeight/2, alpha = 0.01}, scrollview)
	end
	
	return group
end

return M