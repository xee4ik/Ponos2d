-- Предопределяем функцию кнопки 'Назад'.
special_back_fun = nil
ponosFile = {}

-- Предопределяем 'app'
app = {}; utils = require("ponos.funsus.MicroModule")

-- Библиотеки и плагины
clipboard = require 'plugin.pasteboard' 
json = require("json")
utf8 = require("libs.utf8")

-- Модуль работы с файлами
require("ponos.funsus.file")

-- Инит настроек приложения и 'app'
require("ponos.settings")

-- Interface
PonosUi = require("ponos.fileM.PonosUi") -- Виджеты интерфейса (кнопки, слайдеры, чекбоксы, радио группы, скроллы идр)
widget = require("widget") -- На всяий случай виджеты от Короны
require("ponos.fileM.dialogue") -- Модуль для создания всяких всплывающих окон
require("ponos.fileM.dropdown") -- Модуль всплывающих списков

-- Другие файлы
require("ponos.fileM.paletteAndHex") -- Выборка цвета (by cerberus)
require("ponos.fileM.topbar") -- ХУЙХУЙХУЙХУЙХУЙ
require("ponos.fileM.block") -- Блок как объект
require("ponos.scenes.formula_editor") -- Редактор формул
require("ponos.game.blocks") -- Категории блоков
require("ponos.game.formulas") -- Сборка формул
require("ponos.game.game") -- Сборка кода проекта и симулятор

-- Модуль типо Composer от Квистера(риквеста)
scene = require("ponos.fileM.scene")

-- Открываем первую сцену
if ponosSettings.isFirstTime then
 scene.newScene("start", { params={} })
else
 scene.newScene("menu", { params={} })
end

timer.performWithDelay(100, function()
local score = 0
for i = 1, #blocks_category.allcat do
    local this = blocks_category[blocks_category.allcat[i][1]]
	for j = 1, #this do
	    if this[j].comment == nil then score = score+1 end
	end
end
print(score)
end, 1)