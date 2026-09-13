--[[ функция 1. utils.isCorrectHex
  проверяет на корректность hex цвета;
  отправляемые данные: текст(string) с хексом;
]]

--функция 2. utils.hexToRgb

--[[ функция 3. utils.rgbToHex
  отправляемые данные - массив {0.75, 1, 0.3}
]]

--[[ функция 4. utils.setRGB (теперь метод внутри picker'а)
  отправляемые данные - r, g, b (от 0 до 1)
]]

-- Это пикер из Pocket Zipka кстати хахпхахпа

function utils.isCorrectHex(value)
    if type(value) ~= "string" or string.len(value) ~= 7 then return false end
    local check = string.gsub(value, "#", "")
    if string.len(check) ~= 6 then return false end
    local found = string.match(check, "[0-9A-Fa-f]+")
    return (found == check)
end

display.newPickerColor = function(onComplete)
    local group = display.newGroup()
    local sdvig = (500 / 6 + 50) / 2

    local rectYourColor = display.newRect(-sdvig, 0, 500, 500)
    rectYourColor:setFillColor(1, 0, 0)
    group:insert(rectYourColor)

    rectYourColor.aim = display.newRoundedRect(0, 0, 50, 50, 25)
    rectYourColor.aim:setFillColor(0, 0, 0, 0)
    rectYourColor.aim.strokeWidth = 5
    rectYourColor.aim.isHitTestable = false
    group:insert(rectYourColor.aim)

    local cRectX, cRectY, cRectW, cRectH = rectYourColor.x, rectYourColor.y, rectYourColor.width, rectYourColor.height
    local cRectMinX = cRectX - cRectW / 2
    local cRectMaxX = cRectX + cRectW / 2
    local cRectMinY = cRectY - cRectH / 2
    local cRectMaxY = cRectY + cRectH / 2

local function touchColor(event)
        if event.phase == "began" then
            native.setKeyboardFocus(nil)
            display.getCurrentStage():setFocus(event.target, event.id)
        end

        if (event.phase == "began" or event.phase == "moved") and onComplete ~= nil then
            local localX, localY = group:contentToLocal(event.x, event.y)

            -- Ограничиваем координаты для курсора в пределах рамки
            local clampedX = math.max(math.min(localX, cRectMaxX), cRectMinX)
            local clampedY = math.max(math.min(localY, cRectMaxY), cRectMinY)

            -- Двигаем визуальный курсор
            rectYourColor.aim.x = clampedX
            rectYourColor.aim.y = clampedY

            -- ИСПРАВЛЕНИЕ БАГА:
            -- Смещаем точку сэмплирования на 1 пиксель внутрь от края объекта.
            -- Это гарантирует, что display.colorSample возьмет цвет градиента, а не пустого фона.
            local safeX = math.max(math.min(clampedX, cRectMaxX - 1), cRectMinX + 1)
            local safeY = math.max(math.min(clampedY, cRectMaxY - 1), cRectMinY + 1)

            -- Берем цвет с безопасной позиции
            local sampleX, sampleY = group:localToContent(safeX, safeY)
            
            display.colorSample(sampleX, sampleY, function(e)
                if onComplete then onComplete({e.r, e.g, e.b}) end
            end)
        elseif event.phase == "ended" or event.phase == "cancelled" then
            display.getCurrentStage():setFocus(event.target, nil)
        end
        return true
    end
    rectYourColor:addEventListener("touch", touchColor)
    rectYourColor:addEventListener("touch", touchColor)

    local rectWhite = display.newRect(-sdvig, 0, 500, 500)
    rectWhite.fill.effect = "filter.linearWipe"
    rectWhite.fill.effect.direction = {1, 0}
    rectWhite.fill.effect.smoothness = 1
    rectWhite.fill.effect.progress = 0.5
    rectWhite.isHitTestable = false
    group:insert(rectWhite)

    local rectBlack = display.newRect(-sdvig, 0, 500, 500)
    rectBlack:setFillColor(0, 0, 0)
    rectBlack.fill.effect = "filter.linearWipe"
    rectBlack.fill.effect.direction = {0, -1}
    rectBlack.fill.effect.smoothness = 1
    rectBlack.fill.effect.progress = 0.5
    rectBlack.isHitTestable = false
    group:insert(rectBlack)

    local tableColors = {{1,0,0},{1,0,1},{0,0,1},{0,1,1},{0,1,0},{1,1,0},{1,0,0}}
    local stepHeight = rectWhite.height / (#tableColors - 1)

    local aimGradient = display.newRoundedRect(rectWhite.x + rectWhite.width / 2 + rectWhite.width / 12 + 50, 0, rectWhite.width / 5, rectWhite.width / 30, rectWhite.width / 90)
    aimGradient:setFillColor(0, 0, 0, 0)
    aimGradient.strokeWidth = 5
    aimGradient.isHitTestable = false
    group:insert(aimGradient)

    local gRectMinY = cRectMinY
    local gRectMaxY = cRectMaxY

    local function touchGradientColor(event)
        if (event.phase == "began" and onComplete ~= nil) then
            native.setKeyboardFocus(nil)
            display.getCurrentStage():setFocus(event.target, event.id)
        end

        if ((event.phase == "began" or event.phase == "moved") and onComplete ~= nil) then
            
            -- ИСПОЛЬЗУЕМ contentToLocal для точного нахождения координат внутри группы
            local localX, localY = group:contentToLocal(event.x, event.y)
            local height = rectWhite.height / 2
            aimGradient.y = math.max(math.min(localY, height - 1), -height + 1)

            -- Получаем экранные координаты курсора градиента
            local sampleX, sampleY = group:localToContent(aimGradient.x, aimGradient.y)

            local function onColorSample(e)
                rectYourColor:setFillColor(e.r, e.g, e.b)
                
                -- ИСПРАВЛЕНИЕ:
                -- Берем реальные экранные координаты курсора для симуляции события, 
                -- чтобы функция touchColor работала правильно, где бы ни находилась группа.
                local aimContentX, aimContentY = group:localToContent(rectYourColor.aim.x, rectYourColor.aim.y)
                
                touchColor({
                    target = rectYourColor, 
                    x = aimContentX, 
                    y = aimContentY, 
                    phase = "moved"
                })
            end
            
            display.colorSample(sampleX, sampleY, onColorSample)

        elseif (onComplete ~= nil) then
            display.getCurrentStage():setFocus(event.target, nil)
        end
        return true
    end

    for i = 1, #tableColors - 1 do
        local gradient = {
            type = "gradient",
            color1 = {tableColors[i][1], tableColors[i][2], tableColors[i][3]},
            color2 = {tableColors[i+1][1],tableColors[i+1][2],tableColors[i+1][3]},
            direction = "down"
        }
        local rectGradient = display.newRect(rectWhite.x + rectWhite.width / 2 + 50, cRectMinY + stepHeight * (i - 1), rectWhite.width / 6, stepHeight)
        rectGradient.anchorX = 0
        rectGradient.anchorY = 0
        rectGradient:setFillColor(gradient)
        rectGradient:addEventListener("touch", touchGradientColor)
        group:insert(rectGradient)
    end

    rectYourColor.aim:toFront()
    aimGradient:toFront()

    function group:setRGB(r, g, b)
        local maxVal = math.max(r, g, b)
        local minVal = math.min(r, g, b)
        local delta = maxVal - minVal

        local h, s, v = 0, 0, maxVal
        if maxVal > 0 then s = delta / maxVal end

        if delta ~= 0 then
            if maxVal == r then h = (g - b) / delta
            elseif maxVal == g then h = 2 + (b - r) / delta
            else h = 4 + (r - g) / delta end
            h = h * 60
            if h < 0 then h = h + 360 end
        end

        local c = 1
        local x_val = c * (1 - math.abs((h / 60) % 2 - 1))
        local pureR, pureG, pureB
        if h >= 0 and h < 60 then pureR, pureG, pureB = c, x_val, 0
        elseif h >= 60 and h < 120 then pureR, pureG, pureB = x_val, c, 0
        elseif h >= 120 and h < 180 then pureR, pureG, pureB = 0, c, x_val
        elseif h >= 180 and h < 240 then pureR, pureG, pureB = 0, x_val, c
        elseif h >= 240 and h < 300 then pureR, pureG, pureB = x_val, 0, c
        else pureR, pureG, pureB = c, 0, x_val end

        rectYourColor:setFillColor(pureR, pureG, pureB)

        local mapped_h = (360 - h) % 360
        local segmentIndex = math.floor(mapped_h / 60)
        if segmentIndex > #tableColors - 2 then segmentIndex = #tableColors - 2 end
        if segmentIndex < 0 then segmentIndex = 0 end
        local segmentProgress = (mapped_h % 60) / 60
        local targetY = cRectMinY + segmentIndex * stepHeight + segmentProgress * stepHeight
        aimGradient.y = math.max(math.min(targetY, gRectMaxY), gRectMinY)

        local posX = cRectMinX + s * (cRectMaxX - cRectMinX)
        local posY = cRectMinY + (1 - v) * (cRectMaxY - cRectMinY)
        rectYourColor.aim.x = math.max(math.min(posX, cRectMaxX), cRectMinX)
        rectYourColor.aim.y = math.max(math.min(posY, cRectMaxY), cRectMinY)

        if onComplete then onComplete({r, g, b}) end
    end

    return group
end

function utils.rgbToHex(rgb)
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

function utils.hexToRgb(hex)
    if not hex or type(hex) ~= 'string' then return {1, 1, 1} end -- Базовая защита
    hex = hex:gsub("#", "")
    if string.len(hex) ~= 6 then return {1, 1, 1} end
    return {
        tonumber("0x" .. hex:sub(1, 2)) or 1 / 255, 
        tonumber("0x" .. hex:sub(3, 4)) or 1 / 255, 
        tonumber("0x" .. hex:sub(5, 6)) or 1 / 255
    }
end