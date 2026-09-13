local m = {}

function m.loadPonosEngine(data)
 local name = data.project_name
 local lua = [[local json = require("json")
local physics = require("physics")
physics.start()
local project = json.decode(]]..string.format('%q', json.encode(data))..[[)
local gameScene = display.newGroup()
local objects = {}
local joints = {}
local global_vars = {}
local local_vars = {}
local ponosfun = {}
local BASE_DIR
local RES_PATH
if isGameSim then 
 BASE_DIR = system.DocumentsDirectory 
 RES_PATH = "projects/]]..name..[[/resources/"
else 
 BASE_DIR = system.ResourceDirectory 
 RES_PATH = "res/"
end
ponosfun.sin = function(value) return(math.sin(math.rad(value))) end
ponosfun.cos = function(value) return(math.cos(math.rad(value))) end
ponosfun.tg = function(value) return(math.tan(math.rad(value))) end
ponosfun.asin = function(value) return(math.deg(math.asin(value))) end
ponosfun.acos = function(value) return(math.deg(math.acos(value))) end
ponosfun.atan = function(value) return(math.deg(math.atan(value))) end
ponosfun.pos_x = function(value) return( objects[value].x ) end
ponosfun.pos_y = function(value) return( objects[value].y ) end
ponosfun.width = function(value) return( objects[value].width ) end
ponosfun.height = function(value) return( objects[value].height ) end
ponosfun.alpha = function(value) return( objects[value].alpha ) end
ponosfun.rotation = function(value) return( objects[value].rotation ) end
ponosfun.text = function(value) return( objects[value].text ) end
ponosfun.object_var = function(object, key) return( objects[object].variables[key] ) end
ponosfun.xScale = function(value) return( objects[value].xScale ) end
ponosfun.yScale = function(value) return( objects[value].yScale ) end
ponosfun.round = function(value) local flValue = math.floor(value) local remainder = value-flValue flValue = flValue+(remainder>=0.5 and 1 or 0) return(flValue) end
ponosfun.cell = function(value) return(math.floor(value)+1) end
ponosfun.timer = function(sec, repeats, callback) timer.performWithDelay(sec, callback, repeats) end
ponosfun.get_var = function(name) if local_vars[name] ~= nil then return local_vars[name] end return global_vars[name] end
ponosfun.print = function(log) print(log); if isGameSim then table.insert(console_, {log}) end end
ponosfun.rgbToHex = function(r,g,b) local rgb = {r,g,b}; local hexadecimal = '#' for key, value in pairs(rgb) do local hex = '' while (value > 0) do local index = math.fmod(value, 16) + 1; value = math.floor(value / 16); hex = string.sub('0123456789ABCDEF', index, index) .. hex end  if(string.len(hex) == 0) then hex = '00' elseif(string.len(hex) == 1) then hex = '0' .. hex end hexadecimal = hexadecimal .. hex end return hexadecimal end
ponosfun.hexToRgb = function(hex) if not hex then return {1, 1, 1} end hex = hex:gsub("#", "") if string.len(hex) ~= 6 then return {1, 1, 1} end return { tonumber("0x" .. hex:sub(1, 2)) / 255, tonumber("0x" .. hex:sub(3, 4)) / 255, tonumber("0x" .. hex:sub(5, 6)) / 255} end

-- РАБОТА С ПОТОКОМ --
ponosfun.createScope = function(parent)
 local scope = {}
 setmetatable(scope, {
  __index = parent,
  __newindex = function(t, k, v)
   local curr = parent
   while curr do
    if rawget(curr, k) ~= nil then
     rawset(curr, k, v)
     return
    end
    local mt = getmetatable(curr)
    curr = mt and mt.__index
   end
   rawset(t, k, v)
  end
 })
 return scope
end
ponosfun.threader = function(func)
 local co = coroutine.create(func)
 local function resume()
  local status, err = coroutine.resume(co)
  if not status then
   if __sandbox_error then
    __sandbox_error(err)
   else
    ponosfun.print(err)
   end
  end
 end
 resume()
end
ponosfun.wait = function(sec)
 local co = coroutine.running()
 if co then
  timer.performWithDelay(sec * 1000, function()
   coroutine.resume(co)
  end)
  coroutine.yield()
 end
end

ponosfun.text_alert = function(title)
 local co = coroutine.running()
 local _dialogGroup = display.newGroup()
 local _bgDim = display.newRect(display.contentCenterX, display.contentCenterY, 10000, 10000)
 _dialogGroup:insert(_bgDim)
 _bgDim:setFillColor(0, 0, 0, 0.6)
 _bgDim.isHitTestable = true
 _bgDim:addEventListener("touch", function() return true end)
 local _dialogBg = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth * 0.8, 200)
 _dialogGroup:insert(_dialogBg)
 _dialogBg:setFillColor(0, 0, 0)
 _dialogBg.strokeWidth = 2
 _dialogBg:setStrokeColor(0.8, 0.8, 0.8)
 local _qText = display.newText({
  text = tostring(title),
  x = display.contentCenterX,
  y = display.contentCenterY - 60,
  width = display.contentWidth * 0.7,
  font = native.systemFont,
  fontSize = 28,
  align = "center"
 })
 _qText:setFillColor(1, 1, 1)
 _dialogGroup:insert(_qText)
 local _btnBg = display.newRect(display.contentCenterX, display.contentCenterY + 50, 120, 40)
 _btnBg:setFillColor(1, 1, 1)
 _dialogGroup:insert(_btnBg)
 local _btnText = display.newText({
  text = "OK",
  x = display.contentCenterX,
  y = display.contentCenterY + 50,
  font = native.systemFont,
  fontSize = 18
 })
 _btnText:setFillColor(0, 0, 0)
 _dialogGroup:insert(_btnText)
 _btnBg:addEventListener("touch", function(e)
  if e.phase == "ended" then
   display.remove(_dialogGroup)   
   if co then coroutine.resume(co) end
  end
  return true
 end)
 _dialogGroup:toFront()
 if co then coroutine.yield() end
end
ponosfun.input_alert = function(title, callback)
 local co = coroutine.running()
 local _dialogGroup = display.newGroup()
 local _bgDim = display.newRect(display.contentCenterX, display.contentCenterY, 10000, 10000)
 _dialogGroup:insert(_bgDim)
 _bgDim:setFillColor(0, 0, 0, 0.6)
 _bgDim.isHitTestable = true
 _bgDim:addEventListener("touch", function() return true end)
 local _dialogBg = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth * 0.8, 200)
 _dialogGroup:insert(_dialogBg)
 _dialogBg:setFillColor(0, 0, 0)
 _dialogBg.strokeWidth = 2
 _dialogBg:setStrokeColor(0.8, 0.8, 0.8)
 local _qText = display.newText({
  text = tostring(title),
  x = display.contentCenterX,
  y = display.contentCenterY - 60,
  width = display.contentWidth * 0.7,
  font = native.systemFont,
  fontSize = 28,
  align = "center"
 })
 _qText:setFillColor(1, 1, 1)
 _dialogGroup:insert(_qText)
 local _inputField = native.newTextField(display.contentCenterX, display.contentCenterY - 10, display.contentWidth * 0.7, 40)
 _dialogGroup:insert(_inputField)
 local _btnBg = display.newRect(display.contentCenterX, display.contentCenterY + 50, 120, 40)
 _btnBg:setFillColor(1, 1, 1)
 _dialogGroup:insert(_btnBg)
 local _btnText = display.newText({
     text = "OK",
     x = display.contentCenterX,
     y = display.contentCenterY + 50,
     font = native.systemFont,
     fontSize = 18
 })
 _btnText:setFillColor(0, 0, 0)
 _dialogGroup:insert(_btnText)
 _btnBg:addEventListener("touch", function(e)
  if e.phase == "ended" then
   local _val = ""
   if _inputField and _inputField.text then
    _val = _inputField.text
   end
   if callback then
    callback(_val)
   end
   if _inputField then
    _inputField:removeSelf()
    _inputField = nil
   end
   display.remove(_dialogGroup)
   if co then coroutine.resume(co) end
  end
  return true
 end)
 _dialogGroup:toFront()
 if co then coroutine.yield() end
end
	
local ponosBehaviors = {
    touchAnimation = function(object, level)
	    local power = 1+level
	    object:addEventListener("touch", function(event)
		    if event.phase == "began" then
				if object.touchAnimation then
				    object.xScale = object.startScale.x
					object.yScale = object.startScale.y
				    transition.cancel(object.touchAnimation)
				end
				object.startScale = {
				   x = object.xScale, 
				   y = object.yScale
				}
				display.getCurrentStage():setFocus( object )
				object.touchAnimation = transition.to(object, {xScale = object.startScale.x/power, yScale = object.startScale.y/power, time = 100} )
			elseif event.phase == "ended" then
			    if object.touchAnimation then
				    transition.cancel(object.touchAnimation)
				end
			    object.touchAnimation = transition.to(object, {xScale = object.startScale.x, yScale = object.startScale.y, time = 100} )
				display.getCurrentStage():setFocus( nil )
			end
		end)
	end,
	player = function(object)
		
	end,
	solid = function(object)
		
	end
}
local_vars = ponosfun.createScope(nil)

-- =========================
-- ===== ДАЛЕЕ ВАШ КОД =====
-- =========================]]
 return lua
end

m.generators = require("ponos.game.generators")

return m