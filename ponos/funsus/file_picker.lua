-- В моменте я решил написать свой кастомный файл пикер, но он работает только с локальным хранилищем почемуто

local color = {bg = {53/255, 53/255, 53/255}}

local dialogW = math.min(720, display.contentWidth - 20)
local dialogH = math.min(790, display.contentWidth * 1.3)

local lfs = require("lfs")

local platform = system.getInfo("platform")
local ROOT_STORAGE = ""
local base_dirs = {}

if platform == "android" then
    ROOT_STORAGE = "/sdcard/"
    if not lfs.attributes(ROOT_STORAGE) then
        ROOT_STORAGE = "/storage/emulated/0/"
    end
    base_dirs = {
        {name = "Память", path = ROOT_STORAGE, icon = "res/ui/import.png"},
        {name = "Загрузки", path = ROOT_STORAGE .. "Download", icon = "res/ui/import.png"},
        {name = "DCIM", path = ROOT_STORAGE .. "DCIM", icon = "res/ui/import.png"}
    }

elseif platform == "win" then
    ROOT_STORAGE = "C:/"
    local user_profile = os.getenv("USERPROFILE") or os.getenv("HOME")
    local user_docs = user_profile:gsub("\\", "/") .. "/Documents"
    
    local possible_dirs = {
        {name = "Диск C:", path = "C:/"},
        {name = "Диск D:", path = "D:/"},
        {name = "Диск E:", path = "E:/"},
        {name = "Мои док.", path = user_docs}
    }
    
    for _, dir in ipairs(possible_dirs) do
        local success, attr = pcall(lfs.attributes, dir.path)
        if success and attr and attr.mode == "directory" then
            dir.icon = "res/ui/import.png"
            table.insert(base_dirs, dir)
        end
    end

else
    ROOT_STORAGE = system.pathForFile("", system.DocumentsDirectory)
    base_dirs = {
        {name = "Документы", path = system.DocumentsDirectory, icon = "res/ui/import.png"}
    }
end

