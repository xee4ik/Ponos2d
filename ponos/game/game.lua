-- Скрипт: привет гавногод, мы же лучшие друзбя? давай постараемся вместе.

--[[
    ладно, на самом деле всё не так плохо
	
	это модуль для отладки и симуляции lua-кода с апи solar2d соедененный с сборкой кода из блоков.
    тут есть функция для запуска lua-кода и генератор блоков
	
	чтобы добавить новый блок обратите внимание на таблицу generators - в ней находится какраз тот код который собирабт блоки. Пишите название блока из таблицы all_blocks и дальше по шаблону: function(p)
        return string.format("какой-то код и первый параметр блока это '%s'", p[1])
    end
	
	также в функции load_game() подготавливается код - там вы можете написать кастомные функции для новых формул 
	
	ВАЖНО: использовать функции извне кода игры лучше не делать. Продублируйте модуль, который хотите использовать в код игры для начала
]]

console_ = {}
isGameSim = true
local modules = require('ponos.game.modules')

local function run_lua(lua_code, target_group)
    local loaded_func, err = loadstring(lua_code)
    
    if loaded_func then
        local env = {}
        setmetatable(env, { __index = _G })
        
        env.display = {}
        setmetatable(env.display, { __index = _G.display })
        
        env.__sandbox_error = function(err_msg)
            print("runtime ERROR: ", err_msg)
            if ponosSettings and ponosSettings.errorAlert and type(new_warning) == "function" then
                new_warning(app.words[53])
            end
            table.insert(console_, {app.words[476] .. tostring(err_msg), 'error'})
        end

        env.display.newRoundedRect = function(...)
            local obj = _G.display.newRoundedRect(...)
            if obj and target_group and target_group.insert then
                target_group:insert(obj)
            end
            return obj
        end

        env.display.newRect = function(...)
            local obj = _G.display.newRect(...)
            if obj and target_group and target_group.insert then
                target_group:insert(obj)
            end
            return obj
        end
		
		env.display.newImage = function(...)
            local obj = _G.display.newImage(...)
            if obj and target_group and target_group.insert then
                target_group:insert(obj)
            end
            return obj
        end

        env.display.newCircle = function(...)
            local obj = _G.display.newCircle(...)
            if obj and target_group and target_group.insert then
                target_group:insert(obj)
            end
            return obj
        end
		
		env.display.newText = function(...)
            local obj = _G.display.newText(...)
            if obj and target_group and target_group.insert then
                target_group:insert(obj)
            end
            return obj
        end
		
		env.display.newGroup = function(...)
            local obj = _G.display.newGroup(...)
            if obj and target_group and target_group.insert then
                target_group:insert(obj)
            end
            return obj
        end
        
        setfenv(loaded_func, env)
        
        local success, runtime_err = pcall(loaded_func)
        if not success then
            env.__sandbox_error(runtime_err)
        else
            table.insert(console_, {string.format(app.words[475], project_data.project_name), 'success'})
        end
    else
        print("ERROR: ", err)
        if ponosSettings and ponosSettings.errorAlert and type(new_warning) == "function" then
            new_warning(app.words[53])
        end
        table.insert(console_, {app.words[303] .. tostring(err), 'error'})
    end
end

local generators = modules.generators

local function input_block(data)
    local index = data.index
    
    if not all_blocks or not all_blocks[index] then
        return "-- ERROR BLOCK"
    end

    local processed_params = {}
    if data.params then
        for i = 1, #data.params do
		    if type(data.params[i]) == "table" then
            processed_params[i] = pekarim_formula(data.params[i])
			else
			processed_params[i] = data.params[i]
			end
        end
    end

    local generator = generators[index]
    if generator then
        return generator(processed_params)
    end

    return "-- UNKNOWN BLOCK"
end

