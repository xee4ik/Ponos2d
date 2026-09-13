local M = {}
local lfs = require("lfs")

function M.create(group, params)
    local bg = display.newRect(group, sw / 2, sh / 2, sw, sh)
    bg:setFillColor(app.color.mainBackgroundColor[1],app.color.mainBackgroundColor[2],app.color.mainBackgroundColor[3])
    
    local topbar = PonosUi.newTopBar(group, project_data.project_name, nil, function(e) end)
    local resourcesDir = {"resources"}
    local back_fun = function() end
    local updatelist
    
    local topbar2 = PonosUi.newTopBar2(group, "", {
        {id = "back", icon = "res/ui/back.png", callback = function() back_fun() end}
    })
    local bar2height = topbar2.barheight
    
    local function split() return project_path .. "/" .. table.concat(resourcesDir, "/") end
    local function split_res_path(forText)
        if forText then return "/" .. table.concat(resourcesDir, " / ") end
        return "/" .. table.concat(resourcesDir, "/")
    end
    
    local filesDir = split()
    local libOpen = false
    local libGroup = nil
    
local function open_library()
    if libOpen then
        display.remove(libGroup)
        libGroup = nil
        libOpen = false
    else
        libGroup = display.newGroup()
        group:insert(libGroup)
        
        local basePath = "AssetsLibrary/"
        local files = app.words[283]
        
        local cols = math.floor(sw / 150)
        if cols < 1 then cols = 1 end
        
        local cellW = sw / cols
        local cellH = cellW + app.fontsize1
        local itemSize = 100
        
        local bg = display.newRect(libGroup, sw/2, sh/2, sw, sh)
        bg:setFillColor(app.color.mainBackgroundColor[1], app.color.mainBackgroundColor[2], app.color.mainBackgroundColor[3])
        bg:addEventListener("touch", function(event) return true end)
        
        local scroll = PonosUi.newScrollView({
            x = sw/2,
            y = 0,
            height = sh,
            width = sw,
			verticalVel = 100,
        })
        libGroup:insert(scroll)
        
        local currentY = app.pad+app.topbarheight
		
		local topbar = display.newText({
            x = app.pad, 
            y = app.topbarheight/2, 
            width = sw - app.pad * 2, 
            text = app.words[284], 
            fontSize = app.fontsize3,
			font = app.font
        })
		topbar.anchorX = 0
		topbar:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
		scroll:insert(topbar)
		
        for j = 1, #files do
            local title = display.newText({
                x = app.pad, 
                y = currentY, 
                width = sw - app.pad * 2, 
                text = files[j][1], 
                fontSize = app.fontsize1,
				font = app.font
            })
			scroll:insert(title)
            title.anchorX = 0
            title.anchorY = 0
			title:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
            currentY = currentY + title.height + app.pad
            local content = display.newGroup()
            scroll:insert(content)
            content.x = 0
            content.y = currentY
            
            local cat = files[j][2]
            local maxRows = 0
            
            for i = 1, #cat do
                local item = cat[i]
                local col = (i - 1) % cols
                local row = math.floor((i - 1) / cols)
                
                local cx = (col * cellW) + (cellW / 2)
                local cy = (row * cellH) + (cellH / 2)
                
                local g = display.newGroup()
                content:insert(g)
                g.x = cx
                g.y = cy
local btnW = cellW - app.pad
local btnH = cellH - app.pad

local btnOutline = display.newRoundedRect(g, 0, 0, btnW + 4, btnH + 4, 30 + 2)
if app.color.listOutlineColor then
    btnOutline:setFillColor(unpack(app.color.listOutlineColor))
end

local hit = PonosUi.newButton(function(event) 
    if event.phase == "moved" then
        scroll:takeFocus(event)
    elseif event.phase == "ended" then
        print(filesDir..item[2])
        local test = display.newGroup()
        local img = display.newImage(test, basePath .. item[2])
        display.save(test, {
            filename = filesDir.."/"..item[1]..".png",
            baseDir = system.DocumentsDirectory,
            captureOffscreenArea = true,
            backgroundColor = {0, 0, 0, 0}
        })
        display.remove(test)
        open_library()
        updatelist()
	elseif event.phase == 'began' then
	    scroll:stop()
    end
end, {
    x = 0,
    y = 0,
    width = btnW,
    height = btnH,
    alpha = 1,
    style = "list",
    line_width = 0,
    rounded = 30,
    text = ""
}, g)
                local img = display.newImage(g, basePath .. item[2])
                if img then
                    local scale = itemSize / math.max(img.width, img.height)
                    img.width = img.width * scale
                    img.height = img.height * scale
                    img.y = -hit.height/2+img.height/2+app.pad
                end
                local label = display.newText({
                    parent = g,
                    text = item[1],
                    x = 0,
                    y = img and (img.y + img.height/2 + 4) or 0,
                    fontSize = app.fontsize1,
					width = hit.width,
					align = "center",
					font = native.systemFont
                })
                label.anchorY = 0
                label:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
                
                if row > maxRows then maxRows = row end
            end
            local contentHeight = (maxRows + 1) * cellH
            currentY = currentY + contentHeight + app.pad*3
        end
		
        scroll:upd()
        
        libOpen = true
    end
