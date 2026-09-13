-- загружаем формулы
require("ponos.all.dat_formulas")

-- Тут файл где всем формулам присваиваются свои функции объедененный с функциями-сборщиками формул как визуально так и в код

local funcs = { 
    pos_x = "ponosfun.pos_x", 
    pos_y = "ponosfun.pos_y", 
    width = "ponosfun.width", 
    height = "ponosfun.height", 
    xScale = "ponosfun.xScale", 
    yScale = "ponosfun.yScale", 
    rotation = "ponosfun.rotation", 
    alpha = "ponosfun.alpha", 
    visible = "ponosfun.visible", 
    anchorX = "ponosfun.anchorX", 
    anchorY = "ponosfun.anchorY", 
    text = "ponosfun.text",
	object_var = "ponosfun.object_var",
    sin = "ponosfun.sin", 
    cos = "ponosfun.cos", 
    tg = "ponosfun.tg", 
    ctg = "ponosfun.ctg", 
    asin = "ponosfun.asin",
    acos = "ponosfun.acos",
    atan = "ponosfun.atan",
    floor = "math.floor", 
    ceil = "ponosfun.ceil",
    round = "ponosfun.round",
    abs = "math.abs",
    sqrt = "math.sqrt",
    pow = "math.pow",
    min = "math.min",
    max = "math.max",
    random = "math.random", 
    log10 = "math.log10",
	screen_width = "display.contentWidth",
	screen_height = "display.contentHeight",
	screen_centerX = "display.contentWidth/2",
	screen_centerY = "display.contentHeight/2",
	get_var = "ponosfun.get_var",
	camera_x = "gameScene.x",
	camera_y = "gameScene.y",
	rgb_to_hex = "ponosfun.rgbToHex",
    ["str_len"] = "string.len",
    ["str_upper"] = "string.upper",
    ["str_lower"] = "string.lower",
    ["str_sub"] = "string.sub",
    ["str_rep"] = "string.rep",
    ["str_reverse"] = "string.reverse",
    ["str_find"] = "string.find",
	["JSON_encode"] = 'json.encode',
	["JSON_decode"] = 'json.decode'
}

-- это функция чтобы заебошить конкретный элемент формулы
function binini_formula(this)
	local result = ""
		
    if this[1] == "number" then
        result = this[2]
    elseif this[1] == "string" then
    	result = "'"..this[2].."'"
	elseif this[1] == "func" then
	    result = funs_words[this[2]] or "ERROR"
	elseif this[1] == "key" then
	    result = "["..this[2].."]" or "ERROR"
	elseif this[1] == "function" then
	    if this[2] == "*" then
		    result = "×"
		elseif this[2] == "/" then
		    result = "÷"
		elseif this[2] == "~=" then
		    result = "≠"
		elseif this[2] == ">=" then
		    result = "≥"
		elseif this[2] == "<=" then
		    result = "≤"
		elseif this[2] == "and" then
		    result = app.words[85]
		elseif this[2] == "or" then
		    result = app.words[86]
		elseif this[2] == "not" then
		    result = app.words[87]
		elseif this[2] == "true" then
		    result = app.words[88]
		elseif this[2] == "false" then
		    result = app.words[89]
		elseif this[2] == "nil" then
		    result = app.words[233]
		else
		    result = this[2]
		end
    end
	
	return result
end

-- функция для создания строки из формулы. Принимаем грязные таблички, а выводим красивый текст формулы :)
function make_formula(bin, cursor)
    bin = bin or {{"number", 0}}
	local result = ""
	for i = 1, #bin do
	    local this = bin[i]
	    result = result..binini_formula(this).." "
	end
	return result
end

local function make_func(func)
    local result = funcs[func] or func
    
	return result
end

function pekarim_formula(formula)
    local result = ""
	
	for i = 1, #formula do
	    local symbol = formula[i]
	    
	    if symbol[1] == "string" then
		    symbol[2] = string.format("%q", symbol[2])
		    
        elseif symbol[1] == "key" then
		    symbol[2] = string.format("[%q]", symbol[2])
		    
		elseif symbol[1] == "func" then
		    symbol[2] = make_func(symbol[2])
		elseif symbol[2] == "true" or symbol[2] == "false" or symbol[2] == "not" or symbol[2] == "and" or symbol[2] == "or" or symbol[2] == "nil" then
		    symbol[2] = " "..make_func(symbol[2]).." "
		end
	    
	    result = result .. (symbol[2] or "")
	end
	
	return result
end