function load_game(project_dat, groupScene, isGet, backscene)
    backscene = backscene or {}
    orientation.lock(project_dat.orientation)
    if project_dat.orientation == 'portrait' then
	 display.contentWidth = sw
	 display.contentHeight = sh
    else
	 display.contentWidth = sh
	 display.contentHeight = sw
    end

    local list = ponosFile["получить список скриптов"](project_dat.project_name)
    local scripts = {}
    
    for i = 1, #list do
        local el = ponosFile["загрузить скрипт"](list[i].file, project_dat.project_name)
        table.insert(scripts, el)
    end
	
    local lua = modules.loadPonosEngine(project_dat)

    lua = lua .. "\nponosfun.threader(function()\n"

    for i = 1, #scripts do
        local blocks = scripts[i].script or {}
        lua = lua .. "\n--" .. tostring(scripts[i].title) .. "\n"
		lua = lua .. [[ponosfun.threader(function()
		local current_scope = ponosfun.createScope(local_vars)
                local local_vars = current_scope
                
                local parent_ponosfun = ponosfun
                local ponosfun = setmetatable({
                    get_var = function(name)
                        local val = local_vars[name]
                        if val == nil then val = global_vars[name] end
                        if val == nil then ponosfun.print("переменная '"..name.."' несуществует") return nil end
                        return val
                    end
                }, { __index = parent_ponosfun })]]
        
        for j = 1, #blocks do
            lua = lua .. input_block(blocks[j]) .. "\n"
        end
		lua = lua .. "end)\n"
    end
    
    lua = lua .. "\nend)\n"
	
	print(lua)
    
    if not isGet then
	
    local group = display.newGroup()
    groupScene:insert(group)
    
    local consoleGroup = display.newGroup()
	consoleGroup.x = display.contentWidth/2
    groupScene:insert(consoleGroup)
    
    local consoleBg = display.newRoundedRect(consoleGroup, 0, 0, math.min(display.contentWidth,display.contentHeight, 640)-50, math.min(math.min(display.contentWidth,display.contentHeight)*1.4-50, display.contentHeight - 100, 480), 110/3.4)
    consoleBg:setFillColor(app.color.panelBgColor[1],app.color.panelBgColor[2],app.color.panelBgColor[3])
	consoleGroup.y = consoleGroup.height/2+50
    local scrollview = PonosUi.newScrollView({
        x = 0,
        y = -consoleBg.height/2,
        height = consoleBg.height-60,
        width = consoleBg.width,
		horizontalScrollDisabled = true,
    })
    consoleGroup:insert(scrollview)
	local text_group = {}
	local console_isOpen = false
	local function updateConsole()
	    if text_group.num then
	    if console_isOpen and text_group.num ~= #console_ then
		    display.remove(text_group)
			text_group = display.newGroup()
			scrollview:insert(text_group)
			text_group.num = #console_
			local currenty = 0
	        for i = 1, #console_ do
			    local value = console_[i][1]
				local color = console_[i][2] or 'default'
				local font = console_[i][3] or app.font
				
				if type(value) == 'table' then 
				    value = tostring(value)..'\nJSON: '..json.encode(value)
				end
				
				if type(color) == 'string' then 
				    if color == 'default' then
					    color = {0.3,0.3,0.3}
					elseif color == 'success' then
					    color = {0,0.75,0}
						font = app.fontBold
					elseif color == 'error' then
					    color = {179/255,8/255,9/255}
					end 
				end
				
				local el = display.newGroup()
				text_group:insert(el )
				
				local text = display.newText({
				    x = app.pad, y = 0, width = scrollview.width-app.pad*2, font = font, fontSize = app.fontsize1,
					text = tostring(value)
				})
				text.anchorX = 0
				local bg = display.newRect(el, 0,0, scrollview.width, text.height+app.pad*2)
				bg:setFillColor(unpack(color))
				bg.anchorX = 0
				el:insert(text)
				el.y = currenty+el.height/2
				currenty = currenty+el.height
			end
	    end
		else 
		 text_group.num = 0
		end
	end
	
    consoleGroup.isVisible = false
    
    local function console()
        if not console_isOpen then
            console_isOpen = true
            consoleGroup.isVisible = true
            consoleGroup.alpha = 0
            transition.to(consoleGroup, {alpha = 1, time = 200})
            updateConsole()
        else
            console_isOpen = false
            transition.to(consoleGroup, {alpha = 0, time = 200, onComplete = function()
                consoleGroup.isVisible = false
            end})
        end
    end
	
	timer.performWithDelay(100, function() updateConsole() end, 0)
	
	local hline = display.newRect(consoleGroup, 0,-consoleBg.height/2+scrollview.height, consoleBg.width, 4)
	hline:setFillColor(app.color.lineColor[1],app.color.lineColor[2],app.color.lineColor[3], app.color.lineColor[4])
	local buttons = { {text = app.words[304], index = "clear"}, {text = app.words[305], index = "close"}}
	local elWidth = consoleBg.width/#buttons
	for i = 1, #buttons do
	    local item = buttons[i]
		local id = item.index 
	    local btn = PonosUi.newButton(function(event)
		    if event.phase == "ended" then
			    if id == "clear" then
				    console_ = {{app.words[306], nil}}
					updateConsole()
				elseif id == "close" then
				    console()
				end
			elseif event.phase == "moved" then
			    scrollview:takeFocus(event)
			end
		end, {x = (i-1)*elWidth - consoleBg.width/2, y = consoleBg.height/2, width = elWidth, height = 60, text = item.text, rounded = 110/3.4, alpha = 0.01, fontSize = 18}, consoleGroup)
		btn.anchorX = 0
		btn.anchorY = 1
	end
    
    local groupPanel = display.newGroup()
    groupScene:insert(groupPanel)
    local panelh = 110
    local bg = display.newRoundedRect(groupPanel, 0, 0, math.min(display.contentWidth,display.contentHeight)-50*2, panelh, panelh/3.4)
    bg:setFillColor(app.color.panelBgColor[1],app.color.panelBgColor[2],app.color.panelBgColor[3])
    groupPanel.x = display.contentWidth/2
    local open_y = display.contentHeight-panelh/2-50
    groupPanel.y = display.contentHeight+panelh/2
    groupPanel.isVisible = false
	
	local panel_is_open
    
    local function close_panel()
	    panel_is_open = false
        groupPanel:toFront()
		if groupPanel.animation then
		    transition.cancel(groupPanel.animation)
		end
        groupPanel.animation = transition.to(groupPanel, {y = display.contentHeight+panelh/2, time = 300, transition = easing.inQuad, onComplete = function()
		groupPanel.isVisible = false
		end})
    end
    
    local buttons = {
        { "back", nil, "res/ui/back.png" },
        { "continue", nil, "res/ui/play.png" },
        { "console", nil, "res/ui/build.png" },
    }
	
    local elw = (bg.width-app.pad)/#buttons
    local currentx = -bg.width/2+app.pad/2
    for i = 1, #buttons do
        local index = buttons[i][1]
        local btn = PonosUi.newButton(function(event)
        if event.phase == "ended" then
            if index == "back" then
                special_back_fun()
            end
            if index == "continue" then
                close_panel()
            end
            if index == "console" then
                console()
            end
        end
        end, {x = currentx, y = 0, width = elw, height = bg.height-app.pad, rounded = bg.height/3.4, alpha = 0.01, text = buttons[i][2] or "", icon = {path = buttons[i][3]}}, groupPanel)
        btn.anchorX = 0
        currentx = currentx+elw
    end
    
    local function open_panel()
	    panel_is_open = true
        groupPanel:toFront()
		groupPanel.isVisible = true
		if groupPanel.animation then
		    transition.cancel(groupPanel.animation)
		end
        groupPanel.animation = transition.to(groupPanel, {y = open_y, time = 300, transition = easing.outQuad})
    end
	
	special_back_fun = function(event)
	    if panel_is_open then
		    if timer.cancelAll then timer.cancelAll() end
			if project_dat.automatic_screenshot then 
			    ponosFile["удалить файл"](project_path .. '/icon.png') 
				local container = display.newContainer(app.content, app.content)
				container:insert(group)
				group.x = -app.content/4
				group.y = -display.contentHeight/2+app.content/4
				container.y = 0
				container.x = 0
				display.save(container,{ filename=project_path .. '/icon.png', baseDir=system.DocumentsDirectory, backgroundColor={0,0,0,0}}) 
				display.remove(container)
			end
			orientation.lock('portrait')
			display.contentWidth = sw
			display.contentHeight = sh
			system.deactivate('multitouch')
            scene.goto(backscene.name or 'project', {transition = "slideRight", params = backscene.params or {}})
		else
		    open_panel()
		end
	end
    
    local drag = 0
    
    local openbtn = PonosUi.newButton(function(event)
        local t = event.target
        if event.phase == "began" then
            t.isFocus = true
            display.currentStage:setFocus( t )
            if t.trans then
                transition.cancel(t.trans)
            end
            drag = false
        end
        
        if event.phase == "moved" and t.isFocus then
            local dx = math.abs(event.x - event.xStart)
            local dy = math.abs(event.y - event.yStart)
            if dx > 20 or dy > 20 then
                drag = true
            end
            
            if drag then
                t.alpha = 1
                t.x = event.x 
                t.y = event.y
            end
        end
        
        if (event.phase == "ended" or event.phase == "cancelled") and t.isFocus then
            t.alpha = 0.6
            t.isFocus = false
            
            if not drag then
                open_panel()
            else
                local x = t.x 
                local y = t.y 
                if t.x < display.contentWidth/2 then x = 100 else x = display.contentWidth-100 end
                if t.y > display.contentHeight/2 then y = display.contentHeight-100 else y = 100 end
                t.trans = transition.to(t, {x = x, y = y, time = 350, transition = easing.outQuad})
            end
            drag = false
			display.currentStage:setFocus( nil )
        end
    end, { x = display.contentWidth-100, y = display.contentHeight-100, width = 80, height = 80, rounded = 30, text = '', colorBg = app.color.panelBgColor, icon = {path = 'res/ui/undo.png'}}, groupScene)
    openbtn.alpha = 0.6
	
	run_lua(lua, group)
	
	else
	return lua
    end
end

function buildProjectFolder(data)
local name = data.project_name
local PathMyProject = "projects/"..name.."/"
local path = "build/"..name
local lua = load_game(data, nil, true)
ponosFile["создать путь"](path)
ponosFile["копировать папку"](PathMyProject.."resources", path.."/res")
ponosFile["писать путь"](path.."main.lua", lua)
ponosFile["писать путь"](path.."config.lua", 'application={content={width=math.max(480,math.min(display.pixelHeight,display.pixelWidth)/(2.4)),height=math.max(480,math.min(display.pixelHeight,display.pixelWidth )/(2.4))*display.pixelHeight/display.pixelWidth,scale="letterbox",fps=60,},}' )
ponosFile["писать путь"](path.."build.settings",'settings={orientation={default="portrait",supported={"portrait"}},android={usesPermissions={"android.permission.INTERNET"},},plugins ={},excludeFiles={all={"Icon.png","Icon-*dpi.png","Images.xcassets"},android={"LaunchScreen.storyboardc"}},}')

ponosFile["папка в zip"](path, function() end)
end

return true