pick_file = function(file_type, save_as, callback)
    local dialogGroup = display.newGroup()
    dialogGroup.x = display.contentWidth / 2
    dialogGroup.y = display.contentHeight / 2
    dialogGroup:addEventListener("touch", function() return true end)

    local bg = display.newRoundedRect(dialogGroup, 0, 0, display.contentWidth, display.contentHeight, 4)
    bg:setFillColor(0, 0, 0, 0.6)
	
    local rect = display.newRoundedRect(dialogGroup, 0, 0, dialogW, dialogH, 8)
    rect:setFillColor(color.bg[1], color.bg[2], color.bg[3])
	
    dialogGroup.alpha = 0
    transition.to(dialogGroup, {transition = easing.outQuad, time = 225, alpha = 1, y = display.contentHeight / 2})
	
	local catW = 150
	
	local scroll_cat = PonosUi.newScrollView({
	    x = -dialogW/2 + catW/2,
        y = -dialogH/2,
        width = catW,
        height = dialogH - 80,
        horizontalScrollDisabled = true,
		showScrollbars = false
    })
	
	local line = display.newRect(dialogGroup, catW - dialogW/2 + 2, -80/2, 4, dialogH - 20 - 80)
	line:setFillColor(app.color.lineColor[1],app.color.lineColor[2],app.color.lineColor[3])
	line.alpha = app.color.lineColor[4]
	
	
	local current_base_path = ROOT_STORAGE
	local directs = {} 
	
	local function get_full_path()
	    local path = current_base_path:gsub("\\", "/")
	    if path:sub(-1) == "/" and not path:match("^%a:/$") then
	        path = path:sub(1, -2)
	    end
		for i = 1, #directs do
		    path = path .. "/" .. directs[i]
		end
		return path
	end
	
	local patht = display.newText({
	    x = -dialogW/2 + catW + 2 + 20,
		y = -dialogH/2 + 20,
		width = dialogW - catW - 2 - 40,
		height = 40,
		text = "/",
		parent = dialogGroup,
		fontSize = 24,
		align = "left",
		font = app.font
	})
	patht.anchorX = 0
	patht.anchorY = 0
	
	local function update_path_text()
	    local display_path = "/"
		for i = 1, #directs do
		    display_path = display_path .. directs[i] .. "/"
		end
		if patht then patht.text = display_path end
	end
	
	local selected_file = nil

	local scroll_file = PonosUi.newScrollView({
	    x = catW/2,
        y = -dialogH/2 + 60,
        width = dialogW - (catW + 2),
        height = dialogH - 80 - 60, 
        horizontalScrollDisabled = true,
		showScrollbars = false
	})
	dialogGroup:insert(scroll_file)
	
	local function clear_file_list()
	    local target = scroll_file.content or scroll_file 
	    while target.numChildren > 0 do
	        target[target.numChildren]:removeSelf()
	    end
	end

	local function get_list()
	    clear_file_list()
	    selected_file = nil
	    
	    local path = get_full_path()
	    
		print(path)
		
	    local success_attr, attr = pcall(lfs.attributes, path)
	    if not success_attr or not attr or attr.mode ~= "directory" then
	        patht.text = "Ошибка доступа или путь неверен"
	        return
	    end

	    local files = {}
	    local dirs = {}
	    
	    local success_iter, iter = pcall(lfs.dir, path)
	    
	    if success_iter then
	        for file in iter do
	            if file ~= "." and file ~= ".." then
	                local full = path .. "/" .. file
	                
	                local success_f, f_attr = pcall(lfs.attributes, full)
	                
	                if success_f and f_attr then
	                    if f_attr.mode == "directory" then
	                        table.insert(dirs, file)
	                    elseif f_attr.mode == "file" then
	                        if not file_type then
	                            table.insert(files, file)
	                        else
	                            local ext = file:match("^.+%.(.+)$")
	                            if ext then
	                                if type(file_type) == "string" and ext == file_type then
	                                    table.insert(files, file)
	                                elseif type(file_type) == "table" then
	                                    for _, v in ipairs(file_type) do
	                                        if ext == v then 
	                                            table.insert(files, file)
	                                            break 
	                                        end
	                                    end
	                                end
	                            end
	                        end
	                    end
	                end
	            end
	        end
	    end
	    
	    table.sort(dirs)
	    table.sort(files)
	    
	    local target = scroll_file.content or scroll_file
	    local y_offset = 0
	    local item_h = 60
		local item_w = scroll_file.width - 20
	    
	    if #directs > 0 then
	        local btn = PonosUi.newButton(nil, {
	            x = item_w/2+10, y = y_offset + item_h/2, 
	            width = item_w, height = item_h - 10, 
	            text = "(назад)", text_align = "left", icon = {path = "res/ui/back.png", position = "left"}, rounded = 10
	        }, target)
	        
	        btn:addEventListener("tap", function()
	            table.remove(directs)
	            update_path_text()
	            get_list()
	        end)
	        y_offset = y_offset + item_h
	    end
	    
	    for _, d in ipairs(dirs) do
	        local btn = PonosUi.newButton(nil, {
	            x = item_w/2+10, y = y_offset + item_h/2, 
	            width = item_w, height = item_h - 10, 
	            text = d, text_align = "left", icon = {path = "res/ui/folder.png", position = "left"}, rounded = 10
	        }, target)
	        
	        btn:addEventListener("tap", function()
	            table.insert(directs, d)
	            update_path_text()
	            get_list()
	        end)
	        y_offset = y_offset + item_h
	    end
	    
	    for _, f in ipairs(files) do
	        local btn = PonosUi.newButton(nil, {
	            x = item_w/2+10, y = y_offset + item_h/2, 
	            width = item_w, height = item_h - 10, 
	            text = f, rounded = 10, text_align = "left", icon = {path = "res/ui/file.png", position = "left"}
	        }, target)
	        
	        btn:addEventListener("tap", function()
	            selected_file = f
	            print("Выбран файл: " .. f)
	        end)
	        y_offset = y_offset + item_h
	    end
	    
	    if target.setScrollHeight then target:setScrollHeight(y_offset) end
	end
	
	for i = 1, #base_dirs do
	    local this = base_dirs[i]
	    local btn = PonosUi.newButton(nil, {
	        x = catW/2, y = -dialogH/2 + 40 + (i-1)*70, 
	        width = catW - 20, height = 60, 
	        text = this.name, icon = {path = this.icon}, rounded = 25
	    }, scroll_cat)
	    
	    btn:addEventListener("tap", function()
	        current_base_path = this.path
	        directs = {} 
	        update_path_text()
	        get_list()
	    end)
	end

    dialogGroup:insert(scroll_cat)
	
	local bottomBar = display.newRect(dialogGroup, 0, dialogH/2 - 40, dialogW, 80)
	bottomBar:setFillColor(color.bg[1] * 0.8, color.bg[2] * 0.8, color.bg[3] * 0.8)
	
	local inputField = nil
	if save_as then
	    inputField = native.newTextField(0, 0, dialogW - 240, 40)
	    inputField.placeholder = "Имя файла..."
	    dialogGroup:insert(inputField)
	    inputField.x = -60
	    inputField.y = dialogH/2 - 40
	end
	
	local function close_dialog(result_path)
	    if inputField then inputField:removeSelf() end
	    
	    transition.to(dialogGroup, {
	        transition = easing.inQuad, time = 225, alpha = 0,
	        onComplete = function()
	            dialogGroup:removeSelf()
	            dialogGroup = nil
	            if callback then callback(result_path) end
	        end
	    })
	end
	
	local btnCancel = PonosUi.newButton(nil, {
	    x = -dialogW/2 + 100,
	    y = dialogH/2 - 40, 
	    width = 120, height = 50, 
	    text = "Отмена", rounded = 15
	}, dialogGroup)
	
	btnCancel:addEventListener("tap", function()
	    close_dialog(nil)
	end)
	
	local btnConfirm = PonosUi.newButton(nil, {
	    x = dialogW/2 - 100, 
	    y = dialogH/2 - 40, 
	    width = 120, height = 50, 
	    text = save_as and "Сохранить" or "Открыть", rounded = 15
	}, dialogGroup)
	
	btnConfirm:addEventListener("tap", function()
	    if save_as then
	        local fname = inputField.text
	        if fname == "" then 
	            print("Введите имя файла!")
	            return 
	        end
	        if file_type and type(file_type) == "string" and not fname:match("%.") then
	            fname = fname .. "." .. file_type
	        end
	        local full_path = get_full_path() .. "/" .. fname
	        close_dialog(full_path)
	    else
	        if selected_file then
	            local full_path = get_full_path() .. "/" .. selected_file
	            close_dialog(full_path)
	        else
	            print("Выберите файл!")
	        end
	    end
	end)

	get_list()
	
    return dialogGroup
end