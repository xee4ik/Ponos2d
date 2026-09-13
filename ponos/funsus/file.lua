local json = require("json")
local lfs = require("lfs")
local import = require('plugins.import')

BASE_DIR = system.DocumentsDirectory
P_DIR = "projects/"

default_project = {
    project_name = "project_name",
    orientation = "portrait",
	automatic_screenshot = true,
    display_config = {
    }
}

ponosFile.format = function(e)
    return e:match("%.([^%.]+)$")
end

local function ensureDir(path)
    local fullPath = system.pathForFile(path, BASE_DIR)
    if fullPath then
        lfs.chdir(system.pathForFile("", BASE_DIR))
        lfs.mkdir(path)
    end
end

ensureDir(P_DIR)
ensureDir("build/")
ensureDir("PonosMasks/")

ensureDir("Backpack/")
ensureDir("Backpack/scripts")

ponosFile['создать путь'] = ensureDir

ponosFile["читать путь"] = function(path)
    local fullPath = system.pathForFile(path, BASE_DIR)
    if not fullPath then return nil end
    local file = io.open(fullPath, "r")
    if not file then return nil end
    local contents = file:read("*a")
    io.close(file)
    return contents
end

ponosFile["писать путь"] = function(path, value)
    if not path or value == nil then return false end
    local fullPath = system.pathForFile(path, BASE_DIR)
    if not fullPath then return false end
    local file = io.open(fullPath, "w")
    if not file then return false end
    file:write(tostring(value))
    io.close(file)
    return true
end

