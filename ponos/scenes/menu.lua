local M = {}
local pages = {}
pages.account = require("ponos.scenes.menuPages.account")
pages.projects = require("ponos.scenes.menuPages.projects")
pages.socialnet = require("ponos.scenes.menuPages.socialnet")

function M.create(group, params)
    params = params or {page = "projects"}
    local bg = display.newRect(group, sw/2, sh/2, sw, sh)
    bg:setFillColor(app.color.mainBackgroundColor[1], app.color.mainBackgroundColor[2], app.color.mainBackgroundColor[3])

    local topbar = PonosUi.newTopBar(group, "Ponos 2d", nil, function(e) end)
    local menuBtnSize = topbar.barheight - app.pad

    local tgBtn = PonosUi.newButton(function(e)
        if e.phase == "ended" then
            system.openURL("https://t.me/xee_apk")
        end
    end, {
        x = sw - menuBtnSize/2 - app.pad/2,
        y = topbar.barheight / 2,
        width = menuBtnSize,
        height = menuBtnSize,
        icon = {path = "res/ui/telegram.png", size = menuBtnSize*0.6},
        alpha = 0.8,
        rounded = menuBtnSize/2
    }, group)

    local contentGroup = display.newGroup()
    group:insert(contentGroup)

    local current_page = nil
    local panel
    local thisPage = nil

    local pagetonum = {account = 1, projects = 2, socialnet = 3}

    local function switch_page(page_name)
        -- Если нажали на ту же самую вкладку — ничего не делаем
        if thisPage == page_name then return end
        
        timer.cancelAll() 
        
        local old_index = thisPage and pagetonum[thisPage] or pagetonum[page_name]
        local new_index = pagetonum[page_name]
        thisPage = page_name

        local direction = (new_index > old_index) and 1 or -1

        -- 1. Берем текущую страницу (если она есть) и отправляем её за экран
        local page_to_remove = current_page
        if page_to_remove then
            -- Останавливаем её текущую анимацию (на случай, если она еще выезжает)
            transition.cancel(page_to_remove)
            
            -- Анимируем её уход
            transition.to(page_to_remove, {
                x = -sw * direction, 
                alpha = 0, 
                time = 250, -- Сделал чуть быстрее (250 вместо 300) для динамики
                transition = easing.outExpo,
                onComplete = function(obj)
                    if obj and obj.removeSelf then
                        obj:removeSelf() -- Удаляем безопасно
                    end
                end
            })
        end

        -- 2. Создаем новую страницу
        local new_page = nil
        if pages[page_name] and pages[page_name].create then
            new_page = pages[page_name].create({
                y = topbar.barheight,
                height = sh - topbar.barheight - panel.height
            })
            contentGroup:insert(new_page)
        end

        current_page = new_page

        -- 3. Анимируем появление новой страницы
        if current_page then
            if page_to_remove then
                current_page.x = sw * direction
                current_page.alpha = 0
                transition.to(current_page, {
                    x = 0, 
                    alpha = 1, 
                    time = 250, 
                    transition = easing.outExpo 
                })
            else
                -- Если это первый запуск (нет старой страницы)
                current_page.alpha = 0
                transition.to(current_page, {alpha = 1, time = 200})
            end
        end
    end
    
    panel = PonosUi.newBottomBar(function(e)
        -- Убрали блокировку isSwitching, теперь можно кликать быстро
        if thisPage ~= e then 
            app.popSound("click1") 
            switch_page(e)
        end
    end, {
        {text = "", icon = "res/ui/account.png", index = "account"},
        {text = "", icon = "res/ui/files.png", index = "projects"},
        {text = "", icon = "res/ui/live help.png", index = "socialnet"}
    }, group, true, true)
    
    local start_page = params.page or "projects"
    switch_page(start_page)
    panel.select(pagetonum[start_page])

    if ponosSettings.isFirstTime then
        ponosSettings.isFirstTime = false
        app.ponosSttSave()
    end

    special_back_fun = function(event)
        transition.to(group, {x = -2, time = 167/3, alpha = 0.99, xScale = 0.98, onComplete = function()
            transition.to(group, {x = 0, time = 254, alpha = 1, xScale = 1, transition = easing.outBack})
        end})
    end
end

return M