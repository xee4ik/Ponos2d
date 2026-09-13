local M = {}

-- Сцена меню проекта :)

function M.create(group, params)
    project_path = params.project_path or project_path
    project_data = params.project_data or project_data
    
    local bg = display.newRect(group, sw/2, sh/2, sw, sh)
    bg:setFillColor(app.color.mainBackgroundColor[1], app.color.mainBackgroundColor[2], app.color.mainBackgroundColor[3])
    
    local topbar = PonosUi.newTopBar(group, "Ponos 2d", nil, function(e) end)
    
    local bar2height = topbar.barheight / 1.18
    local topbar2bg = display.newRect(group, sw/2, topbar.barheight + bar2height/2, sw, bar2height) 
    topbar2bg:setFillColor(app.color.topBar2BgColor[1], app.color.topBar2BgColor[2], app.color.topBar2BgColor[3])
    
    local separator = display.newRect(group, sw/2, topbar.barheight + bar2height, sw, 2)
    separator:setFillColor(0, 0, 0, 0.15) 
    
    local backBtnWidth = bar2height + app.pad
    local backBtn = PonosUi.newButton(function(e)
        if e.phase == "ended" then
            scene.goto("menu", { transition = "zoomOut", params={page = "projects"} })
        end
        return true
    end, {
        x = backBtnWidth/2,
        y = topbar.barheight + bar2height/2,
        width = backBtnWidth,
        height = bar2height,
        icon = {path = "res/ui/back.png", size = bar2height - app.pad*1.5},
        line_width = 0,
        rounded = 0, 
        colorBg = app.color.topBar2BgColor, 
        colorTxt = app.color.topBar2TextColor
    }, group)
    
    local topbar2 = display.newText({
        parent = group,
        x = backBtn.x + backBtn.width/2 + app.pad/2,
        y = topbar.barheight + bar2height/2,
        width = sw - backBtnWidth - app.pad*2,
        text = project_data.project_name,
        fontSize = app.fontsize1,
        align = "left",
        font = app.font
    })
    topbar2.anchorX = 0
    topbar2:setFillColor(app.color.topBar2TextColor[1], app.color.topBar2TextColor[2], app.color.topBar2TextColor[3])
    
    local scrollview = PonosUi.newScrollView({
        x = sw/2,
        y = topbar.barheight + bar2height + separator.height,
        width = sw,
        height = sh - topbar.barheight - bar2height - separator.height,
        hideBackground = true,
        horizontalScrollDisabled = true,
    })
    group:insert(scrollview)
    
    local buttons = {
        {id = "levels",  text = app.words[6], icon = nil}, 
        {id = "scripts", text = app.words[7], icon = "res/ui/blocks.png"},
        {id = "settings",text = app.words[8], icon = "res/ui/cog.png"},
        {id = "files",   text = app.words[9], icon = nil},
        {id = "play",    text = app.words[10], icon = "res/ui/play.png"}
    }
    
    special_back_fun = function(event)
        scene.goto("menu", { transition = "zoomOut", params = {} })
    end
    
    local cols = 2
    local padding = app.pad
    local btnWidth = (sw - padding * (cols + 1)) / cols
    local btnHeight = math.min(85, (sh - topbar.barheight - bar2height) / 4)
    
    for i = 1, #buttons do
        local id = buttons[i].id
        
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        
        local xPos = padding + col * (btnWidth + padding) + btnWidth/2
        local yPos = padding + row * (btnHeight + padding) + btnHeight/2
        
        local btnParams = { 
            x = xPos, 
            y = yPos, 
            width = btnWidth, 
            height = btnHeight, 
            text = buttons[i].text,
            fontSize = app.fontsize1,
            rounded = 30,
        }
        
        if buttons[i].icon then
            btnParams.icon = {path = buttons[i].icon, position = "left", size = btnHeight/2.2 }
        end
        
        local btnBg = PonosUi.newButton(function(event)
            if event.phase == "moved" then
                local delta = math.abs(event.x - event.xStart) + math.abs(event.y - event.yStart)
                if (delta > app.touchDelta) then 
                    display.getCurrentStage():setFocus(event.target, nil)
                    event.target.isFocus = false
                    scrollview:takeFocus(event)
                end
            elseif event.phase == "ended" then
                if id == "levels" then
                    new_dialog({header = app.words[12], description = app.words[11]})
                elseif id == "settings" then
                    scene.goto("project_settings", {transition = "slideLeft"})
                elseif id == "scripts" then
                    scene.goto("scripts", {transition = "slideLeft"})
                elseif id == "play" then
                    scene.newScene("simulator", {transition = "slideLeft", params = {project_data = project_data}})
                elseif id == "files" then
                    scene.goto("resources", {transition = "slideLeft"})
                end
            end
            return true
        end, btnParams, scrollview)
        
        if id == "levels" then
            btnBg.alpha = 0.55
            
            local lockSize = btnHeight / 3
            local lock = display.newImageRect("res/lock.png", lockSize, lockSize)
            if lock then
                lock.x = xPos + btnWidth/2 - lockSize/2 - 6
                lock.y = yPos - btnHeight/2 + lockSize/2 + 6
                scrollview:insert(lock)
            end
        end
    end
end

return M