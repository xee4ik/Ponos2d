_G.utils = {}

-- делаем мега конфигурацию всего приложения: отступы, размеры шрифтов, слова, настройки ponosSettings итдитдитд

utils.isWin = system.getInfo 'platform' ~= 'android'
utils.isSim = system.getInfo 'environment' == 'simulator'

display.contentWidth = display.actualContentWidth
display.contentHeight = display.actualContentHeight

sw = display.contentWidth
sh = display.contentHeight

app.content = math.min(sw,sh)

app.topbarheight = 74

app.pad = 14

app.touchDelta = 10

--print(json.encode(app))

app.fabsize = 44

app.s = {
    transition = "fade",
}

local defaultSettings = {
    language = "",
	engBlocks = false,
	engFormulas = false,
	errorAlert = true,
	isFirstTime = true,
	sounds = true,
	user = {
	    name = "Unknow user",
		id = "user_"..math.random(10000000, 99999999),
		color = { math.random(130, 270)/255, math.random(140, 260)/255, math.random(130, 270)/255 }
	},
	useSystemFont = false,
	blocksEditorSaveScrollPosition = true,
	openScriptInSaveScrollPosition = true,
}

ponosSettings = ponosFile["читать путь"]("ponosSettings.json")
if ponosSettings == nil then
    ponosSettings = defaultSettings
    ponosFile["писать путь"]("ponosSettings.json", json.encode(ponosSettings))
end

ponosSettings = json.decode(ponosFile["читать путь"]("ponosSettings.json"))

function app.ponosSttSave()
    ponosFile["писать путь"]("ponosSettings.json", json.encode(ponosSettings))
end

require("ponos.words.index")
app.words = app.updateWords()
require("ponos.all.dat_blocks")
require("ponos.all.dat_formulas")

local function funBackListener(event)
	if ((event.keyName=="back" or event.keyName=="deleteBack" or event.keyName=="escape") and event.phase=="up") then
		special_back_fun()
		return true
	end
end

Runtime:addEventListener("key", funBackListener)

orientation = require("plugin.orientation")

-- Настройки звука
local loadSound = {
   click1 = audio.loadStream("res/sounds/click1.wav"),
   click2 = audio.loadStream("res/sounds/click2.wav"),
}

function app.popSound(key)
	if ponosSettings.sounds then
    	audio.play(
    	    loadSound[key],{
    	        onComplete = function()
					
		        end
		    }
		)
	end
end

-- Размер текста и шрифт 
function app.updateTextSettings()
 app.fontsize1 = 26
 app.fontsize2 = math.floor(app.fontsize1*1.11)
 app.fontsize3 = math.floor(app.fontsize1*1.22)
 app.fontsizeB = math.floor(app.fontsize1*0.85)
 
 if ponosSettings.useSystemFont then
  app.font = native.systemFont
  app.fontBold = native.systemFontBold
  app.fontMedium = native.systemFont
 else
  app.font = "res/fonts/NotoSans/regular.ttf"
  app.fontBold = "res/fonts/NotoSans/bold.ttf"
  app.fontMedium = "res/fonts/NotoSans/medium.ttf"
 end
end

