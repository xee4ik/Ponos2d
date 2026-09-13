-- generators.lua

local generators = {
    ["system_multitouch"] = function(p)
        return string.format([[
        if (%s) then system.activate('multitouch') else system.deactivate('multitouch') end]], p[1], p[3], p[4], p[5], p[6], p[2], p[1], p[1])
    end,
    ["new_rounded_rect"] = function(p)
        return string.format([[
		local name = %s
        objects[name] = display.newRoundedRect(%s, %s, %s, %s, %s)
        objects[name].myName = name
		gameScene:insert(objects[name])]], p[1], p[3], p[4], p[5], p[6], p[2])
    end,
	
	['set_object_var'] = function(p)
	    return string.format([[
		if objects[%s].variables == nil then objects[%s].variables = {} end
		objects[%s].variables[%s] = %s
		]], p[1], p[1], p[1], p[2], p[3])
	end,

    ["new_circle"] = function(p)
        return string.format([[
        objects[%s] = display.newCircle(%s, %s, %s)
        objects[%s].myName = %s
		gameScene:insert(objects[%s])]], p[1], p[2], p[3], p[4], p[1], p[1], p[1])
    end,

    ["new_text"] = function(p)
        return string.format([[
        objects[%s] = display.newText(%s, %s, %s, native.systemFont, %s)
        objects[%s].myName = %s
        objects[%s]:setFillColor(1, 1, 1)
		gameScene:insert(objects[%s])]], p[1], p[2], p[3], p[4], p[5], p[1], p[1], p[1], p[1])
    end,

    ["new_image"] = function(p)
        return string.format([[
        objects[%s] = display.newImage(RES_PATH .. %s, BASE_DIR)
        if objects[%s] then objects[%s].myName = %s end
		gameScene:insert(objects[%s])]], p[1], p[2], p[1], p[1], p[1], p[1])
    end,

    ["new_group"] = function(p)
        return string.format([[
        objects[%s] = display.newGroup()
        objects[%s].myName = %s
		gameScene:insert(objects[%s])]], p[1], p[1], p[1], p[1])
    end,
	
    ["new_container"] = function(p)
        return string.format([[
        objects[%s] = display.newContainer(%s, %s)
        objects[%s].myName = %s
		gameScene:insert(objects[%s])]], p[1], p[2], p[3], p[1], p[1], p[1])
    end,

    ["insert_to_group"] = function(p)
        return string.format([[
        if objects[%s] and objects[%s] then
            objects[%s]:insert(objects[%s])
        end]], p[2], p[1], p[2], p[1])
    end,
	
	["remove_object"] = function(p)
        return string.format([[
        if objects[%s] then
            display.remove(objects[%s])
        end]], p[1], p[1])
    end,

    ["button_behavior"] = function(p)
        return string.format([[
            ponosBehaviors.touchAnimation(objects[%s], %s)
        ]], p[1], p[2])
    end,
	
    ["set_position"] = function(p)
        return string.format([[
        if objects[%s] then
            objects[%s].x = %s
            objects[%s].y = %s
        end]], p[1], p[1], p[2], p[1], p[3])
    end,

    ["set_x"] = function(p)
        return string.format([[if objects[%s] then objects[%s].x = %s end]], p[1], p[1], p[2])
    end,

    ["set_y"] = function(p)
        return string.format([[if objects[%s] then objects[%s].y = %s end]], p[1], p[1], p[2])
    end,

    ["change_x"] = function(p)
        return string.format([[if objects[%s] then objects[%s].x = objects[%s].x + (%s) end]], p[1], p[1], p[1], p[2])
    end,

    ["change_y"] = function(p)
        return string.format([[if objects[%s] then objects[%s].y = objects[%s].y + (%s) end]], p[1], p[1], p[1], p[2])
    end,
	["camera_position"] = function(p)
        return string.format([[gameScene.x, gameScene.y = %s, %s]], p[1], p[2])
    end,
	["camera_position_x"] = function(p)
        return string.format([[gameScene.x = %s]], p[1])
    end,
	["camera_position_y"] = function(p)
        return string.format([[gameScene.y = %s]], p[1])
    end,

    ["set_size"] = function(p)
        return string.format([[
        if objects[%s] then
            objects[%s].xScale = (%s) / 100
            objects[%s].yScale = (%s) / 100
        end]], p[2], p[2], p[1], p[2], p[1])
    end,

    ["set_width_height"] = function(p)
        return string.format([[
        if objects[%s] then
            objects[%s].width = %s
            objects[%s].height = %s
        end]], p[1], p[1], p[2], p[1], p[3])
    end,

    ["set_width"] = function(p)
        return string.format([[if objects[%s] then objects[%s].width = %s end]], p[1], p[1], p[2])
    end,

    ["set_height"] = function(p)
        return string.format([[if objects[%s] then objects[%s].height = %s end]], p[1], p[1], p[2])
    end,

    ["set_rotation"] = function(p)
        return string.format([[if objects[%s] then objects[%s].rotation = %s end]], p[1], p[1], p[2])
    end,

    ["rotate_right"] = function(p)
        return string.format([[if objects[%s] then objects[%s].rotation = objects[%s].rotation + (%s) end]], p[1], p[1], p[1], p[2])
    end,

    ["set_alpha"] = function(p)
        return string.format([[if objects[%s] then objects[%s].alpha = %s end]], p[1], p[1], p[2])
    end,
	
["tween"] = function(p)
    local obj = p[1]
    local prop = p[2]
    local val = p[3]
    local dur = p[4]
    local ease = p[5] or "linear"
    return string.format([[
if objects[%s] then
    ponosfun.threader(function()
        transition.to(objects[%s], {
            time = (%s) * 1000,
            %s = %s,
            transition = easing.%s,
            onComplete = function()
                ponosfun.wait(0)
            end
        })
        ponosfun.wait(%s)
    end)
end]], obj, obj, dur, prop, val, ease, dur)
end,

    ["set_visible"] = function(p)
        return string.format([[if objects[%s] then objects[%s].isVisible = %s end]], p[1], p[1], p[2])
    end,

    ["set_fill_color"] = function(p)
        return string.format([[if objects[%s] then objects[%s]:setFillColor(%s/255, %s/255, %s/255) end]], p[1], p[1], p[2], p[3], p[4])
    end,
	
	["set_hex_color"] = function(p)
        return string.format([[if objects[%s] then local rgb = ponosfun.hexToRgb(%s); objects[%s]:setFillColor(rgb[1], rgb[2], rgb[3]) end]], p[1], p[2], p[1])
    end,
	
    ["set_stroke_color"] = function(p)
        return string.format([[if objects[%s] then objects[%s]:setStrokeColor(%s/255, %s/255, %s/255) end]], p[1], p[1], p[2], p[3], p[4])
    end,
	
	["set_stroke_color_hex"] = function(p)
        return string.format([[if objects[%s] then local rgb = ponosfun.hexToRgb(%s); objects[%s]:setStrokeColor(rgb[1], rgb[2], rgb[3]) end]], p[1], p[2], p[1])
    end,

    ["set_stroke_width"] = function(p)
        return string.format([[if objects[%s] then objects[%s].strokeWidth = %s end]], p[1], p[1], p[2])
    end,

    ["set_anchor"] = function(p)
        return string.format([[
        if objects[%s] then
            objects[%s].anchorX = %s
            objects[%s].anchorY = %s
        end]], p[1], p[1], p[2], p[1], p[3])
    end,

    ["set_anchorX"] = function(p)
        return string.format([[
        if objects[%s] then
            objects[%s].anchorX = %s
        end]], p[1], p[1], p[2])
    end,

    ["set_anchorY"] = function(p)
        return string.format([[
        if objects[%s] then
            objects[%s].anchorY = %s
        end]], p[1], p[1], p[2])
    end,

    ["set_scale"] = function(p)
        return string.format([[
        if objects[%s] then
            objects[%s].xScale = %s
            objects[%s].yScale = %s
        end]], p[1], p[1], p[2], p[1], p[3])
    end,

    ["set_xScale"] = function(p)
        return string.format([[if objects[%s] then objects[%s].xScale = %s end]], p[1], p[1], p[2])
    end,

    ["set_yScale"] = function(p)
        return string.format([[if objects[%s] then objects[%s].yScale = %s end]], p[1], p[1], p[2])
    end,

    ["set_text"] = function(p)
        return string.format([[if objects[%s] then objects[%s].text = tostring(%s) end]], p[1], p[1], p[2])
    end,

    ["set_font_size"] = function(p)
        return string.format([[if objects[%s] then objects[%s].size = %s end]], p[1], p[1], p[2])
    end,

    ["add_touch_listener"] = function(p)
        return string.format([[
        if objects[%s] then
            local _targetObj = objects[%s]
            if _targetObj._ponos_touch_listener then
                _targetObj:removeEventListener("touch", _targetObj._ponos_touch_listener)
            end
            _targetObj._ponos_touch_listener = function(event)
                ponosfun.threader(function()
                    local current_scope = ponosfun.createScope(local_vars)
                    local e = event
                    e.target = e.target.myName
                    rawset(current_scope, %s, e)
                    local local_vars = current_scope
                    
                    local parent_ponosfun = ponosfun
                    local ponosfun = setmetatable({
                        get_var = function(name)
                            local val = local_vars[name]
                            if val == nil then val = global_vars[name] end
                            if val == nil then ponosfun.print("переменная '"..name.."' несуществует") return "empty" end
                            return val
                        end
                    }, { __index = parent_ponosfun })
        ]], p[1], p[1], p[2])
    end,

    ["end_listener"] = function(p)
        return [[
                end)
            end
            _targetObj:addEventListener("touch", _targetObj._ponos_touch_listener)
        end]]
    end,

    ["remove_listener"] = function(p)
        return string.format([[
        if objects[%s] and objects[%s]._ponos_touch_listener then
            objects[%s]:removeEventListener(%s, objects[%s]._ponos_touch_listener)
            objects[%s]._ponos_touch_listener = nil
        end]], p[1], p[1], p[1], p[2], p[1], p[1])
    end,
	
	["add_object_event_listener"] = function(p)
        return string.format([[objects[%s]:addEventListener(%s,function(event) 
		event.target = event.target.myName
        if type(local_vars[%s]) == "function" then
            ponosfun.threader(function() local_vars[%s](event) end)
        elseif type(global_vars[%s]) == "function" then
            ponosfun.threader(function() global_vars[%s](event) end)
        end
		end)]], p[2], p[1], p[3], p[3], p[3], p[3])
    end,

    ["set_focus"] = function(p)
        return string.format([[display.getCurrentStage():setFocus( objects[ %s ] )]], p[1])
    end,

    ["remove_focus"] = function(p)
        return [[display.getCurrentStage():setFocus( nil )]]
    end,

    ["if_condition"] = function(p)
        return string.format([[if ( %s ) then]], p[1])
    end,

    ["else_condition_then"] = function(p)
        return string.format([[elseif ( %s ) then]], p[1])
    end,

    ["else_condition"] = function(p)
        return [[else]]
    end,

    ["end_if"] = function(p)
        return [[end]]
    end,

    ["repeat_loop"] = function(p)
    local count = p[1]
    return string.format([[
do
    local _loopTotal = %s
    local _loopIdx = 0
    local _loopFinished = false
    
    ponosfun.threader(function()
        while _loopIdx < _loopTotal do
            _loopIdx = _loopIdx + 1
]], count)
end,

["end_loop"] = function(p)
    return [[
            ponosfun.wait(0)
        end
        _loopFinished = true
    end)
    
    -- Блокируем ТЕКУЩИЙ поток до завершения цикла
    while not _loopFinished do
        ponosfun.wait(0)
    end
end]]
end,

    ['for_loop'] = function(p)
	    return string.format([[
		    for i = %s, %s do
			    ponosfun.threader(function()
                    local current_scope = ponosfun.createScope(local_vars)
                    rawset(current_scope, %s, i)
                    local local_vars = current_scope
                    local parent_ponosfun = ponosfun
                    local ponosfun = setmetatable({
                        get_var = function(name)
                            local val = local_vars[name]
                            if val == nil then val = global_vars[name] end
                            if val == nil then ponosfun.print("переменная '"..name.."' несуществует") return "empty" end
                            return val
                        end
                    }, { __index = parent_ponosfun })
		]], p[1], p[2], p[3])
	end, 
	
	['end_for'] = function()
	    return 'end) end'
	end,
	
    ["while_loop"] = function(p)
        return string.format([[while not (%s) do]], p[1])
    end,

    ["end_while"] = function(p)
        return [[end]]
    end,

    ["timer"] = function(p)
        return string.format([[
        ponosfun.timer((%s) * 1000, %s, function()
            ponosfun.threader(function()
                local current_scope = ponosfun.createScope(local_vars)
                local local_vars = current_scope
                
                local parent_ponosfun = ponosfun
                local ponosfun = setmetatable({
                    get_var = function(name)
                        local val = local_vars[name]
                        if val == nil then val = global_vars[name] end
                        if val == nil then ponosfun.print("переменная '"..name.."' несуществует") return "empty" end
                        return val
                    end
                }, { __index = parent_ponosfun })
        ]], p[2], p[1])
    end,

    ["end_timer"] = function(p)
        return [[
            end)
        end)]]
    end,

    ["wait"] = function(p)
        return string.format([[ponosfun.wait(%s)]], p[1])
    end,

    ["wait_until"] = function(p)
        return string.format([[
            ponosfun.threader(function()
            while (%s) do
                ponosfun.wait(0.01)
            end
            local current_scope = ponosfun.createScope(local_vars)
             local local_vars = current_scope
                
             local parent_ponosfun = ponosfun
                local ponosfun = setmetatable({
                    get_var = function(name)
                        local val = local_vars[name]
                        if val == nil then val = global_vars[name] end
                        if val == nil then ponosfun.print("переменная '"..name.."' несуществует") return "empty" end
                        return val
                    end
                }, { __index = parent_ponosfun })
        ]], p[1])
    end,

    ["end_wait"] = function(p)
        return [[
        end)]]
    end,
	
    ["global_function"] = function(p)
        return string.format([[global_vars[%s] = function(event)
                local current_scope = ponosfun.createScope(local_vars)
                rawset(current_scope, %s, event)
                local local_vars = current_scope
                
                local parent_ponosfun = ponosfun
                local ponosfun = setmetatable({
                    get_var = function(name)
                        local val = local_vars[name]
                        if val == nil then val = global_vars[name] end
                        if val == nil then ponosfun.print("переменная '"..name.."' несуществует") return "empty" end
                        return val
                    end
                }, { __index = parent_ponosfun })
        ]], p[1], p[2])
    end,
    ["local_function"] = function(p)
        return string.format([[local_vars[%s] = function(event)
                local current_scope = ponosfun.createScope(local_vars)
                rawset(current_scope, %s, event)
                local local_vars = current_scope
                
                local parent_ponosfun = ponosfun
                local ponosfun = setmetatable({
                    get_var = function(name)
                        local val = local_vars[name]
                        if val == nil then val = global_vars[name] end
                        if val == nil then ponosfun.print("переменная '"..name.."' несуществует") return "empty" end
                        return val
                    end
                }, { __index = parent_ponosfun })
        ]], p[1], p[2])
    end,

    ["end_func"] = function(p)
        return [[end]]
    end,

    ["call_func"] = function(p)
        return string.format([[
        if type(local_vars[%s]) == "function" then
            ponosfun.threader(function() local_vars[%s](nil) end)
        elseif type(global_vars[%s]) == "function" then
            ponosfun.threader(function() global_vars[%s](nil) end)
        end]], p[1], p[1], p[1], p[1])
    end,

    ["call_func_params"] = function(p)
        return string.format([[
        if type(local_vars[%s]) == "function" then
            ponosfun.threader(function() local_vars[%s](%s) end)
        elseif type(global_vars[%s]) == "function" then
            ponosfun.threader(function() global_vars[%s](%s) end)
        end]], p[1], p[1], p[2], p[1], p[1], p[2])
    end,

    ["input_alert"] = function(p)
        return string.format([[
        ponosfun.input_alert(%s, function(_val)
            if local_vars[%s] ~= nil then
                local_vars[%s] = _val
            elseif global_vars[%s] ~= nil then
                global_vars[%s] = _val
            else
                rawset(local_vars, %s, _val)
            end
        end)]], p[1], p[2], p[2], p[2], p[2], p[2])
    end,

    ["text_alert"] = function(p)
        return string.format([[
        ponosfun.text_alert(%s)]], p[1])
    end,

    ["comment"] = function(p)
        return string.format([[-- %s]], p[1])
    end,

    ["enter_lua_code"] = function(p)
        return string.format("loadstring(%s)", p[1])
    end,
	["console_log"] = function(p)
        return string.format("ponosfun.print(%s)", p[1])
    end,

    ["set_global_var"] = function(p)
        return string.format([[global_vars[%s] = %s]], p[1], p[2] or "nil")
    end,

    ["set_local_var"] = function(p)
        return string.format([[rawset(local_vars, %s, %s)]], p[1], p[2] or "nil")
    end,

    ["set_var"] = function(p)
        return string.format([[
        if local_vars[%s] ~= nil then 
            local_vars[%s] = (%s) 
        else 
            global_vars[%s] = (%s) 
        end]], p[1], p[1], p[2] or "nil", p[1], p[2] or "nil")
    end,

    ["change_var"] = function(p)
        return string.format([[
        if local_vars[%s] ~= nil then 
            local_vars[%s] = local_vars[%s] + (%s) 
        else 
            global_vars[%s] = (global_vars[%s] or 0) + (%s) 
        end]], p[1], p[1], p[1], p[2], p[1], p[1], p[2])
    end,

    ["set_key_var"] = function(p)
        return string.format([[
        local _t = ponosfun.get_var(%s)
        if type(_t) == "table" then
            _t[%s] = %s
        end]], p[1], p[2], p[3])
    end,

-- ФИЗИКА
["add_body"] = function(p)
    return string.format([[
if objects[%s] then
    pcall(function() physics.removeBody(objects[%s]) end)
    local _params = { density=%s, bounce=%s, friction=%s }
    physics.addBody(objects[%s], %s, _params)
    objects[%s].gravityScale = %s
    objects[%s]._ponos_body_type = %s
    objects[%s]._density = %s
    objects[%s]._bounce = %s
    objects[%s]._friction = %s
    objects[%s]._gravity = %s
end]], 
    p[1], p[1], p[3], p[4], p[5], 
    p[1], p[2], p[1], p[6], p[1], 
    p[2], p[1], p[3], p[1], p[4], 
    p[1], p[5], p[1], p[6]
)
end,

["remove_body"] = function(p)
    return string.format([[
if objects[%s] and objects[%s]._ponos_body_type then
    pcall(function() physics.removeBody(objects[%s]) end)
    objects[%s]._ponos_body_type = nil
end]], p[1], p[1], p[1], p[1])
end,

["set_body_type"] = function(p)
    return string.format([[
if objects[%s] and objects[%s].bodyType then
    objects[%s].bodyType = %s
    objects[%s]._ponos_body_type = %s
end]], p[1], p[1], p[1], p[2], p[1], p[2])
end,

["upd_hitbox"] = function(p)
    return string.format([[
if objects[%s] and objects[%s]._ponos_body_type then
    local _type = objects[%s]._ponos_body_type
    local _density = objects[%s]._density or 1
    local _bounce = objects[%s]._bounce or 0
    local _friction = objects[%s]._friction or 0
    local _gravity = objects[%s]._gravity or 1
    local _hitbox = objects[%s]._hitbox
    pcall(function() physics.removeBody(objects[%s]) end)
    local _params = { density=_density, bounce=_bounce, friction=_friction }
    if _hitbox then
        if _hitbox.type == "circle" then
            _params.radius = _hitbox.radius
        elseif _hitbox.type == "box" then
            local hw = (_hitbox.width or 100) / 2
            local hh = (_hitbox.height or 100) / 2
            local ox = _hitbox.offsetX or 0
            local oy = _hitbox.offsetY or 0
            _params.shape = { -hw+ox, -hh+oy, hw+ox, -hh+oy, hw+ox, hh+oy, -hw+ox, hh+oy }
        elseif _hitbox.type == "polygon" then
            _params.shape = _hitbox.shape
        end
    end
    physics.addBody(objects[%s], _type, _params)
    objects[%s].gravityScale = _gravity
end]], p[1], p[1], p[1], p[1], p[1], p[1], p[1], p[1], p[1], p[1], p[1], p[1], p[1], p[1])
end,

["set_hitbox_box"] = function(p)
    return string.format([[
if objects[%s] then
    objects[%s]._hitbox = { type="box", width=%s, height=%s, offsetX=0, offsetY=0, rotation=0 }
end]], p[1], p[1], p[2], p[3])
end,

["set_hitbox_circle"] = function(p)
    return string.format([[
if objects[%s] then objects[%s]._hitbox = { type="circle", radius=%s } end
]], p[1], p[1], p[2])
end,

["set_hitbox_polygon"] = function(p)
    return string.format([[
if objects[%s] then objects[%s]._hitbox = { type="polygon", shape=json.decode(%s) } end
]], p[1], p[1], p[2])
end,

["set_linear_velocity"] = function(p)
    return string.format([[
if objects[%s] and objects[%s].setLinearVelocity then
    objects[%s]:setLinearVelocity(%s, %s)
end]], p[1], p[1], p[1], p[2], p[3])
end,

["set_linear_velocity_x"] = function(p)
    return string.format([[
if objects[%s] and objects[%s].setLinearVelocity then
    local _, sy = objects[%s]:getLinearVelocity()
    objects[%s]:setLinearVelocity(%s, sy)
end]], p[1], p[1], p[1], p[1], p[2])
end,

["set_linear_velocity_y"] = function(p)
    return string.format([[
if objects[%s] and objects[%s].setLinearVelocity then
    local sx, _ = objects[%s]:getLinearVelocity()
    objects[%s]:setLinearVelocity(sx, %s)
end]], p[1], p[1], p[1], p[1], p[2])
end,

["apply_force"] = function(p)
    return string.format([[
if objects[%s] and objects[%s].applyForce then
    objects[%s]:applyForce(%s, %s, objects[%s].x + (%s), objects[%s].y + (%s))
end]], p[1], p[1], p[1], p[2], p[3], p[1], p[4], p[1], p[5])
end,

["apply_impulse"] = function(p)
    return string.format([[
if objects[%s] and objects[%s].applyLinearImpulse then
    objects[%s]:applyLinearImpulse(%s, %s, objects[%s].x + (%s), objects[%s].y + (%s))
end]], p[1], p[1], p[1], p[2], p[3], p[1], p[4], p[1], p[5])
end,

["set_angular_velocity"] = function(p)
    return string.format([[
if objects[%s] and objects[%s].angularVelocity then objects[%s].angularVelocity = %s end
]], p[1], p[1], p[1], p[2])
end,

["apply_torque"] = function(p)
    return string.format([[
if objects[%s] and objects[%s].applyTorque then objects[%s]:applyTorque(%s) end
]], p[1], p[1], p[1], p[2])
end,

["set_angular_impulse"] = function(p)
    return string.format([[
if objects[%s] and objects[%s].applyAngularImpulse then objects[%s]:applyAngularImpulse(%s) end
]], p[1], p[1], p[1], p[2])
end,

["set_gravity_scale"] = function(p)
    return string.format([[
if objects[%s] and objects[%s].gravityScale then
    objects[%s].gravityScale = %s
    objects[%s]._gravity = %s
end]], p[1], p[1], p[1], p[2], p[1], p[2])
end,

["set_sensor"] = function(p)
    return string.format([[
if objects[%s] and objects[%s].isSensor ~= nil then objects[%s].isSensor = %s end
]], p[1], p[1], p[1], p[2])
end,

["set_fixed_rotation"] = function(p)
    return string.format([[
if objects[%s] and objects[%s].isFixedRotation ~= nil then objects[%s].isFixedRotation = %s end
]], p[1], p[1], p[1], p[2])
end,

["set_bullet"] = function(p)
    return string.format([[
if objects[%s] and objects[%s].isBullet ~= nil then 
    objects[%s].isBullet = %s 
end]], p[1], p[1], p[1], p[2])
end,

["set_linear_damping"] = function(p)
    return string.format([[
if objects[%s] and objects[%s].linearDamping then objects[%s].linearDamping = %s end
]], p[1], p[1], p[1], p[2])
end,

["set_angular_damping"] = function(p)
    return string.format([[
if objects[%s] and objects[%s].angularDamping then objects[%s].angularDamping = %s end
]], p[1], p[1], p[1], p[2])
end,

["set_awake"] = function(p)
    return string.format([[
if objects[%s] and objects[%s].isAwake ~= nil then objects[%s].isAwake = true end
]], p[1], p[1], p[1])
end,

["set_pivot_joint"] = function(p)
    return string.format([[
pcall(function() if joints[%s] then joints[%s]:removeSelf() end end)
pcall(function()
    local base = objects[%s]
    local pivot = objects[%s]
    if base and pivot and base._ponos_body_type and pivot._ponos_body_type then
        joints[%s] = physics.newJoint("pivot", base, pivot, pivot.x + (%s), pivot.y + (%s))
    end
end)]], p[1], p[1], p[2], p[3], p[1], p[4], p[5])
end,

["set_distance_joint"] = function(p)
    return string.format([[
pcall(function() if joints[%s] then joints[%s]:removeSelf() end end)
pcall(function()
    local bodyA = objects[%s]
    local bodyB = objects[%s]
    if bodyA and bodyB and bodyA._ponos_body_type and bodyB._ponos_body_type then
        joints[%s] = physics.newJoint("distance", bodyA, bodyB, bodyA.x+(%s), bodyA.y+(%s), bodyB.x+(%s), bodyB.y+(%s))
    end
end)]], p[1], p[1], p[2], p[3], p[1], p[4], p[5], p[6], p[7])
end,

["set_weld_joint"] = function(p)
    return string.format([[
pcall(function() if joints[%s] then joints[%s]:removeSelf() end end)
pcall(function()
    local bodyA = objects[%s]
    local bodyB = objects[%s]
    if bodyA and bodyB and bodyA._ponos_body_type and bodyB._ponos_body_type then
        joints[%s] = physics.newJoint("weld", bodyA, bodyB, bodyA.x+(%s), bodyA.y+(%s))
    end
end)]], p[1], p[1], p[2], p[3], p[1], p[4], p[5])
end,

["set_piston_joint"] = function(p)
    return string.format([[
pcall(function() if joints[%s] then joints[%s]:removeSelf() end end)
pcall(function()
    local base = objects[%s]
    local piston = objects[%s]
    if base and piston and base._ponos_body_type and piston._ponos_body_type then
        joints[%s] = physics.newJoint("piston", base, piston, piston.x+(%s), piston.y+(%s), %s, %s)
    end
end)]], p[1], p[1], p[2], p[3], p[1], p[4], p[5], p[6], p[7])
end,

["set_wheel_joint"] = function(p)
    return string.format([[
pcall(function() if joints[%s] then joints[%s]:removeSelf() end end)
pcall(function()
    local base = objects[%s]
    local wheel = objects[%s]
    if base and wheel and base._ponos_body_type and wheel._ponos_body_type then
        joints[%s] = physics.newJoint("wheel", base, wheel, wheel.x+(%s), wheel.y+(%s), %s, %s)
    end
end)]], p[1], p[1], p[2], p[3], p[1], p[4], p[5], p[6], p[7])
end,

["set_touch_joint"] = function(p)
    return string.format([[
pcall(function() if joints[%s] then joints[%s]:removeSelf() end end)
pcall(function()
    local obj = objects[%s]
    if obj and obj._ponos_body_type then
        joints[%s] = physics.newJoint("touch", obj, obj.x+(%s), obj.y+(%s))
    end
end)]], p[1], p[1], p[2], p[1], p[3], p[4])
end,

["set_rope_joint"] = function(p)
    return string.format([[
pcall(function() if joints[%s] then joints[%s]:removeSelf() end end)
pcall(function()
    local bodyA = objects[%s]
    local bodyB = objects[%s]
    if bodyA and bodyB and bodyA._ponos_body_type and bodyB._ponos_body_type then
        joints[%s] = physics.newJoint("rope", bodyA, bodyB, bodyA.x+(%s), bodyA.y+(%s), bodyB.x+(%s), bodyB.y+(%s))
    end
end)]], p[1], p[1], p[2], p[3], p[1], p[4], p[5], p[6], p[7])
end,

["delete_joint"] = function(p)
    return string.format([[
pcall(function() if joints[%s] then joints[%s]:removeSelf() joints[%s] = nil end end)]], p[1], p[1], p[1])
end,

["set_pivot_motor"] = function(p)
    return string.format([[
pcall(function()
    local joint = joints[%s]
    if joint then
        joint.isMotorEnabled = %s
        joint.motorSpeed = %s
        joint.maxMotorTorque = %s
    end
end)]], p[1], p[2], p[3], p[4])
end,

["set_pivot_limits"] = function(p)
    return string.format([[
pcall(function()
    local joint = joints[%s]
    if joint then
        joint.isLimitEnabled = %s
        joint:setRotationLimits(%s, %s)
    end
end)]], p[1], p[2], p[3], p[4])
end,

["set_distance_settings"] = function(p)
    return string.format([[
pcall(function()
    local joint = joints[%s]
    if joint then
        joint.dampingRatio = (%s) / 100
        joint.frequency = %s
        joint.length = %s
    end
end)]], p[1], p[2], p[3], p[4])
end,

["set_touch_target"] = function(p)
    return string.format([[
pcall(function()
    local joint = joints[%s]
    if joint then joint:setTarget(%s, %s) end
end)]], p[1], p[2], p[3])
end,


["set_bounce"] = function(p)
    return string.format([[pcall(function() %s.bounce = %s end)]], p[1], p[2])
end,

["set_friction"] = function(p)
    return string.format([[pcall(function() %s.friction = %s end)]], p[1], p[2])
end,

["set_tangent_speed"] = function(p)
    return string.format([[pcall(function() %s.tangentSpeed = %s end)]], p[1], p[2])
end,

["disable_collision"] = function(p)
    return string.format([[pcall(function() %s.isEnabled = false end)]], p[1])
end,


["set_world_gravity"] = function(p)
    return string.format([[pcall(function() physics.setGravity(%s, %s) end)]], p[1], p[2])
end,

["start_physics"] = function(p)
    return [[pcall(function() physics.start() end)]]
end,

["pause_physics"] = function(p)
    return [[pcall(function() physics.pause() end)]]
end,

["stop_physics"] = function(p)
    return [[pcall(function() physics.stop() end)]]
end,

["show_physics_debug"] = function(p)
    return [[pcall(function() physics.setDrawMode("hybrid") end)]]
end,

["hide_physics_debug"] = function(p)
    return [[pcall(function() physics.setDrawMode("normal") end)]]
end,

    ["return"] = function(p)
        return string.format([[return ( %s )]], p[1])
    end,

    ["end"] = function(p)
        return [[end]]
    end,
}

return generators