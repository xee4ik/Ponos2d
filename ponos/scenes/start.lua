local M = {}

function M.create(group, params)
    local bg = display.newRect(group, sw/2, sh/2, sw, sh)
    bg:setFillColor(app.color.mainBackgroundColor[1],app.color.mainBackgroundColor[2],app.color.mainBackgroundColor[3])
    local langToImg = {
	    ["Русский"] = "ru.png",
		["English"] = "gb.png",
		["Chinese"] = "cn.png"
	}
	
	local newGroup = display.newGroup()
	group:insert(newGroup)
	
	local updateUi
	
	function updateUi()
	    if newGroup then
            newGroup:removeSelf()
            newGroup = nil
        end
        
        newGroup = display.newGroup()
        group:insert(newGroup)
		
	    local title = display.newText({
		    x = app.pad,
			y = 0,
			width = sw-app.pad*2,
			fontSize = app.fontsize3,
		    text = app.words[242],
			parent = newGroup,
			font = app.font
		})
		title.y = app.pad + app.topbarheight
		title.anchorY = 0
		title.anchorX = 0
		title:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
		
		local chooseLangPls = display.newText({
	        x = app.pad,
	    	y = title.y + title.height + app.pad*2,
	    	width = sw-app.pad*2,
	    	fontSize = app.fontsize1,
	    	text = app.words[243],
	        parent = newGroup,
			font = app.font
	    })
		chooseLangPls.anchorY = 0
		chooseLangPls.anchorX = 0
		chooseLangPls:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
		chooseLangPls.alpha = 0.95
		
		local curY = chooseLangPls.y+chooseLangPls.height+app.pad
		
		local flag = display.newImage( "res/flags/"..langToImg[ ponosSettings["language"] ] )
		flag.x = sw-flag.width/2-app.pad
		flag.y = curY + 30
		newGroup:insert(flag)
		
		local tap
		
		local els = { 
            {"Русский", "Русский", "res/flags/ru.png"},
            {"English", "English", "res/flags/gb.png"},
            {"中文", "Chinese", "res/flags/cn.png"}
        }
        
        local displayLangName = ponosSettings["language"]
		for j = 1, #els do
            if els[j][2] == ponosSettings["language"] then
                displayLangName = els[j][1]
                break
            end
        end
        
        local btn = PonosUi.newButton(function(e) tap(e) end, {x = app.pad, 
            y = curY, 
            width = sw - flag.width - app.pad*4, 
            height = 70, 
            text = displayLangName,
            text_align = "left",
            icon = {
                path = "res/ui/triangle.png", 
                position = "right",
                size = 60/3
            }}, newGroup)
        btn.anchorY = 0
        btn.anchorX = 0
        
		
        tap = function(event)
            if event.phase == "ended" then
                local choose 
				choose = dropdown(nil, els, function(b)
				    if b == false then return false end
                    ponosSettings["language"] = els[b][2]
                    app.ponosSttSave()
                    
                    app.words = app.updateWords()
                    if updateBlocksWords then updateBlocksWords() end
                    if updateFormulasWords then updateFormulasWords() end
                    if updateBlocksCategoryWords then updateBlocksCategoryWords() end
                    
                    updateUi()
                    
                end, {x = btn.x+btn.width, y = btn.y+btn.height/2, width = btn.width} )
            end
        end
		
		local panel = PonosUi.newBottomBar(function(index)
            if index == "next" then
                scene.goto("startPages.funcs" , { transition = "slideLeft" } )
			elseif index == "cancel" then
			    local dialog
				dialog = new_dialog({header = app.words[244], description = app.words[245], buttons = {
				{text = app.words[246], callback = function() scene.goto("menu" , { transition = "slideRight" } ) end},{text = app.words[247]}
				}})
            end
        end,{
		    {text = "", icon = "res/ui/cancel.png", index = "cancel", style = "nono"},
            {text = "", icon = "res/ui/continue.png", index = "next", style = "green"}
        }, newGroup)
		
	end
	
	special_back_fun = function(event)
        transition.to(group, {x = -8, time = 167, alpha = 1, xScale = 0.98, transition = easing.outQuad, onComplete = function()
		transition.to(group, {x = 0, time = 254, alpha = 1, xScale = 1, transition = easing.outBack})
		end})
	end
	
	updateUi()
	
end

return M