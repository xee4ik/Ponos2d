local M = {}

function M.create(group, params)
    local bg = display.newRect(group, sw/2, sh/2, sw, sh)
    bg:setFillColor(app.color.mainBackgroundColor[1],app.color.mainBackgroundColor[2],app.color.mainBackgroundColor[3])
    
    local contentGroup 

    local function buildUI()
        if contentGroup then
            contentGroup:removeSelf()
            contentGroup = nil
        end
        
        contentGroup = display.newGroup()
        group:insert(contentGroup)
        
        app.words = app.updateWords()
        
        local topbar = PonosUi.newTopBar(contentGroup, app.words[226], nil, function(e) end) 
        
        local scrollviewa = PonosUi.newScrollView({
            x = sw/2,
            y = app.topbarheight,
            width = sw,
            height = sh-app.topbarheight,
            horizontalScrollDisabled = true,
			showScrollBars = false,
			verticalVel = app.pad*2,
        })
        contentGroup:insert(scrollviewa)
        
        local currenty = app.pad
        local elheight = 62
        
        local settings = {
            {type = "choose", key = "language", elements = { 
                {"Русский", "Русский", "res/flags/ru.png", true},
                {"English", "English", "res/flags/gb.png", true},
                {"中文", "Chinese", "res/flags/cn.png", true}
            }, text = app.words[229] },
            {type = "checkbox", key = "engBlocks", text = app.words[230] },
            {type = "checkbox", key = "engFormulas", text = app.words[231] },
            {type = "enter" },
            {type = "checkbox", key = "errorAlert", text = app.words[232] },
            {type = "checkbox", key = "sounds", text = app.words[279] },
            {type = "checkbox", key = "useSystemFont", text = app.words[280] },
			{type = "enter" },
			{type = "checkbox", key = "blocksEditorSaveScrollPosition", text = app.words[281] },
			{type = "checkbox", key = "openScriptInSaveScrollPosition", text = app.words[282] },
        }
        
        for i = 1, #settings do
            local this = settings[i]
            local type = this.type or "text"
            local text = this.text or "hello world!"
            local key = this.key or "testkey"
            
			local bg = display.newRoundedRect(0,0,sw-app.pad*2, app.pad*2, 30)
			bg:setFillColor(app.color.settingsCardBgColor[1], app.color.settingsCardBgColor[2],app.color.settingsCardBgColor[3])
			
            local el = display.newGroup()
            
            if type == "choose" then
                local tap
                
                local displayLangName = ponosSettings[key]
                for j = 1, #this.elements do
                    if this.elements[j][2] == ponosSettings[key] then
                        displayLangName = this.elements[j][1]
                        break
                    end
                end
                
                local btn = PonosUi.newButton(function(e) tap(e) end, {x = sw-app.pad*2, 
                    y = 0, 
                    width = math.min(app.content / 2.2, 340), 
                    height = elheight, 
                    text = displayLangName,
                    text_align = "left",
                    icon = {
                        path = "res/ui/triangle.png", 
                        position = "right",
                        size = elheight/3
                    }}, el)
                btn.anchorY = 0.5
                btn.anchorX = 1
                
                tap = function(event)
                    if event.phase == "ended" then
                        local choose = dropdown(nil, this.elements, function(b)
						    if b == false then return false end
                            ponosSettings[key] = this.elements[b][2]
                            if app.ponosSttSave then app.ponosSttSave() end
                            
                            app.words = app.updateWords()
                            if updateBlocksWords then updateBlocksWords() end
                            if updateFormulasWords then updateFormulasWords() end
                            if updateBlocksCategoryWords then updateBlocksCategoryWords() end
                            
                            buildUI()
                            
                        end, {x = sw-app.pad*2, y = event.y} )
                    end
                end
                
                local head = display.newText({
                    x = app.pad*2,
                    y = btn.y,
                    width = sw-btn.width-app.pad*3,
                    text = text,
                    fontSize = app.fontsize1,
					font = app.font
                })
                head.anchorX = 0
                el:insert(head)
				head:setFillColor(app.unpack(app.color.standartTextColor))
                
            elseif type == "checkbox" then
                local checkbox = PonosUi.newCheckBox(function(b) 
                    ponosSettings[key] = b.active
                    app.ponosSttSave()
					if key == "useSystemFont" then
					    app.updateTextSettings()
						buildUI()
					end
                end, {x = sw, y = 0, active = ponosSettings[key]})
                checkbox.y = 0
                checkbox.x = sw-checkbox.width/2-app.pad*2
                
                local head = display.newText({
                    x = app.pad*2,
                    y = checkbox.y,
                    width = sw-checkbox.width-app.pad*4,
                    text = text,
                    fontSize = app.fontsize1,
					font = app.font
                })
                head.anchorX = 0
				el:insert(checkbox)
                el:insert(head)
				head:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
            end
			
			bg.height = el.height+app.pad*2
			bg.x = sw/2
			bg.y = currenty
			bg.anchorY = 0
            
            el.y = currenty+ (bg.height-el.height)/2+el.height/2
            currenty = currenty+bg.height+app.pad
            if type == "enter" then
                currenty = currenty+20
				display.remove(bg)
				display.remove(el)
			else
			    scrollviewa:insert(bg)
				scrollviewa:insert(el)
            end
        end
        
        local backBtn = PonosUi.newButton(function(event)
            if event.phase == "moved" then
                local delta = math.abs(event.x - event.xStart) + math.abs(event.y - event.yStart)
                if (delta > app.touchDelta) then 
                    display.getCurrentStage():setFocus(event.target, nil)
                    event.target.isFocus = false
                    scrollviewa:takeFocus(event)
                    if paramData and paramData[1] == "cell" then paramData[3].yScale = 1 end
                end
                return true
            end
            if event.phase == "ended" then
                app.words = app.updateWords()
                if updateBlocksWords then updateBlocksWords() end
                if updateFormulasWords then updateFormulasWords() end
                if updateBlocksCategoryWords then updateBlocksCategoryWords() end
                
                scene.goto("menu", {params = {page = "account"}, transition = "zoomOut"})
            end
        end, {x = sw/2, y = currenty + 40+elheight, height = 80, width = 80, text = "", rounded = 30, icon = {path = "res/ui/back.png", position = "center"}}, scrollviewa)
		
		local solar2d = display.newImage("res/splash.png")
		scrollviewa:insert(solar2d)
		solar2d.x = sw/2
		local scale = math.min(sw-app.pad*2, 480) / solar2d.width
        solar2d.width = solar2d.width * scale
        solar2d.height = solar2d.height * scale
		solar2d.y = math.max(backBtn.y+solar2d.height/2+app.pad*2, scrollviewa.height-solar2d.height/2-app.pad-getBottomNavHeight())
		
        
    end
	
	special_back_fun = function(event)
		scene.goto("menu", { transition = "zoomOut", params = {page = "account"} })
	end
    
    buildUI()
end

return M