end
    
    local patht = display.newText({
        parent = group, x = 0, y = app.topbarheight + bar2height,
        fontSize = app.fontsize2, text = split_res_path(true), font = app.font
    })
    patht.anchorX, patht.anchorY = 0, 0
	patht:setFillColor(app.color.standartTextColor[1],app.color.standartTextColor[2],app.color.standartTextColor[3])
    local panelH = 0
    
    local scrollview = PonosUi.newScrollView({
        x = sw / 2, y = app.topbarheight + bar2height + patht.height,
        width = sw, height = sh - app.topbarheight - bar2height - panelH - patht.height,
        horizontalScrollDisabled = true, verticalVel = 100
    })
    group:insert(scrollview)
	
	local panel = PonosUi.newFabs(function(index)
        if index == "new_file" then
            local buttons = {
                {"import_file", app.words[286]},
                {"local_library", app.words[287]},
                {"text_file", app.words[19]},
                {"folder", app.words[20]}
            }
			
            local dialog = new_variants({header = app.words[285]},buttons,function(id)
                if id == "import_file" then
				    new_variants({header = app.words[286], description = app.words[489]}, {{'image/*', app.words[490]}, {'audio/*', app.words[491]}, {'text/x-lua', app.words[492]}, {'*/*', '...'}}, function(fileimport) 
					    ponosFile['импортировать формат'](filesDir, fileimport, function() updatelist() end)
					end)
                elseif id == "text_file" then
                    ponosFile["писать путь"](filesDir .. "/file" .. math.random(10000, 99999) .. ".txt", "0")
                    updatelist()
                elseif id == "folder" then
                    new_input_alert({header = app.words[21]}, function(e)
                        if e and e ~= "" then
                            ponosFile["создать путь"](filesDir .. "/" .. e)
                            updatelist()
                        end
                    end, true)
                elseif id == "local_library" then
                    open_library()
                end
            end)
        end
    end, {{text = "", icon = "res/ui/plus.png", index = "new_file"}}, group)
    
    local projects_group = display.newGroup()
    scrollview:insert(projects_group)
    
    local formats = {
        ["png"] = "image", ["jpg"] = "image", ["jpeg"] = "image",
        ["mp3"] = "audio_file", ["wav"] = "audio_file", ["ogg"] = "audio_file",
        ["lua"] = "lua", ["html"] = "web", ["txt"] = "file", ["json"] = "file"
    }
    
    updatelist = function()
        for i = projects_group.numChildren, 1, -1 do projects_group[i]:removeSelf() end
        filesDir = split()
        local list_files = ponosFile["получить файлы в проекте"](filesDir) or {}
        
        table.sort(list_files, function(a, b) return tostring(a):lower() < tostring(b):lower() end)
        patht.text = split_res_path(true)
        transition.cancel(patht)
        
        if patht.width > sw / 1.3 then
            transition.to(patht, {x = sw / 1.3 - patht.width, time = 150})
        else
            transition.to(patht, {x = 0, time = 150})
        end
        
        local tabheight = math.max(64, math.min(106, (sh - topbar.barheight) / math.max(#list_files, 1)))
        local thumbSize = tabheight / 2
        
        local function touchEl(event)
            local t = event.target
            if event.phase == "moved" then
                local delta = math.abs(event.x - event.xStart) + math.abs(event.y - event.yStart)
                if delta > app.touchDelta then
                    display.getCurrentStage():setFocus(event.target, nil)
                    event.target.isFocus = false
                    scrollview:takeFocus(event)
                end
            elseif event.phase == "ended" then
                if not t or t.isFocus == false or not t.type then return true end
                if t.type == "image" then
                    copy_pasteboard(t.data.title)
					new_s_warning(app.words[288])
                elseif t.type == "file" or t.type == "lua" or t.type == "web" then
                    local dialog = new_input_alert({header = t.data.title}, function(e) 
                        ponosFile["писать путь"](t.data.file, e)
                    end, false)
                    dialog.text(ponosFile["читать путь"](t.data.file))
                elseif t.type == "folder" then
                    table.insert(resourcesDir, t.data.title)
                    updatelist()
                end
            end
            return true
        end
        
        for i = 1, #list_files do
            local mygroup = display.newGroup()
            projects_group:insert(mygroup)
            mygroup.y = (i-1) * tabheight + app.pad + app.pad * (i-1)
            
            local data = {title = list_files[i], file = filesDir .. "/" .. list_files[i]}
			local btnOutline = display.newRoundedRect(mygroup, sw/2, tabheight/2, sw-app.pad*2+4, tabheight+4, 30+2)
            btnOutline:setFillColor( unpack(app.color.listOutlineColor) )
            local btnBg = PonosUi.newButton(touchEl, {
                x = sw / 2, y = tabheight / 2, width = sw-app.pad*2, height = tabheight, alpha = 1, style = "list", line_width = 0, rounded = 30,
            }, mygroup)
            
            local ext = ponosFile.format(data.title)
            local itemType = formats[ext]
            if not itemType then
                local fullPath = system.pathForFile(data.file, system.DocumentsDirectory)
                local attr = fullPath and lfs.attributes(fullPath)
                itemType = (attr and attr.mode == "directory") and "folder" or "file"
            end
            
            local iconX = (thumbSize / 2) + app.pad*2
            local iconY = btnBg.y
            
            if itemType == "image" then
                local thumb = display.newImage(mygroup, data.file, system.DocumentsDirectory)
                if thumb then
                    thumb.x = iconX
                    thumb.y = iconY
					local scale = thumbSize / math.max(thumb.width, thumb.height)
                    thumb.width = thumb.width * scale
                    thumb.height = thumb.height * scale
                else
                    local fallback = display.newRoundedRect(mygroup, iconX, iconY, thumbSize, thumbSize, 9)
                    fallback.fill = {type = "image", filename = "res/ui/image.png"}
					fallback:setFillColor(app.color.textAcentLightColor[1],app.color.textAcentLightColor[2],app.color.textAcentLightColor[3])
                end
            else
                local icon = display.newRoundedRect(mygroup, iconX, iconY, thumbSize, thumbSize, 9)
                icon.fill = {type = "image", filename = "res/ui/" .. itemType .. ".png"}
				icon:setFillColor(app.color.textAcentLightColor[1],app.color.textAcentLightColor[2],app.color.textAcentLightColor[3])
            end
            
            btnBg.type = itemType
            btnBg.data = data
            
            local funs = {
                {app.words[15], "rename"},
                {app.words[289], "copy"},
                {app.words[13], "delete"}
            }
            
            local menu2 = PonosUi.newButton(function(e)
                if e.phase == "moved" then
                    local delta = math.abs(e.x - e.xStart) + math.abs(e.y - e.yStart)
                    if delta > app.touchDelta then
                        display.getCurrentStage():setFocus(e.target, nil)
                        e.target.isFocus = false
                        scrollview:takeFocus(e)
                    end
                elseif e.phase == "ended" then
                    if e.target and e.target.isFocus == false then return true end
                    dropdown(group, funs, function(a, b)
					    if a == false then return false end
                        if b[2] == "rename" then
                            local dialog = new_input_alert({
                                header = app.words[15],
                                description = app.words[22]
                            }, function(newName)
                                if newName and newName ~= "" then
                                    if itemType == "folder" then
                                        ponosFile["переименовать папку"](data.file, newName)
                                    else
                                        ponosFile["переименовать файл"](newName, data.file, filesDir)
                                    end
                                    updatelist()
                                end
                            end, true)
                            dialog.text(data.title)
                        elseif b[2] == "copy" then
                            local copyName = data.title
                            local base, extPart = copyName:match("^(.+)(%..+)$")
                            if itemType == "folder" then
                                copyName = data.title .. "_copy"
                                ponosFile["копировать папку"](data.file, filesDir .. "/" .. copyName)
                            else
                                if base then
                                    copyName = base .. "_copy" .. extPart
                                else
                                    copyName = data.title .. "_copy"
                                end
                                ponosFile["копировать файл"](data.file, filesDir .. "/" .. copyName)
                            end
                            updatelist()
                        elseif b[2] == "delete" then
                            new_dialog({
                                header = app.words[23],
                                description = app.words[24],
                                buttons = {
                                    {text = app.words[25]},
                                    {text = app.words[26], callback = function()
                                        if itemType == "folder" then
                                            ponosFile["удалить папку"](data.file)
                                        else
                                            ponosFile["удалить файл"](data.file)
                                        end
                                        updatelist()
                                    end}
                                }
                            })
                        end
                    end, {x = sw, y = e.y})
                end
                return true
            end, {
                x = sw - thumbSize / 2 - app.pad*2, y = btnBg.y,
                width = thumbSize, height = thumbSize,
                icon = {path = "res/ui/menu.png"}, alpha = 0, rounded = thumbSize / 2
            }, mygroup)
            local text = deep_copy(data.title)
            if utf8.len(text)>16 then text = utf8.sub(text, 1, 16) .. '...' end
            local name = display.newText({
                x = iconX + thumbSize / 2 + app.pad*2, y = btnBg.y,
                text = text, width = sw - app.pad * 6 - thumbSize*2,
                align = "left", fontSize = app.fontsize1, font = app.font
            })
            mygroup:insert(name)
            name.anchorX = 0
			name:setFillColor(app.color.textAcentLightColor[1], app.color.textAcentLightColor[2], app.color.textAcentLightColor[3])
        end
    end
    
    updatelist()
    
    back_fun = function()
        if #resourcesDir == 1 then
            scene.goto("project", {transition = "slideRight", params = {}})
        else
            table.remove(resourcesDir, #resourcesDir)
            updatelist()
        end
    end
    
    special_back_fun = function(event) back_fun() end
end

return M