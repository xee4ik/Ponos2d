local M = {}

function M.create(group, params)
    local bg = display.newRect(group, sw/2, sh/2, sw, sh)
    bg:setFillColor(app.color.mainBackgroundColor[1],app.color.mainBackgroundColor[2],app.color.mainBackgroundColor[3])
    bg.alpha = 0
    transition.to(bg, {alpha = 1, time = 300})
	
	local panel = PonosUi.newBottomBar(function(index)
           if index == "ok" then
		    timer.cancelAll()
               scene.goto("startPages.end" , { transition = "slideLeft" } )
           end
       end,{
           {text = "понятно", icon = nil, index = "ok", style = "green"}
       }, group)
    
    local scrollview = PonosUi.newScrollView({
        x = sw/2,
        y = 0,
        width = sw,
        height = sh-panel.height,
        horizontalScrollDisabled = true,
        showScrollbars = false,
		verticalVel = 100
    })
    group:insert(scrollview)
	
	local script = json.decode('[{"index":"new_rounded_rect","params":[[["string","button"]],[["number","60"]],[["func","screen_width"],["function","/"],["number",2]],[["func","screen_height"],["function","/"],["number",2]],[["number","150"]],[["number","150"]]]},{"index":"new_text","params":[[["string","score"]],[["number",0]],[["func","pos_x"],["function","("],["string","button"],["function",")"]],[["func","pos_y"],["function","("],["string","button"],["function",")"],["function","-"],["number","150"]],[["function","nil"]],[["number","42"]]]},{"index":"add_touch_listener","params":[[["string","button"]],[["string","event"]]]},{"index":"if_condition","params":[[["func","get_var"],["function","("],["string","event"],["function",")"],["key","phase"],["function","=="],["string","began"]]]},{"index":"change_var","params":[[["string","clicks"]],[["number",1]]]},{"index":"set_text","params":[[["string","score"]],[["func","get_var"],["function","("],["string","clicks"],["function",")"]]]},{"index":"set_scale","params":[[["string","button"]],[["number",0],["function","."],["number",9]],[["number",0],["function","."],["number",9]]]},{"index":"set_fill_color","params":[[["string","button"]],[["number","200"]],[["number","200"]],[["number","200"]]]},{"index":"timer","params":[[["number",1]],[["number",0],["function","."],["number",2]]]},{"index":"set_scale","params":[[["string","button"]],[["number",1]],[["number",1]]]},{"index":"set_fill_color","params":[[["string","button"]],[["number","255"]],[["number","255"]],[["number","255"]]]},{"index":"end_timer","params":[]},{"index":"end_if","params":[]},{"index":"end_listener","params":[]}]')
	
	local function touchParameter(event)
	    
	end
	
	local currentY = app.topbarheight + app.pad
	
	local title = display.newText({
	    x = app.pad,
		y = currentY,
		width = sw-app.pad*2,
		fontSize = app.fontsize3,
		text = app.words[248],
		font = app.font
	})
	title.anchorX = 0
	title.anchorY = 0
	title:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
	scrollview:insert(title)
	
	currentY = currentY+title.height+app.pad*2
	
	
	local title2 = display.newText({
	    x = app.pad,
		y = currentY,
		width = sw-app.pad*2,
		fontSize = app.fontsize1,
		text = app.words[249],
		font = app.font
	})
	title2.anchorX = 0
	title2.anchorY = 0
	title2:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
	title2.alpha = 0.95
	scrollview:insert(title2)
	
	local i = 1
	
	currentY = currentY+title2.height+30+app.pad
	
	local blocksObjects = {}
    
    timer.performWithDelay(100, function()
	    
		local blockData = all_blocks[script[i].index] or {type = "block"}
        local blockObj = create_block(script[i])
		
		blockObj.y = currentY+app.pad
        
        blockObj.id = i
        blockObj.blockData = blockData
        blocksObjects[i] = blockObj
        scrollview:insert(blockObj)
        
        --blockObj:addEventListener("touch", touchBlock)
        for j = 1, #blockObj.cells do
            blockObj.cells[j][2]:addEventListener("touch", touchParameter)
        end
		
		local locy = currentY
		
		blockObj.alpha = 0.3
		
		transition.to(blockObj, {alpha = 1, y = locy, transition = easing.outQuad, time = 300})
		
		i = i+1
		
		currentY = currentY + blockObj.height
		
	end, #script)
	
end

return M