-- Цвета приложения
function app.updateColorSettings()
app.color = {
    mainBackgroundColor = {0.10, 0.10, 0.11},
    
    cursorColor = {0.35, 0.60, 0.85},
    lineColor = {1, 1, 1, 0.1}, 
    
	standartTextColor = {0.85, 0.85, 0.85}, 
	textDescColor = {0.55, 0.55, 0.55},
	textAcentLightColor = {1, 1, 1}, 
	formulaTextColor = {1,1,1},
	
	panelBgColor = {0.15, 0.15, 0.16},
	settingsCardBgColor = {0.16, 0.16, 0.17},
	
	projectCardBgcolor = {0.16, 0.16, 0.17},
	projectCardOutlineColor = {0.22, 0.22, 0.24},
	projectCardTextColor = {0.9, 0.9, 0.9},
	projectOpen = {text = {1,1,1}, bg = {0,0,0, 0.01}},
    
    listBgColor = {0.16, 0.16, 0.17}, 
    listOutlineColor = {0.22, 0.22, 0.24},
    listTextColor = {0.9, 0.9, 0.9},
    
    btnBgColor = {0.22, 0.22, 0.24}, 
    btnTextColor = {0.95, 0.95, 0.95},
    btnDelBgColor = {0.85, 0.35, 0.35},
    btnCopyBgColor = {0.25, 0.55, 0.45},
    buttonRippleColor = {1, 1, 1, 0.18},
    
    btnFabBgColor = {0.35, 0.60, 0.85},
	btnFabIconColor = {1,1,1},
	btnFabTextColor = {1,1,1},
    btnFabOutlineColor = {0.2, 0.2, 0.22},
    
    topBar1BgColor = {0.07, 0.07, 0.08},
    topBar1TextColor = {0.9, 0.9, 0.9},
    topBar2BgColor = {0.12, 0.12, 0.13},
    topBar2TextColor = {0.75, 0.75, 0.75},
    
    bottomBarBgColor = {0.07, 0.07, 0.08},
    bottomBarIconColor = {0.6, 0.6, 0.6},
    bottomBarHighLightColor = {0.35, 0.60, 0.85}, 
    
    dialogColor = {
        bg = {0.16, 0.16, 0.17},
        header = {1, 1, 1},
        description = {0.8, 0.8, 0.8},
        buttonText = {1, 1, 1},
    },
    
    dropdown = {
        bg = {0.18, 0.18, 0.19},
        text = {0.9, 0.9, 0.9},
        ripple = {1, 1, 1, 0.08}
    },
    
    formulaEditorNumPadGradient = { type = "gradient", color1 = {1,1,1,0.02}, color2 = {1,1,1,0.05}, direction = "down" },
    formulaEditorButtonsColours = { default = {0.22, 0.22, 0.24}, action = {0.35, 0.35, 0.38} },
    
    scrollviewGlowColor = {0.35, 0.60, 0.85},
    scrollviewMaxGlowAlphaValue = 0.15,
    
    checkBoxColor = {
        inactive = {0.45, 0.45, 0.45},
        active = {0.35, 0.60, 0.85},
    },
    
    radioButton = {
        bg = {0.16, 0.16, 0.17},
        strokeWidth = 2,
        strokeColor = {0.45, 0.45, 0.45},
        accentColor = {0.35, 0.60, 0.85}
    },
	
	loaderColor = {1,1,1},
	redactorFormulaBgElementsCode = { numberColor = {1, 0, 0.3}, functionColor = {1, 0.8, 0}, stringColor = {0, 1, 0.3}, defaultColor = {0.6, 0.6, 0.6} },
}
-- app.color = {
-- mainBackgroundColor = {0.94, 0.94, 0.96},
-- cursorColor = {0.15, 0.48, 0.82},
-- lineColor = {0, 0, 0, 0.08}, 

-- standartTextColor = {0.18, 0.18, 0.20}, 
-- textDescColor = {0.50, 0.50, 0.54},
-- textAcentLightColor = {0.10, 0.10, 0.12}, 
-- formulaTextColor = {1,1,1},

-- panelBgColor = {1.0, 1.0, 1.0},
-- settingsCardBgColor = {1.0, 1.0, 1.0},

-- projectCardBgcolor = {1.0, 1.0, 1.0},
-- projectCardOutlineColor = {0.84, 0.84, 0.88},
-- projectCardTextColor = {0.15, 0.15, 0.18},
-- projectOpen = {text = {0.1, 0.1, 0.12}, bg = {0, 0, 0, 0.03}},

-- listBgColor = {1.0, 1.0, 1.0}, 
-- listOutlineColor = {0.84, 0.84, 0.88},
-- listTextColor = {0.15, 0.15, 0.18},

-- btnBgColor = {0.90, 0.90, 0.93}, 
-- btnTextColor = {0.15, 0.15, 0.18},
-- btnDelBgColor = {0.90, 0.40, 0.40},
-- btnCopyBgColor = {0.20, 0.60, 0.48},
-- buttonRippleColor = {0, 0, 0, 0.08},

-- btnFabBgColor = {0.15, 0.48, 0.82},
-- btnFabIconColor = {1, 1, 1},
-- btnFabTextColor = {1, 1, 1},
-- btnFabOutlineColor = {0.75, 0.75, 0.80},

-- topBar1BgColor = {0.92, 0.92, 0.95},
-- topBar1TextColor = {0.15, 0.15, 0.18},
-- topBar2BgColor = {0.96, 0.96, 0.98},
-- topBar2TextColor = {0.45, 0.45, 0.48},

-- bottomBarBgColor = {0.92, 0.92, 0.95},
-- bottomBarIconColor = {0.50, 0.50, 0.54},
-- bottomBarHighLightColor = {0.15, 0.48, 0.82}, 

-- dialogColor = {
    -- bg = {1.0, 1.0, 1.0},
    -- header = {0.12, 0.12, 0.15},
    -- description = {0.35, 0.35, 0.38},
    -- buttonText = {0.15, 0.15, 0.18},
-- },

-- dropdown = {
    -- bg = {0.97, 0.97, 0.99},
    -- text = {0.15, 0.15, 0.18},
    -- ripple = {0, 0, 0, 0.05}
-- },

-- formulaEditorNumPadGradient = { type = "gradient", color1 = {0, 0, 0, 0.01}, color2 = {0, 0, 0, 0.04}, direction = "down" },
-- formulaEditorButtonsColours = { default = {0.90, 0.90, 0.93}, action = {0.80, 0.80, 0.84} },

-- scrollviewGlowColor = {0.15, 0.48, 0.82},
-- scrollviewMaxGlowAlphaValue = 0.12,

-- checkBoxColor = {
    -- inactive = {0.60, 0.60, 0.64},
    -- active = {0.15, 0.48, 0.82},
-- },

-- radioButton = {
    -- bg = {1.0, 1.0, 1.0},
    -- strokeWidth = 2,
    -- strokeColor = {0.60, 0.60, 0.64},
    -- accentColor = {0.15, 0.48, 0.82}
-- },

-- loaderColor = {0,0,0},
-- redactorFormulaBgElementsCode = { numberColor = {1, 0, 0.3}, functionColor = {1, 0.8, 0}, stringColor = {0, 1, 0.3}, defaultColor = {0.6, 0.6, 0.6} },

-- }
end 

app.unpack = unpack or table.unpack

-- Функция для обновления всех настроек интерфейса сразу
function app.updateInterfaceValues()
 app.updateTextSettings()
 app.updateColorSettings()
end

-- обновляем значения при первом входе
app.updateInterfaceValues()