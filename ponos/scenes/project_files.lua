local M = {}

-- В будующем хочу сделать просмотр песочницы проекта, но ее еще просто нету. Этот файл - просто заготовка

function M.create(group, params)
    local path_for_res = project_path.."resources/"
	
	local bg = display.newRect(group, sw / 2, sh / 2, sw, sh)
    bg:setFillColor(app.color.mainBackgroundColor[1],app.color.mainBackgroundColor[2],app.color.mainBackgroundColor[3])

    local topbar = PonosUi.newTopBar(group, project_data.project_name, nil, function(e) end)
	
	local topbar2 = PonosUi.newTopBar2(group, "", { {id = "back", icon = "res/ui/back.png", callback = function()
	    scene.goto("project", {transition = "slideRight"})
	end} } )
    local bar2height = topbar2.barheight
end