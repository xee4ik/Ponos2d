-- файл с категориями блоков. ЭТО НЕ БЛОКИ, А КАТЕГОРИИ - РАЗМЕТКА ПРОСТО. блоки пишутся в "ponos.all.dat_blocks"

function updateBlocksCategoryWords()

blocks_category = {
    ["event"]={
	    {
            index = "comment",
            params = { 
                app.words[471]
            }
        },
		--{ index = "in_comment", params = { } },
	    {
		    index = "add_touch_listener",
			params = {{ {"string", "object"} }, { {"string", "event"} }}
		},
		{
            comment = app.words[54],
			info = app.words[55],
        },
	    {
            index = "if_condition",
            params = { 
                { {"func", "get_var"}, {"function", "("}, {"string", "event"}, {"function", ")"}, {"key", "phase"}, {"function", "=="}, {"string", "began"} }
            }
        },
		{
            comment = app.words[56],
			info = app.words[57],
        },
		{
            index = "if_condition",
            params = { 
                { {"func", "get_var"}, {"function", "("}, {"string", "event"}, {"function", ")"}, {"key", "phase"}, {"function", "=="}, {"string", "moved"} }
            }
        },
		{
            comment = app.words[58],
			info = app.words[59],
        },
		{
            index = "if_condition",
            params = { 
                { {"func", "get_var"}, {"function", "("}, {"string", "event"}, {"function", ")"}, {"key", "phase"}, {"function", "=="}, {"string", "ended"} }
            }
        },
		--{
        --    index = "remove_listener",
        --    params = { 
        --        { {"string", "object"} },
		--		{'"touch"'}
        --    }
        --},
		{
            index = "set_focus",
            params = { 
                { {"string", "object"} }
            }
        },
		{
            index = "remove_focus",
            params = { 
                { }
            }
        },
		{
		    comment = app.words[470],
		},
		{
            index = "global_function",
            params = { 
                { {"string", "func"} },
				{ {"string", "event"} }
            }
        },
		{
            index = "local_function",
            params = { 
                { {"string", "func"} },
				{ {"string", "event"} }
            }
        },
		{
            index = "call_func",
            params = { 
                { {"string", "func"} },
            }
        },
		{
            index = "call_func_params",
            params = { 
                { {"string", "func"} },
				{ {"number", "0"} }
            }
        },
		{
		    index = "add_object_event_listener",
			params = {
			    "'touch'",
				{ {"string", "object"} },
				{ {"string", "func"} }
			}
		}
    },
    
    ["object"]={
	    {
            comment = app.words[60],
        },
        {
            index = "new_rounded_rect",
            params = {
                { {"string", "object"} },
                { {"number", 15} },
                { {"number", 0} },
                { {"number", 0} },
                { {"number", 100} },
                { {"number", 100} }
            },
        },
        {
            index = "new_circle",
            params = { {{"string", "object"}}, {{"number", 0}}, {{"number", 0}}, {{"number", 50}} }
        },
        {
            index = "new_text",
            params = { {{"string", "object"}}, {{"string", app.words[222]}}, {{"number", 0}}, {{"number", 0}}, {{"number", 16}} }
        },
        {
            index = "new_image",
            params = { {{"string", "object"}}, {{"string", "image.png"}} }
        },
		{
            comment = app.words[61],
			info = app.words[62]
        },
        {
            index = "new_group",
            params = { {{"string", "groupObject"}} }
        },
		{
            index = "new_container",
            params = { {{"string", "groupObject"}}, {{"number", 100}}, {{"number", 100}} }
        },
		{
		    comment = app.words[469]
		},
        {
            index = "insert_to_group",
            params = { {{"string", "object"}}, {{"string", "groupObject"}} }
        },
		{
		    index = 'set_object_var',
			params = { {{"string", "object"}}, {{"string", "variable"}}, {{"number", 0}} }
		},
		{
            index = "remove_object",
            params = { {{"string", "object"}} }
        }
    },
	
	["behavior"] = {
	    {
		    index = "button_behavior",
			params = { 
			    { {"string", "object"} }, 
				0.1 
			},
		},
	},
	
["move"]={
    { comment = app.words[468] },
    {
        index = "set_position",
        params = {
            { {"string", "object"} },
            { {"number", 100} },
            { {"number", 200} }
        },
    },
    {
        index = "set_x",
        params = {
            { {"string", "object"} },
            { {"number", 100} }
        },
    },
    {
        index = "set_y",
        params = {
            { {"string", "object"} },
            { {"number", 200} }
        },
    },
    {
        index = "change_x",
        params = {
            { {"string", "object"} },
            { {"number", 100} }
        },
    },
    {
        index = "change_y",
        params = {
            { {"string", "object"} },
            { {"number", 200} }
        },
    },
    {
        index = "set_rotation",
        params = {
            { {"string", "object"} },
            { {"number", 0} }
        },
    },
    {
        index = "rotate_right",
        params = {
            { {"string", "object"} },
            { {"number", 45} }
        },
    },
	{
	 comment = app.words[467]
	},
	{
        index = "camera_position",
        params = {
            { {"number", 0} }, { {"number", 0} },
        },
    },
	{
        index = "camera_position_x",
        params = {
            { {"number", 0} }
        },
    },
	{
        index = "camera_position_y",
        params = {
            { {"number", 0} }
        },
    },
},
["physic"]={
    { comment = app.words[466] },
    {
        index = "add_body",
        params = {
            { {"string", "object"} },
            "'dynamic'",
            { {"number", 1} },
            { {"number", 0.2} },
            { {"number", 0.3} },
            { {"number", 1} }
        },
    },
    {
        index = "remove_body",
        params = {
            { {"string", "object"} }
        },
    },
    {
        index = "set_body_type",
        params = {
            { {"string", "object"} },
            "'dynamic'",
        },
    },
    { comment = app.words[465] },
{
    index = "set_hitbox_box",
    params = {
        { {"string", "object"} },
        { {"number", 100} },
        { {"number", 100} }
    },
},
{
    index = "set_hitbox_circle",
    params = {
        { {"string", "object"} },
        { {"number", 50} }
    },
},
    {
        index = "upd_hitbox",
        params = {
            { {"string", "object"} }
        },
    },
--{
  --  index = "set_hitbox_polygon",
--    params = {
      --  { {"string", "object"} },
    --    { {"string", "[-50,-50, 50,-50, 50,50, -50,50]"} }
  --  },
--},
    { comment = app.words[464] },
    {
        index = "set_linear_velocity",
        params = {
            { {"string", "object"} },
            { {"number", 0} },
            { {"number", 0} }
        },
    },
    {
        index = "set_linear_velocity_x",
        params = {
            { {"string", "object"} },
            { {"number", 0} }
        },
    },
    {
        index = "set_linear_velocity_y",
        params = {
            { {"string", "object"} },
            { {"number", 0} }
        },
    },
    {
        index = "apply_force",
        params = {
            { {"string", "object"} },
            { {"number", 0} },
            { {"number", 0} },
            { {"number", 0} },
            { {"number", 0} }
        },
    },
    {
        index = "apply_impulse",
        params = {
            { {"string", "object"} },
            { {"number", 0} },
            { {"number", 0} },
            { {"number", 0} },
            { {"number", 0} }
        },
    },
    {
        index = "set_angular_velocity",
        params = {
            { {"string", "object"} },
            { {"number", 0} }
        },
    },
    {
        index = "apply_torque",
        params = {
            { {"string", "object"} },
            { {"number", 0} }
        },
    },
    {
        index = "set_angular_impulse",
        params = {
            { {"string", "object"} },
            { {"number", 0} }
        },
    },
    { comment = app.words[463] },
    {
        index = "set_gravity_scale",
        params = {
            { {"string", "object"} },
            { {"number", 1} }
        },
    },
    {
        index = "set_sensor",
        params = {
            { {"string", "object"} },
			'true'
        },
    },
    {
        index = "set_fixed_rotation",
        params = {
            { {"string", "object"} },
			'true'
        },
    },
    {
        index = "set_bullet",
        params = {
            { {"string", "object"} },
			'true'
        },
    },
    {
        index = "set_linear_damping",
        params = {
            { {"string", "object"} },
            { {"number", 0} }
        },
    },
    {
        index = "set_angular_damping",
        params = {
            { {"string", "object"} },
            { {"number", 0} }
        },
    },
    {
        index = "set_awake",
        params = {
            { {"string", "object"} }
        },
    },
    { comment = app.words[462] },
    {
        index = "set_pivot_joint",
        params = {
            { {"string", "joint"} },
            { {"string", "base_object"} },
            { {"string", "pivot_object"} },
            { {"number", 0} },
            { {"number", 0} }
        },
    },
    {
        index = "set_distance_joint",
        params = {
            { {"string", "joint"} },
            { {"string", "body_a"} },
            { {"string", "body_b"} },
            { {"number", 0} }, { {"number", 0} },
            { {"number", 0} }, { {"number", 0} }
        },
    },
    {
        index = "set_weld_joint",
        params = {
            { {"string", "joint"} },
            { {"string", "body_a"} },
            { {"string", "body_b"} },
            { {"number", 0} }, { {"number", 0} }
        },
    },
    {
        index = "set_piston_joint",
        params = {
            { {"string", "joint"} },
            { {"string", "base_object"} },
            { {"string", "piston_object"} },
            { {"number", 0} }, { {"number", 0} },
            { {"number", 100} }, { {"number", 0} }
        },
    },
    {
        index = "set_wheel_joint",
        params = {
            { {"string", "joint"} },
            { {"string", "base_object"} },
            { {"string", "wheel_object"} },
            { {"number", 0} }, { {"number", 0} },
            { {"number", 0} }, { {"number", 100} }
        },
    },
    {
        index = "set_touch_joint",
        params = {
            { {"string", "joint"} },
            { {"string", "object"} },
            { {"number", 0} }, { {"number", 0} }
        },
    },
    {
        index = "set_rope_joint",
        params = {
            { {"string", "joint"} },
            { {"string", "body_a"} },
            { {"string", "body_b"} },
            { {"number", 0} }, { {"number", 0} },
            { {"number", 0} }, { {"number", 0} }
        },
    },
    {
        index = "delete_joint",
        params = {
            { {"string", "joint"} }
        },
    },
    { comment = app.words[461] },
    {
        index = "set_pivot_motor",
        params = {
            { {"string", "joint"} },
            { {"function", "true"} },
            { {"number", 0} },
            { {"number", 1000} }
        },
    },
    {
        index = "set_pivot_limits",
        params = {
            { {"string", "joint"} },
            { {"function", "true"} },
            { {"number", -45} },
            { {"number", 45} }
        },
    },
    {
        index = "set_distance_settings",
        params = {
            { {"string", "joint"} },
            { {"number", 50} },
            { {"number", 1} },
            { {"number", 100} }
        },
    },
    {
        index = "set_touch_target",
        params = {
            { {"string", "joint"} },
            { {"number", 0} },
            { {"number", 0} }
        },
    },
    { comment = app.words[460] },
    {
        index = "set_bounce",
        params = {
            { {"string", "contact"} },
            { {"number", 0.5} }
        },
    },
    {
        index = "set_friction",
        params = {
            { {"string", "contact"} },
            { {"number", 0.3} }
        },
    },
    {
        index = "set_tangent_speed",
        params = {
            { {"string", "contact"} },
            { {"number", 0} }
        },
    },
    {
        index = "disable_collision",
        params = {
            { {"string", "contact"} }
        },
    },
    { comment = app.words[459] },
    {
        index = "set_world_gravity",
        params = {
            { {"number", 0} },
            { {"number", 9.8} }
        },
    },
    {
        index = "start_physics",
        params = {},
    },
    {
        index = "pause_physics",
        params = {},
    },
	{
        index = "resume_physics",
        params = {},
    },
    {
        index = "stop_physics",
        params = {},
    },
    {
        index = "show_physics_debug",
        params = {},
    },
    {
        index = "hide_physics_debug",
        params = {},
    },
},
	["control"] = {
	    {
		    comment = app.words[63]
		},
	    {
            index = "if_condition",
            params = { 
                { {"number", 1}, {"function", ">"}, {"number", 0} }
            }
        },
		{
            index = "else_condition_then",
            params = { 
                { {"number", 1}, {"function", ">"}, {"number", 0} }
            }
        },
		{
            index = "else_condition",
            params = { 
            }
        },
		{
		    comment = app.words[64],
		},
		{
            index = "repeat_loop",
            params = { 
                { {"number", 10} }
            }
        },
		{
            index = "timer",
            params = { 
                { {"number", 10} },
				{ {"number", 0.1} }
            }
        },
		{
		    comment = app.words[65],
		},
		{
            index = "while_loop",
            params = { 
                { {"number", 1}, {"function", ">"}, {"number", 0} }
            }
        },
		{
		    index = 'for_loop',
			params = {
			    { {"number", 1} },
				{ {"number", 10} },
				{ {"string", 'i'} },
			}
		},
		{
		    comment = app.words[458],
		},
		{
            index = "wait_until",
            params = { 
                { {"number", 1}, {"function", ">"}, {"number", 0} }
            }
        },
		{
            index = "wait",
            params = { 
                { {"number", "1"} }
            }
        },
		{
            index = "return",
            params = { 
                { {"function", "false"} }
            }
        },
	},
	["view"] = {
	    {
		    comment = app.words[66]
		},
	    {
            index = "set_width_height",
            params = { 
                { {"string", "object"} },
				{ {"number", 100} },
				{ {"number", 100} },
            }
        },
		{
            index = "set_width",
            params = { 
                { {"string", "object"} },
				{ {"number", 100} },
            }
        },
		{
            index = "set_height",
            params = { 
                { {"string", "object"} },
				{ {"number", 100} },
            }
        },
		{
            index = "set_alpha",
            params = { {{"string", "object"}}, {{"number", 1}} }
        },
        {
            index = "set_visible",
            params = { {{"string", "object"}}, {{"function", "true"}} }
        },
		{
		    comment = app.words[457]
		},
        {
            index = "set_fill_color",
            params = { {{"string", "object"}}, {{"number", 1}}, {{"number", 1}}, {{"number", 1}} }
        },
		{
            index = "set_hex_color",
            params = { {{"string", "object"}}, {{"string", "#FF0000"}}}
        },
		{
		    comment = app.words[67],
		},
		{
            index = "set_stroke_width",
            params = { {{"string", "object"}}, {{"number", 2}} }
        },
        {
            index = "set_stroke_color",
            params = { {{"string", "object"}}, {{"number", 255}}, {{"number", 255}}, {{"number", 255}} }
        },
		{
            index = "set_stroke_color_hex",
            params = { {{"string", "object"}}, {{"string", "#FF0000"}}}
        },
		{
		    comment = app.words[68],
			info = app.words[69]
		},
        {
            index = "set_anchor",
            params = { {{"string", "object"}}, {{"number", 0.5}}, {{"number", 0.5}} }
        },
		{
            index = "set_anchorX",
            params = { {{"string", "object"}}, {{"number", 0.5}}}
        },
		{
            index = "set_anchorY",
            params = { {{"string", "object"}}, {{"number", 0.5}}}
        },
		{
		    comment = app.words[70],
			info = app.words[71]
		},
		{
            index = "set_scale",
            params = { {{"string", "object"}}, {{"number", 1}}, {{"number", 1}} }
        },
		{
            index = "set_xScale",
            params = { {{"string", "object"}}, {{"number", 1}} }
        },
		{
            index = "set_yScale",
            params = { {{"string", "object"}}, {{"number", 1}} }
        },
		{comment = app.words[456]},
        { index = "tween", params = { {{"string","object"}}, "x", {{"number",100}}, {{"number",0.5}}, "linear" } },
		{
		    comment = app.words[220]
		},
		{
            index = "set_text",
            params = { {{"string", "object"}}, {{"number", 0}} }
        },
		{
            index = "set_font_size",
            params = { {{"string", "object"}}, {{"number", 24}} }
        },
	},
	["device"] = {
	    --{
        --    index = "enter_lua_code",
        --    params = { 
        --        { {"string", "local rect = display.newRect(display.contentCenterX, display.contentCenterY, 100, 100)"} }
        --    }
        --},
		{
            index = "console_log",
            params = { 
                { {"string", app.words[221]} }
            }
        },
		{
		    index = "input_alert",
			params = {
			    { {"string", app.words[455]} },
				{ {"string", "variable"} },
			}
		},
		{
		    index = "text_alert",
			params = {
			    { {"string", app.words[454]} },
			}
		},
				{
            index = "system_multitouch",
            params = { 
			    "true"
            }
        }, 
	},
	["data"] = {
	    {
		    comment = app.words[72],
		    info = app.words[73]
		}, 
	    {
            index = "set_global_var",
            params = { 
                { {"string", "variable"} },
				{ {"number", 0} },
            }
        }, 
	    {
            index = "set_local_var",
            params = { 
                { {"string", "variable"} },
				{ {"number", 0} },
            }
        }, 
		{
		    comment = app.words[74]
		}, 
		{
            index = "set_var",
            params = { 
                { {"string", "variable"} },
				{ {"number", 0} },
            }
        }, 
		{
            index = "change_var",
            params = { 
                { {"string", "variable"} },
				{ {"number", 1} },
            }
        }, 
		{
		    comment = app.words[75],
		    info = app.words[76]
		}, 
		{
            index = "set_key_var",
            params = { 
                { {"string", "variable"} },
				{ {"key", "key"} },
				{ {"string", "ponos"} },
            }
        }, 
	}, 
	['allcat'] = { 
	    { "event", GLOB_C_C_C_C_BLOCKCKCKCK.brown, app.words[78] }, 
		{ "control", GLOB_C_C_C_C_BLOCKCKCKCK.orange, app.words[79] }, 
		{ "object", GLOB_C_C_C_C_BLOCKCKCKCK.object, app.words[80] }, 
		{ "behavior", GLOB_C_C_C_C_BLOCKCKCKCK.object, app.words[452] }, 
		{ "move", GLOB_C_C_C_C_BLOCKCKCKCK.blue, app.words[81] }, 
		{ "physic", GLOB_C_C_C_C_BLOCKCKCKCK.phys_main, app.words[453] }, 
		{ "view", GLOB_C_C_C_C_BLOCKCKCKCK.green, app.words[82] },
		{ "data", GLOB_C_C_C_C_BLOCKCKCKCK.red, app.words[83]},
		{ "device", GLOB_C_C_C_C_BLOCKCKCKCK.gold, app.words[84]},
		--{ "funcs", GLOB_C_C_C_C_BLOCKCKCKCK.blue_dark, "свои блоки"},
	}
	
}