ponosFile["проверить существование"] = function(path)
    local fullPath = system.pathForFile(path, BASE_DIR)
    if not fullPath then return false end
    local file = io.open(fullPath, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

local function ensureDirRecursive(path)
    local parts = {}
    for part in path:gmatch("[^/]+") do
        table.insert(parts, part)
    end
    local current = ""
    for _, part in ipairs(parts) do
        current = current == "" and part or (current .. "/" .. part)
        local fullPath = system.pathForFile(current, BASE_DIR)
        if fullPath then
            lfs.mkdir(fullPath)
        end
    end
end

ponosFile["копировать файл"] = function(s, d)
    if not s or not d then return false end
    local dd = d:match("(.+)/[^/]+$")
    if dd then ensureDirRecursive(dd) end
    
    local sf = system.pathForFile(s, BASE_DIR)
    local df = system.pathForFile(d, BASE_DIR)
    if not sf or not df then return false end
    
    local src = io.open(sf, "rb")
    if not src then return false end
    local data = src:read("*a")
    src:close()
    
    local dst = io.open(df, "wb")
    if not dst then return false end
    dst:write(data)
    dst:close()
    return true
end

ponosFile["копировать папку"] = function(srcDir, destDir)
    if not srcDir or not destDir then return false end
    local srcFullPath = system.pathForFile(srcDir, BASE_DIR)
    if not srcFullPath then return false end
    
    local attr = lfs.attributes(srcFullPath)
    if not attr or attr.mode ~= "directory" then return false end
    
    ensureDirRecursive(destDir)
    for file in lfs.dir(srcFullPath) do
        if file ~= "." and file ~= ".." then
            local srcPath = srcDir .. "/" .. file
            local dstPath = destDir .. "/" .. file
            local filePath = system.pathForFile(srcPath, BASE_DIR)
            local fileAttr = filePath and lfs.attributes(filePath)
            
            if fileAttr and fileAttr.mode == "directory" then
                ponosFile["копировать папку"](srcPath, dstPath)
            else
                ponosFile["копировать файл"](srcPath, dstPath)
            end
        end
    end
    return true
end

ponosFile["удалить файл"] = function(path)
    if not path then return false end
    local fullPath = system.pathForFile(path, BASE_DIR)
    if not fullPath then return false end
    return os.remove(fullPath) ~= nil
end

ponosFile["удалить папку"] = function(path)
    if not path then return false end
    local fullPath = system.pathForFile(path, BASE_DIR)
    if not fullPath then return false end
    
    local attr = lfs.attributes(fullPath)
    if not attr or attr.mode ~= "directory" then return false end
    
    for file in lfs.dir(fullPath) do
        if file ~= "." and file ~= ".." then
            local itemPath = path .. "/" .. file
            local itemFullPath = system.pathForFile(itemPath, BASE_DIR)
            local itemAttr = itemFullPath and lfs.attributes(itemFullPath)
            
            if itemAttr and itemAttr.mode == "directory" then
                ponosFile["удалить папку"](itemPath)
            elseif itemFullPath then
                os.remove(itemFullPath)
            end
        end
    end
    lfs.rmdir(fullPath)
    return true
end

ponosFile["переименовать файл"] = function(arg1, arg2, arg3)
    local oldPath, newName, dir
    if arg3 then
        newName, oldPath, dir = arg1, arg2, arg3
    else
        oldPath, newName = arg1, arg2
        dir = oldPath:match("(.+)/[^/]+$") or ""
    end
    
    local np = (dir and dir ~= "") and (dir .. "/" .. newName) or newName
    if ponosFile["проверить существование"](np) then return false end
    
    -- Приоритет: атомарное переименование через OS (безопасно для любых форматов)
    local oldFull = system.pathForFile(oldPath, BASE_DIR)
    local newFull = system.pathForFile(np, BASE_DIR)
    
    if oldFull and newFull then
        local ok = os.rename(oldFull, newFull)
        if ok then return true end
    end
    
    -- Fallback: бинарное копирование + удаление (если os.rename не поддерживается)
    local src = io.open(oldFull, "rb")
    if not src then return false end
    local data = src:read("*a")
    src:close()
    
    local dst = io.open(newFull, "wb")
    if not dst then return false end
    dst:write(data)
    dst:close()
    
    os.remove(oldFull)
    return true
end

ponosFile["переименовать папку"] = function(oldPath, newName)
    if not oldPath or not newName or newName == "" then return false end
    local dir = oldPath:match("(.+)/[^/]+$") or ""
    local newPath = (dir ~= "") and (dir .. "/" .. newName) or newName
    
    local oldFullPath = system.pathForFile(oldPath, BASE_DIR)
    if not oldFullPath then return false end
    local attr = lfs.attributes(oldFullPath)
    if not attr or attr.mode ~= "directory" then return false end
    
    local newFullPath = system.pathForFile(newPath, BASE_DIR)
    if newFullPath and lfs.attributes(newFullPath) then return false end
    
    local success = ponosFile["копировать папку"](oldPath, newPath)
    if success then ponosFile["удалить папку"](oldPath) end
    return success
end

ponosFile["копировать из ресурсов"] = function(resDir, docDir)
    if utils.isSim or utils.isWin then
        local docsPath = system.pathForFile(docDir, system.DocumentsDirectory)
        local resPath = system.pathForFile(resDir, system.ResourceDirectory)
        local file = io.open(resPath, "rb")
        local contents = file:read("*a")
        io.close(file)
        local fileDoc = io.open(docsPath, "wb")
        fileDoc:write(contents)
        io.close(fileDoc)
        return true
    else
        local group = display.newGroup()
        display.newImage(group, resDir)
        display.save(group, {
            filename = docDir,
            baseDir = system.DocumentsDirectory,
            captureOffscreenArea = true,
            backgroundColor = {0, 0, 0, 0}
        })
        display.remove(group)
        return true
    end
end

ponosFile["экспортировать файл"] = function(filePath, listener)
    local IS_SIM = system.getInfo('environment') == 'simulator'
    local IS_WIN = system.getInfo('platform') ~= 'android'
    
    if IS_SIM or IS_WIN then
        timer.performWithDelay(50, function()
            local ok, err = pcall(function()
                local FILEPICKER = require('plugin.tinyfiledialogs')
                local saveTo = FILEPICKER.saveFileDialog({})
                
                if not saveTo then
                    if listener then listener({isError = true, message = "User cancelled"}) end
                    return
                end
                
                if not filePath then
                    if listener then listener({isError = true, message = "Source file is nil"}) end
                    return
                end
                
                local srcFile = io.open(filePath, "rb")
                if not srcFile then
                    if listener then listener({isError = true, message = "Source file not found"}) end
                    return
                end
                srcFile:close()
                
                local src = io.open(filePath, "rb")
                local dst = io.open(saveTo, "wb")
                if not dst then
                    src:close()
                    if listener then listener({isError = true, message = "Cannot write to destination"}) end
                    return
                end
                
                dst:write(src:read("*a"))
                src:close()
                dst:close()
                
                if listener then listener({isError = false, path = saveTo}) end
            end)
            
            if not ok and listener then
                listener({isError = true, message = tostring(err)})
            end
        end)
    else
        native.showPopup("activity", {items = {filePath}, excludedActivities = {}})
        if listener then listener({isError = false, path = filePath}) end
    end
end

local function copyFolderByFullPath(srcFull, dstFull)
    local attr = lfs.attributes(srcFull)
    if not attr or attr.mode ~= "directory" then return false end
    lfs.mkdir(dstFull)
    
    for file in lfs.dir(srcFull) do
        if file ~= "." and file ~= ".." then
            local srcFile = srcFull .. "/" .. file
            local dstFile = dstFull .. "/" .. file
            local fileAttr = lfs.attributes(srcFile)
            
            if fileAttr and fileAttr.mode == "directory" then
                copyFolderByFullPath(srcFile, dstFile)
            else
                local fIn = io.open(srcFile, "rb")
                if fIn then
                    local data = fIn:read("*a")
                    fIn:close()
                    local fOut = io.open(dstFile, "wb")
                    if fOut then
                        fOut:write(data)
                        fOut:close()
                    end
                end
            end
        end
    end
    return true
end

ponosFile["папка в zip"] = function(path, listener)
    local zipAndroid
    if not utils.isWin then zipAndroid = require('plugin.zipAndroid') end
    local zip = require("plugin.zip")
    local tempDir = system.TemporaryDirectory
    local zipName = "export.zip"
    local zipPath = system.pathForFile(zipName, tempDir)
    
    pcall(function() os.removeFolder(system.pathForFile('', tempDir), true) end)
    local srcFullPath = system.pathForFile(path, system.DocumentsDirectory)
    local destFullPath = system.pathForFile('', tempDir)
    copyFolderByFullPath(srcFullPath, destFullPath)
    
    timer.performWithDelay(100, function()
        if utils.isSim or utils.isWin then
            local files = {}
            local function insert_files(currentPath, origPath)
                for file in lfs.dir(currentPath) do
                    if file ~= "." and file ~= ".." then
                        local filePath = currentPath .. "/" .. file
                        local attr = lfs.attributes(filePath)
                        if attr.mode == "directory" then
                            insert_files(filePath, origPath == '' and file or origPath .. '/' .. file)
                        else
                            files[#files + 1] = origPath == '' and file or origPath .. '/' .. file
                        end
                    end
                end
            end
            insert_files(destFullPath, '')
            pcall(function() os.remove(zipPath) end)
            
            zip.compress({
                zipFile = zipName,
                zipBaseDir = tempDir,
                srcBaseDir = tempDir,
                srcFiles = files,
                listener = function(event)
                    if event.isError then
                        if listener then listener({isError = true, message = "Zip compress error"}) end
                    else
                        ponosFile["экспортировать файл"](zipPath, listener)
                    end
                end
            })
        else
            zipAndroid.compress({
                level = 0,
                path = zipPath,
                folder = srcFullPath,
                listener = function(e)
                    if e.isError then
                        if listener then listener({isError = true, message = "Android zip error"}) end
                    else
                        ponosFile["экспортировать файл"](zipPath, listener)
                    end
                end
            })
        end
    end)
end

ponosFile["собрать zip"] = function(path, zipName, listener)
    local zipAndroid
    if not utils.isWin then zipAndroid = require('plugin.zipAndroid') end
    local zip = require("plugin.zip")
    local tempDir = system.TemporaryDirectory
    local finalZipPath = system.pathForFile(zipName, system.DocumentsDirectory)
    
    pcall(function() os.removeFolder(system.pathForFile('', tempDir), true) end)
    local srcPath = system.pathForFile(path, system.DocumentsDirectory)
    local destPath = system.pathForFile('', tempDir)
    ponosFile["копировать папку"](srcPath, destPath)
    
    timer.performWithDelay(100, function()
        if utils.isSim or utils.isWin then
            local files = {}
            local function insert_files(currentPath, origPath)
                for file in lfs.dir(currentPath) do
                    if file ~= "." and file ~= ".." then
                        local filePath = currentPath .. "/" .. file
                        local attr = lfs.attributes(filePath)
                        if attr.mode == "directory" then
                            insert_files(filePath, origPath == '' and file or origPath .. '/' .. file)
                        else
                            files[#files + 1] = origPath == '' and file or origPath .. '/' .. file
                        end
                    end
                end
            end
            insert_files(destPath, '')
            
            local tempZip = "temp_export.zip"
            local tempZipPath = system.pathForFile(tempZip, tempDir)
            pcall(function() os.remove(tempZipPath) end)
            
            zip.compress({
                zipFile = tempZip,
                zipBaseDir = tempDir,
                srcBaseDir = tempDir,
                srcFiles = files,
                listener = function(event)
                    if event.isError then
                        if listener then listener({isError = true, message = "Zip compress error"}) end
                    else
                        ponosFile["копировать файл"](tempDir .. "/" .. tempZip, zipName)
                        pcall(function() os.removeFolder(system.pathForFile('', tempDir), true) end)
                        if listener then listener({isError = false, path = finalZipPath}) end
                    end
                end
            })
        else
            zipAndroid.compress({
                level = 0,
                path = finalZipPath,
                folder = srcPath,
                listener = function(e)
                    if e.isError then
                        if listener then listener({isError = true, message = "Android zip error"}) end
                    else
                        if listener then listener({isError = false, path = finalZipPath}) end
                    end
                end
            })
        end
    end)
end

ponosFile["создать проект"] = function(name, keys)
    if not name or name == "" or #name < 3 then
        new_dialog({
            header = "Ошибка при создании проекта",
            description = "Введенное вами название проекта недопустимо. Придумайте другое.",
        })
        return false
    end
    
    ensureDir(P_DIR .. name)
    ensureDir(P_DIR .. name .. "/scripts")
    ensureDir(P_DIR .. name .. "/levels")
    ensureDir('build/' .. name)
    ensureDir(P_DIR .. name .. "/resources")
    ponosFile["писать путь"](P_DIR .. name .. "/levels/levels.json", "[]")
    
    local data = {}
    for k, v in pairs(default_project) do
        if type(v) == "table" then
            data[k] = {}
            for k2, v2 in pairs(v) do data[k][k2] = v2 end
        else
            data[k] = v
			if keys then if keys[k] then data[k] = keys[k] end end
        end
    end
    data.project_name = name
    
    ponosFile["писать путь"](P_DIR .. name .. "/project.json", json.encode(data))
    return true
end

ponosFile["получить список проектов"] = function()
    local projects = {}
    local basePath = system.pathForFile(P_DIR, BASE_DIR)
    if not basePath then return projects end
    
    for file in lfs.dir(basePath) do
        if file ~= "." and file ~= ".." then
            local projectDir = P_DIR .. file
            local projectFilePath = projectDir .. "/project.json"
            
            if ponosFile["проверить существование"](projectFilePath) then
                local content = ponosFile["читать путь"](projectFilePath)
                if content then
                    local projdat = json.decode(content)
					local data = {}
                    if projdat then
                        local isCorrect = true
                        local requiredDirs = {"scripts", "levels", "resources"}
						local updateData = false
                        
                        for _, dirName in ipairs(requiredDirs) do
                            local dirPath = system.pathForFile(projectDir .. "/" .. dirName, BASE_DIR)
                            if not dirPath or not lfs.attributes(dirPath, "mode") then
                                isCorrect = false
                                break
                            end
                        end
                        
                        if isCorrect and not ponosFile["проверить существование"](projectDir .. "/levels/levels.json") then
                            isCorrect = false
                        end
                        
                        if isCorrect then
                            if type(projdat.project_name) ~= "string" or projdat.project_name == "" or type(projdat.orientation) ~= "string" then
                                isCorrect = false
                            end
                            
                            if isCorrect and type(projdat.display_config) == "table" then
                            else
                                isCorrect = false
                            end
                        end
						
						for key, value in pairs(default_project) do 
						    if projdat[key] == nil then projdat[key] = default_project[key]; updateData = true end
						end 
						
						if updateData then 
						    ponosFile["писать путь"](projectFilePath, json.encode(projdat))
						end
                        
                        data.path = P_DIR .. file
                        data.iscorrect = isCorrect
                        table.insert(projects, {projdat, data})
                    end
                end
            end
        end
    end
    return projects
end

-- Универсальные функции для работы со списками (уровни/скрипты)
local function readList(projectName, subfolder)
    local path = P_DIR .. projectName .. "/" .. subfolder .. "/" .. subfolder .. ".json"
    local content = ponosFile["читать путь"](path)
    if content then
        local success, data = pcall(json.decode, content)
        if success and data then return data end
    end
    return {}
end

local function writeList(projectName, subfolder, list)
    local path = P_DIR .. projectName .. "/" .. subfolder .. "/" .. subfolder .. ".json"
    return ponosFile["писать путь"](path, json.encode(list))
end

local function getNextIndex(projectName, subfolder)
    return #readList(projectName, subfolder) + 1
end

ponosFile["импортировать файл"] = function(fileType, pathSave, callback)
    local function onPickerComplete(event)
        if event.completed or event.isCompleted or event.done == "ok" then
            local sourcePath = event.path or event.filename or event.uri
            if sourcePath then
                local success = ponosFile["копировать файл"](sourcePath, pathSave)
                if callback then callback(success, pathSave) end
            elseif event.done == "ok" then
                -- Обработка импорта через plugin.android.filepicker
                local file = io.open(system.pathForFile("fileimport.json", system.DocumentsDirectory), "r")
                if file then
                    local content = file:read("*a")
                    file:close()
                    json.decode(content)
                    if callback then callback() end
                end
            else
                if callback then callback(false) end
            end
        else
            if callback then callback(false) end
        end
    end
    
    if utils.isWin or utils.isSim then
        if native.showPopup then
            native.showPopup("filePicker", {
                type = fileType,
                listener = function(event)
                    if event.action == "clicked" and event.index == 1 then
                        onPickerComplete({completed = true, path = event.path})
                    else
                        onPickerComplete({completed = false})
                    end
                end
            })
        end
    else
        local success, filePicker = pcall(require, "plugin.android.filepicker")
        if success and filePicker then
            filePicker.show({type = fileType, listener = onPickerComplete})
        end
    end
end

local function copyDir(src, dst)
    local sPath = system.pathForFile(src, BASE_DIR)
    if not sPath then return end
    lfs.mkdir(system.pathForFile(dst, BASE_DIR))
    for file in lfs.dir(sPath) do
        if file ~= "." and file ~= ".." then
            local fSrc = src .. "/" .. file
            local fDst = dst .. "/" .. file
            local attr = lfs.attributes(system.pathForFile(fSrc, BASE_DIR))
            if attr.mode == "directory" then
                copyDir(fSrc, fDst)
            else
                ponosFile["копировать файл"](fSrc, fDst)
            end
        end
    end
end

local function removeDir(path)
    local fullPath = system.pathForFile(path, BASE_DIR)
    if not fullPath then return end
    for file in lfs.dir(fullPath) do
        if file ~= "." and file ~= ".." then
            local fPath = path .. "/" .. file
            local attr = lfs.attributes(system.pathForFile(fPath, BASE_DIR))
            if attr.mode == "directory" then
                removeDir(fPath)
                lfs.rmdir(system.pathForFile(fPath, BASE_DIR))
            else
                os.remove(system.pathForFile(fPath, BASE_DIR))
            end
        end
    end
    lfs.rmdir(fullPath)
end

-- === УРОВНИ ===
ponosFile["создать уровень"] = function(name, projectName)
    if not name or name == "" then
        name = "Уровень " .. getNextIndex(projectName, "levels")
    end
    local idx = getNextIndex(projectName, "levels")
    local fileName = "level_" .. idx .. ".json"
    local levelPath = P_DIR .. projectName .. "/levels/" .. fileName
    local levelData = {title = name, objects = {}, settings = {}}
    
    if not ponosFile["писать путь"](levelPath, json.encode(levelData)) then return false end
    local list = readList(projectName, "levels")
    table.insert(list, {title = name, file = fileName})
    return writeList(projectName, "levels", list)
end

ponosFile["получить список уровней"] = function(p) return readList(p, "levels") end

ponosFile["загрузить уровень"] = function(fileName, projectName)
    local path = P_DIR .. projectName .. "/levels/" .. fileName
    local content = ponosFile["читать путь"](path)
    if content then
        local success, data = pcall(json.decode, content)
        if success and data then return data end
    end
    return nil
end

-- Универсальное сохранение (для уровней и скриптов)
ponosFile["сохранить уровень"] = function(fileName, projectName, levelData, subfolder)
    if not levelData then return false end
    local sub = subfolder or "levels"
    local path = P_DIR .. projectName .. "/" .. sub .. "/" .. fileName
    return ponosFile["писать путь"](path, json.encode(levelData))
end

ponosFile["переместить уровень"] = function(fromIndex, toIndex, projectName)
    local list = readList(projectName, "levels")
    if not list[fromIndex] or not list[toIndex] then return false end
    table.insert(list, toIndex, table.remove(list, fromIndex))
    return writeList(projectName, "levels", list)
end

ponosFile["сохранить порядок уровней"] = function(p, l) return writeList(p, "levels", l) end

ponosFile["дублировать уровень"] = function(fileName, projectName)
    local data = ponosFile["загрузить уровень"](fileName, projectName)
    if not data then return false end
    local list = readList(projectName, "levels")
    local newIdx = #list + 1
    local newFileName = "level_" .. newIdx .. ".json"
    data.title = data.title .. " (копия)"
    
    local newPath = P_DIR .. projectName .. "/levels/" .. newFileName
    if not ponosFile["писать путь"](newPath, json.encode(data)) then return false end
    table.insert(list, {title = data.title, file = newFileName})
    return writeList(projectName, "levels", list)
end

ponosFile["удалить уровень"] = function(fileName, projectName)
    local list = readList(projectName, "levels")
    local idx = nil
    for i, v in ipairs(list) do
        if v.file == fileName then idx = i; break end
    end
    if not idx then return false end
    
    local fullPath = system.pathForFile(P_DIR .. projectName .. "/levels/" .. fileName, BASE_DIR)
    if fullPath then os.remove(fullPath) end
    table.remove(list, idx)
    return writeList(projectName, "levels", list)
end

ponosFile["переименовать уровень"] = function(newName, fileName, projectName)
    local list = readList(projectName, "levels")
    for i, v in ipairs(list) do
        if v.file == fileName then
            list[i].title = newName
            local data = ponosFile["загрузить уровень"](fileName, projectName)
            if data then
                data.title = newName
                ponosFile["сохранить уровень"](fileName, projectName, data)
            end
            return writeList(projectName, "levels", list)
        end
    end
    return false
end

-- === СКРИПТЫ ===
ponosFile["создать скрипт"] = function(name, projectName)
    if not name or name == "" then
        name = app.words[473] .. getNextIndex(projectName, "scripts")
    end
    local idx = getNextIndex(projectName, "scripts")
    local fileName = "script_" .. idx .. ".json"
    local path = P_DIR .. projectName .. "/scripts/" .. fileName
    local data = {title = name, script = {}, user = {}}
    
    if not ponosFile["писать путь"](path, json.encode(data)) then return false end
    local list = readList(projectName, "scripts")
    table.insert(list, {title = name, file = fileName})
    return writeList(projectName, "scripts", list)
end

ponosFile["получить список скриптов"] = function(p) return readList(p, "scripts") end

ponosFile["загрузить скрипт"] = function(fileName, projectName)
    local path = P_DIR .. projectName .. "/scripts/" .. fileName
    local content = ponosFile["читать путь"](path)
    if content then
        local success, data = pcall(json.decode, content)
        if success and data then return data end
    end
    return nil
end

ponosFile["переместить скрипт"] = function(fromIndex, toIndex, projectName)
    local list = readList(projectName, "scripts")
    if not list[fromIndex] or not list[toIndex] then return false end
    table.insert(list, toIndex, table.remove(list, fromIndex))
    return writeList(projectName, "scripts", list)
end

ponosFile["сохранить порядок скриптов"] = function(p, l) return writeList(p, "scripts", l) end

ponosFile["дублировать скрипт"] = function(fileName, projectName)
    local data = ponosFile["загрузить скрипт"](fileName, projectName)
    if not data then return false end
    local list = readList(projectName, "scripts")
    local newIdx = #list + 1
    local newFileName = "script_" .. newIdx .. ".json"
    data.title = data.title .. " " .. app.words[235]
    
    local newPath = P_DIR .. projectName .. "/scripts/" .. newFileName
    if not ponosFile["писать путь"](newPath, json.encode(data)) then return false end
    table.insert(list, {title = data.title, file = newFileName})
    return writeList(projectName, "scripts", list)
end

ponosFile["удалить скрипт"] = function(fileName, projectName)
    local list = readList(projectName, "scripts")
    local idx = nil
    for i, v in ipairs(list) do
        if v.file == fileName then idx = i; break end
    end
    if not idx then return false end
    
    local fullPath = system.pathForFile(P_DIR .. projectName .. "/scripts/" .. fileName, BASE_DIR)
    if fullPath then os.remove(fullPath) end
    table.remove(list, idx)
    return writeList(projectName, "scripts", list)
end

ponosFile["переименовать скрипт"] = function(newName, fileName, projectName)
    local list = readList(projectName, "scripts")
    for i, v in ipairs(list) do
        if v.file == fileName then
            list[i].title = newName
            local data = ponosFile["загрузить скрипт"](fileName, projectName)
            if data then
                data.title = newName
                ponosFile["сохранить уровень"](fileName, projectName, data, "scripts")
            end
            return writeList(projectName, "scripts", list)
        end
    end
    return false
end

ponosFile["получить файлы в проекте"] = function(PATH)
    local result = {}
    local basePath = system.pathForFile(PATH or "", BASE_DIR)
    if not basePath then return result end
    for file in lfs.dir(basePath) do
        if file ~= "." and file ~= ".." then
            table.insert(result, file)
        end
    end
    return result
end

ponosFile["импортировать формат"] = function(path, format, callback)
	import.show(format, system.pathForFile(path, system.DocumentsDirectory), callback)
end