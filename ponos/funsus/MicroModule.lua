function rgbToHex(rgb)
	local hexadecimal = '#'
	for key, value in pairs(rgb) do
		local hex = ''
		while(value > 0)do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex
		end
		if(string.len(hex) == 0)then
			hex = '00'
		elseif(string.len(hex) == 1)then
			hex = '0' .. hex
		end
		hexadecimal = hexadecimal .. hex
	end
	return hexadecimal
end

function hexToRgb(hex)
    if not hex then return {0, 0, 0} end
    hex = hex:gsub("#", "")
    if string.len(hex) ~= 6 then return {1, 1, 1} end
    return {
        tonumber("0x" .. hex:sub(1, 2)) / 255, 
        tonumber("0x" .. hex:sub(3, 4)) / 255, 
        tonumber("0x" .. hex:sub(5, 6)) / 255
    }
end

function deep_copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    
    for k, v in pairs(obj) do
        res[deep_copy(k, s)] = deep_copy(v, s)
    end
    return res
end

function getBottomNavHeight()
    local totalHeight = display.actualContentHeight
    local safeHeight = display.safeActualContentHeight
    
    local totalInsetValue = totalHeight - safeHeight
    
    local topInset = math.abs(display.safeScreenOriginY)
    
    local bottomInset = totalInsetValue - topInset
    
    return math.max(0, bottomInset)
end

function copy_pasteboard(string)
    ponosFile["писать путь"]("clipboard.txt", string)
	print(string)
	clipboard.copy()
end