end

updateBlocksCategoryWords()

function open_blocks_category(callback, my_blocks)
    local group = display.newGroup()
    
    local isEnabled = true
    
    my_blocks = my_blocks or {}
    
    local loadingTimer = nil -- Таймер для загрузки блоков
    
    local function close_scene(newx)
        newx = newx or 0
		native.setKeyboardFocus(nil)
        transition.to(group, { time = 300, alpha = 0, x = newx, transition = easing.outQuad, onComplete = function() 
            group:removeSelf()
            group = nil 
        end} )
    end
    
    local bg = display.newRect(group, 0, 0, sw, sh)
    bg.anchorX = 0
    bg.anchorY = 0
    bg:setFillColor(app.color.mainBackgroundColor[1],app.color.mainBackgroundColor[2],app.color.mainBackgroundColor[3])
    
    local topbar = PonosUi.newTopBar(group, app.words[77], nil, function(e) end)
    local topbar2 = PonosUi.newTopBar2(group, "", { {id = "back", icon = "res/ui/back.png"} } )
    local bar2height = topbar2.barheight
    
    local categoriesGroup = PonosUi.newScrollView({
        x = sw/2,
        y = topbar.barheight + bar2height,
        width = sw,
        height = sh - (topbar.barheight + bar2height),
        horizontalScrollDisabled = true,
        verticalVel = getBottomNavHeight()
    })
    local blocksGroup = display.newGroup()
    
    group:insert(categoriesGroup)
    group:insert(blocksGroup)
    
    local currentScrollView = nil
    local currentSearchField = nil 
    local currentSearchGroup = nil
    local isInsideCategory = false

    local function onBack()
        if isInsideCategory then
            isInsideCategory = false
            
            if loadingTimer then
                timer.cancel(loadingTimer)
                loadingTimer = nil
            end
            
            blocksGroup.isVisible = false
            
            if currentSearchField then
                native.setKeyboardFocus(nil)
                currentSearchField:removeSelf()
                currentSearchField = nil
            end
            
            if currentSearchGroup then
                currentSearchGroup:removeSelf()
                currentSearchGroup = nil
            end
            
            if currentScrollView then
                local container = currentScrollView.content or currentScrollView
                while container.numChildren > 0 do
                    container:remove(1)
                end
                if currentScrollView.parent then
                    currentScrollView.parent:remove(currentScrollView)
                end
                currentScrollView = nil
            end
            
            categoriesGroup.isVisible = true
            
        else
            if callback then callback(nil) end
            close_scene(sw/2)
        end
    end

    topbar2:removeSelf()
    topbar2 = PonosUi.newTopBar2(group, "", { {id = "back", icon = "res/ui/back.png", callback = onBack} } )

    local categories = {}
    table.insert(categories, {"search_all", {0.2, 0.6, 0.8}, "Все блоки", "res/ui/search.png"})
    if blocks_category.allcat then
        for i = 1, #blocks_category.allcat do
            table.insert(categories, blocks_category.allcat[i])
        end
    end
    
    local function open_cat(key)
        isInsideCategory = true
        
        categoriesGroup.isVisible = false
        blocksGroup.isVisible = true
        
        local panel = {height = 0}
        local category = {}
        
        local scroll_y = topbar.barheight + bar2height
        local scroll_h = sh - (topbar.barheight + bar2height)

        if key == "search_all" then
            for k, v in pairs(blocks_category) do
                if type(v) == "table" and k ~= "allcat" then
                    for i = 1, #v do
                        if not v[i].comment then
                            table.insert(category, v[i])
                        end
                    end
                end
            end
            for w = 1, #my_blocks do
                table.insert(category, my_blocks[w]["block"])
            end
            
            currentSearchGroup = display.newGroup()
            blocksGroup:insert(currentSearchGroup)
            
            local fieldWidth = sw-app.pad*2
            local fieldHeight = 75
            currentSearchGroup.x = sw/2
            currentSearchGroup.y = scroll_y+fieldHeight/2+app.pad
            
            local inputRect = display.newRoundedRect(currentSearchGroup, 0, 0, fieldWidth, fieldHeight, 8)
            inputRect.alpha = 0.4
            inputRect:setFillColor(0, 0, 0)
            
            local inputLine = display.newRect(currentSearchGroup, 0, inputRect.height/2 - app.pad/2, inputRect.width - app.pad, 4)
            
            local iconSize = 30
            local searchIcon = display.newImageRect(currentSearchGroup, "res/ui/search.png", iconSize, iconSize)
            searchIcon.x = -fieldWidth/2 + app.pad + iconSize/2
            searchIcon.y = 0
            
            local textWidth = fieldWidth - app.pad*3 - iconSize
            local textX = searchIcon.x + iconSize/2 + app.pad + textWidth/2
            
            currentSearchField = native.newTextField(textX, 0, textWidth, fieldHeight - app.pad)
            currentSearchField.placeholder = app.words[494]
            currentSearchField.isEditable = true
            currentSearchField.hasBackground = false
            currentSearchField.size = 25
			currentSearchGroup:insert(currentSearchField)
            
            if utils and (utils.isSim or utils.isWin) then
                currentSearchField:setTextColor(0,0,0)
            else
                currentSearchField:setTextColor(1,1,1)
            end
            
            scroll_y = scroll_y+fieldHeight+app.pad*2
            scroll_h = scroll_h-fieldHeight-app.pad*2

        elseif key == "funcs" then
            for w = 1, #my_blocks do
                table.insert(category, my_blocks[w]["block"])
            end
            panel = PonosUi.newBottomBar(function(index)
                if index == "add_block" then
                    new_input_alert({header = "название блока", description = "вы не сможете изменить его потом"}, function(e)
                        local dialog = new_dialog({header = "Отлично!", description = "добавьте параметры для нового блока.", buttons = { {text = "создать блок", callback = function(dat) end} } })
                        local cowid = dialog.contentWidth
                        
                        local block_i = "block_"..math.random(1000000, 9999999)
                        local block_dat = { index = block_i, params = {  } }
                        
                        all_blocks[block_i] = { type = "block", color = GLOB_C_C_C_C_BLOCKCKCKCK.blue_dark, params = { {"text", e} }}
                        
                        local blockObj = create_block(block_dat, cowid)
                        dialog:insert(blockObj)
                        blockObj.x = -cowid/2
                        blockObj.y = -blockObj.height+30
                        
                        local plusParam = PonosUi.newButton( function() end, {x = -cowid/2+app.pad, y = 30+app.pad, width = 50, height = 50, rounded = 20, icon = {path = "res/ui/plus.png", size = 40} }, dialog )
                        plusParam.anchorX = 0
                        plusParam.anchorY = 0
                        dialog:recalc()
                    end, true)
                end
            end,{
                {text = "", icon = "res/ui/plus.png", index = "add_block"}
            }, group)
            blocksGroup:insert(panel)
            scroll_h = scroll_h - panel.height
        else
            category = blocks_category[key]
            if panel.height then scroll_h = scroll_h - panel.height end
        end
        
        local scrollview = PonosUi.newScrollView({
            x = sw/2,
            y = scroll_y,
            width = sw,
            height = scroll_h,
            horizontalScrollDisabled = true,
            verticalVel = getBottomNavHeight()+app.pad
        })
        currentScrollView = scrollview
        blocksGroup:insert(scrollview)
        
        if key == "search_all" then
		    local old_back = special_back_fun
			special_back_fun = function() end
            local loadingGroup = display.newGroup()
            local loadingBg = display.newRect(loadingGroup, sw/2, sh/2, sw, sh)
            loadingBg.isVisible = false
            loadingBg.isHitTestable = true
            loadingBg:addEventListener("touch", function() return true end)

            local loading = PonosUi.newLoader(loadingGroup, sw/2, sh/2)

            local loadingText = display.newText({
                parent = loadingGroup,
                text = string.format("Загрузка блоков... %d%%", 0),
                x = sw/2, y = sh/2+60,
                font = app.font,
                fontSize = app.fontsize1,
                align = "center"
            })
            loadingText:setFillColor(unpack(app.color.standartTextColor))
            group:insert(loadingGroup)

            local search_blocks_cache = {}
            local currentIndex = 1
            local batchSize = 10
            
            local function applySearchFilter(filter_text)
                local currenty = 36
                for i = 1, #search_blocks_cache do
                    local item = search_blocks_cache[i]
                    local blockdata = item.data
                    
                    local show_block = true
                    if filter_text and filter_text ~= "" then
                        show_block = false
                        local search_str = ""
                        
                        if all_blocks[blockdata.index] and all_blocks[blockdata.index].params then
                            for p = 1, #all_blocks[blockdata.index].params do
                                if all_blocks[blockdata.index].params[p][1] == "text" then
                                    search_str = search_str .. " " .. tostring(all_blocks[blockdata.index].params[p][2])
                                end
                            end
                        end
                        if string.find(string.lower(search_str), string.lower(filter_text), 1, true) then
                            show_block = true
                        end
                    end
                    
                    if show_block then
                        item.block.isVisible = true
                        item.block.y = currenty
                        currenty = currenty + item.block.height
                        
                        if item.blockEnd then
                            item.blockEnd.isVisible = true
                            item.blockEnd.y = currenty - 4
                            currenty = currenty + item.blockEnd.height
                        end
                        currenty = currenty + app.pad
                    else
                        item.block.isVisible = false
                        if item.blockEnd then item.blockEnd.isVisible = false end
                    end
                end
                
                scrollview:setScrollHeight(currenty)
                scrollview:upd(true)
            end
            
            currentSearchField:addEventListener("userInput", function(event)
                if event.phase == "editing" then
                    if loadingGroup == nil then
                        applySearchFilter(event.text)
                    end
                elseif event.phase == "submitted" or event.phase == "ended" then
                    native.setKeyboardFocus(nil)
                end
            end)
            local function generateNextBatch()
                local limit = math.min(currentIndex + batchSize - 1, #category)
                
                for i = currentIndex, limit do
                    local blockdata = category[i]
                    
                    local block = create_block(blockdata)
                    block.anchorY = 0 
                    block.isVisible = false
                    scrollview:insert(block)
                    
                    local blockEnd = nil
                    if all_blocks[blockdata.index].special == "cycle" then
                        local blocksObjects = special_blocks[blockdata.index]
                        blockEnd = create_block(special_blocks_struct[blocksObjects[#blocksObjects]])
                        blockEnd.anchorY = 0 
                        blockEnd.isVisible = false
                        scrollview:insert(blockEnd)
                    end
                    
                    block:addEventListener("touch", function(event)
                        if event.phase == "moved" then
                            if math.abs(event.xDelta+event.yDelta)>50 then scrollview:takeFocus(event) return false end return true
                        elseif event.phase == "ended" and isEnabled then
                            isEnabled = false
                            if currentSearchField then native.setKeyboardFocus(nil) end
                            callback(deep_copy(blockdata))
                            close_scene()
                        end
                    end)
                    
                    table.insert(search_blocks_cache, {
                        data = blockdata,
                        block = block,
                        blockEnd = blockEnd
                    })
                end
                
                currentIndex = limit + 1
                
                local pct = math.floor(((currentIndex - 1) / #category) * 100)
                loadingText.text = string.format("Загрузка блоков... %d%%", pct)
                
                if currentIndex <= #category then
                    loadingTimer = timer.performWithDelay(1, generateNextBatch)
                else
                    loadingTimer = nil
                    loadingGroup:removeSelf()
                    loadingGroup = nil
					special_back_fun = old_back
                    applySearchFilter("")
                end
            end
            if #category > 0 then
                loadingTimer = timer.performWithDelay(1, generateNextBatch)
            else
                loadingGroup:removeSelf()
                loadingGroup = nil
            end
        else
            local function renderCategoryBlocks()
                local container = scrollview.content or scrollview
                while container.numChildren > 0 do container:remove(1) end
                
                local currenty = 36
                if category then
                    for i = 1, #category do
                        local blockdata = category[i]
                        
                        if not blockdata["comment"] then
                            local block = create_block(blockdata)
                            block.anchorY = 0 
                            block.y = currenty
                            
                            currenty = currenty + block.height
                            
                            if all_blocks[blockdata.index].special == "cycle" then
                                local blocksObjects = special_blocks[blockdata.index]
                                local blockEnd = create_block(special_blocks_struct[blocksObjects[#blocksObjects]])
                                blockEnd.anchorY = 0 
                                blockEnd.y = currenty-4
                                currenty = currenty + blockEnd.height
                                scrollview:insert(blockEnd)
                            end
                            
                            currenty = currenty + app.pad
                            
                            block:addEventListener("touch", function(event)
                                if event.phase == "moved" then
                                    if math.abs(event.xDelta+event.yDelta)>50 then scrollview:takeFocus(event) return false end return true
                                elseif event.phase == "ended" and isEnabled then
                                    isEnabled = false
                                    callback(deep_copy(blockdata))
                                    close_scene()
                                end
                            end)
                            
                            scrollview:insert(block)
                        else
                            local up_pad = app.pad/2
                            if currenty == 36 then
                                up_pad = -currenty/4+app.pad*2
                            end
                            local icon
                            if blockdata.info then
                                icon = {path = "res/ui/cap.png", position = "right"}
                            end
                            local btn = PonosUi.newButton(function(e) 
                                if blockdata.info and e.phase == "ended" then
                                    new_dialog({header = blockdata.comment, description = blockdata.info})
                                elseif e.phase == 'moved' then 
                                    if math.abs(e.yDelta+e.xDelta)>30 then scrollview:takeFocus(e) end
                                    return true
                                end
                            end, {
                                x = sw/2,
                                y = currenty+up_pad+2,
                                text = blockdata.comment,
                                fontSize = app.fontsize1,
                                width = sw-app.pad*2,
                                height = 60,
                                text_align = "left",
                                icon = icon,
                                rounded = 30,
                            }, scrollview)
                            currenty = currenty+btn.height+up_pad+app.pad*2
                        end
                    end
                end
                
                if scrollview.invalidate then scrollview:invalidate() end
                if scrollview.update then scrollview:update() end
            end
            
            renderCategoryBlocks()
        end
    end
    
    local function buildCategoriesList()
        for i = 1, #categories do
            local catData = categories[i]
            
            local catBg = display.newImageRect("res/block/fill.png", sw, 100)
            catBg.anchorX = 0
            catBg.anchorY = 0
            catBg:setFillColor(catData[2][1], catData[2][2], catData[2][3])
            catBg.y = (i-1)*100
            categoriesGroup:insert(catBg)
            
            local catTitle = display.newText({
                x = app.pad*2,
                y = catBg.y + 50,
                text = catData[3],
                width = sw - app.pad*4,
                fontSize = app.fontsize2,
                font = app.font
            })
            categoriesGroup:insert(catTitle)
            catTitle.anchorX = 0
            
            local line = display.newRect( sw/2, catBg.y + 100, sw, 4)
            line.anchorY = 1
            line:setFillColor(catData[2][1]/6, catData[2][2]/6, catData[2][3]/6)
            categoriesGroup:insert(line)
            
            local btn = PonosUi.newButton(function(event)
                if event.phase == "moved" then
                    local delta = math.abs(event.x - event.xStart) + math.abs(event.y - event.yStart)
                    if (delta > app.touchDelta) then 
                        display.getCurrentStage():setFocus(event.target, nil)
                        event.target.isFocus = false
                        categoriesGroup:takeFocus(event)
                    end
                end
                if event.phase == "ended" then
                    open_cat(catData[1])
                end 
            end, {
                x = sw/2,
                y = catBg.y + 50,
                width = sw,
                height = 100,
                text = "",
                alpha = 0.01
            }, categoriesGroup)
        end
    end
    
    special_back_fun = function(event)
        onBack()
    end

    buildCategoriesList()
end