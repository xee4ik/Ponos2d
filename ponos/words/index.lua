function app.updateWords()
    local words = {}
    
    local deviceLang = system.getPreference("locale", "language") or "en"
    
    local currentLangCode = ponosSettings.language
    
    if currentLangCode == "" or currentLangCode == nil then
        if deviceLang == "ru" then
            currentLangCode = "Русский"
        elseif deviceLang == "zh" or deviceLang == "zh-Hans" or deviceLang == "zh-CN" then
            currentLangCode = "Chinese"
        elseif deviceLang == "zh-Hant" or deviceLang == "zh-TW" or deviceLang == "zh-HK" then
            currentLangCode = "Chinese"
        else
            currentLangCode = "English"
        end
    end
    
    local langPaths = {
        ["English"] = "eng", 
        ["Русский"] = "ru", 
        ["Chinese"] = "zh", 
    }
    
    ponosSettings.language = currentLangCode
    if app.ponosSttSave then
        app.ponosSttSave()
    end
    
    local filePath = langPaths[currentLangCode]
    
    if not filePath then
        filePath = "eng"
    end
    
    local success, wordsModule = pcall(require, "ponos.words." .. filePath)
    
    if success and type(wordsModule) == "table" then
        words = wordsModule
    else
        success, wordsModule = pcall(require, "ponos.words.eng")
        if success and type(wordsModule) == "table" then
            words = wordsModule
        else
            words = {}
        end
    end
    
    return words
end