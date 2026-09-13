local m = {}
local tr, ez, tm = transition, easing, timer
local scenesRoot, overlaysRoot = display.newGroup(), display.newGroup()
overlaysRoot:toFront()

local active, gen, lock = {}, {}, {}
local scenes, sceneOrder = {}, {}
local overlays, overlayOrder = {}, {}
local tags, history = {}, {}
local alwaysCache, devToolsGroup = {}, nil

local threads, threadOfCo = {}, {}

local function track(id,h,t) active[id]=active[id] or {}; active[id][#active[id]+1]={h=h,_t=t} end
local function kill(id) local l=active[id]; if not l then return end for i=#l,1,-1 do local p=l[i]; if p._t=="tr" then tr.cancel(p.h) else tm.cancel(p.h) end; table.remove(l,i) end end
local function easingOf(e) return type(e)=="function" and e or ez[e] or ez.linear end
local function safeRemove(o) if o and o.removeSelf then o:removeSelf() end end
local function isValid(o) return o and o.removeSelf and o.stage end
local function last(order) return order[#order] end
local function push(order,id) for i=#order,1,-1 do if order[i]==id then table.remove(order,i) end end order[#order+1]=id end
local function splitName(id) local t={} for s in id:gmatch("[^:]+") do t[#t+1]=s end return t end
local function subKey(parts) return #parts>1 and table.concat(parts,"_",2) or nil end

m.defaultSettings=app.SceneDefaultSettings or {time=450,transition="zoomIn",easing="outQuint",path="ponos.scenes",delete=true,cache=true,dimEnabled=true,dimAlpha=0.7,dimColor={0,0,0},slideFactor=0.5,scaleOld=0.9}

-- Эффекты
local effects = {}
local function animate(id,obj,p,gn,fin)
  if not obj then return end
  local u=p.onComplete
  p.onComplete=function(...) if u then u(...) end if gen[id]==gn and fin then fin(...) end end
  track(id,tr.to(obj,p),"tr")
end
effects.none=function(o,n) if n then n.isVisible,n.alpha=1,1 end end
effects.fade=function(o,n,p,d,id,gn) local t,e=p.time or d.time,easingOf(p.easing or d.easing); if n then n.alpha,n.isVisible=0,true; animate(id,n,{time=t,alpha=1,transition=e},gn) end; if o then animate(id,o,{time=t,alpha=0,transition=e},gn) end end
effects.fadeSequential=function(o,n,p,d,id,gn) local t,e=p.time or d.time,easingOf(p.easing or d.easing); local show=function() if n then n.alpha,n.isVisible=0,true; animate(id,n,{time=t,alpha=1,transition=e},gn) end end; if o then animate(id,o,{time=t,alpha=0,transition=e,onComplete=show},gn) else show() end end
effects.slideLeft=function(o,n,p,d,id,gn) local w=sw; local t,e=p.time or d.time,easingOf(p.easing or d.easing); if n then n.isVisible=true;n.x=w;animate(id,n,{time=t,x=0,transition=e},gn) end; if o then animate(id,o,{time=t,x=-w,transition=e},gn) end end
effects.slideRight=function(o,n,p,d,id,gn) local w=sw; local t,e=p.time or d.time,easingOf(p.easing or d.easing); if n then n.isVisible=true;n.x=-w;animate(id,n,{time=t,x=0,transition=e},gn) end; if o then animate(id,o,{time=t,x=w,transition=e},gn) end end
effects.slideUp=function(o,n,p,d,id,gn) local h=sh; local t,e=p.time or d.time,easingOf(p.easing or d.easing); if n then n.isVisible=true;n.y=h;animate(id,n,{time=t,y=0,transition=e},gn) end; if o then animate(id,o,{time=t,y=-h,transition=e},gn) end end
effects.slideDown=function(o,n,p,d,id,gn) local h=sh; local t,e=p.time or d.time,easingOf(p.easing or d.easing); if n then n.isVisible=true;n.y=-h;animate(id,n,{time=t,y=0,transition=e},gn) end; if o then animate(id,o,{time=t,y=h,transition=e},gn) end end
effects.zoomIn=function(o,n,p,d,id,gn) local t,e=p.time or d.time,easingOf(p.easing or d.easing); if n then n.xScale,n.yScale,n.alpha,n.isVisible=0.5,0.5,0,true end; if o then animate(id,o,{time=t,xScale=1.5,yScale=1.5,alpha=0,transition=e},gn) end; if n then animate(id,n,{time=t,xScale=1,yScale=1,alpha=1,transition=e},gn) end end
effects.zoomOut=function(o,n,p,d,id,gn) local t,e=p.time or d.time,easingOf(p.easing or d.easing); if n then n.xScale,n.yScale,n.alpha,n.isVisible=1.5,1.5,0,true end; if o then animate(id,o,{time=t,xScale=0.5,yScale=0.5,alpha=0,transition=e},gn) end; if n then animate(id,n,{time=t,xScale=1,yScale=1,alpha=1,transition=e},gn) end end
effects.scaleFade=function(o,n,p,d,id,gn) local t,e=p.time or d.time,easingOf(p.easing or d.easing); if n then n.xScale,n.yScale,n.alpha,n.isVisible=0.85,0.85,0,true end; if o then animate(id,o,{time=t,xScale=1.05,yScale=1.05,alpha=0,transition=e},gn) end; if n then animate(id,n,{time=t,xScale=1,yScale=1,alpha=1,transition=e},gn) end end

-- Теги
local function attachTags(id,list)
  if not list then return end
  for _,t in ipairs(list) do
    tags[t]=tags[t] or {}
    local dup=false; for _,v in ipairs(tags[t]) do if v==id then dup=true break end end
    if not dup then tags[t][#tags[t]+1]=id end
  end
end
local function detachTags(id)
  for tg,l in pairs(tags) do
    for i=#l,1,-1 do if l[i]==id then table.remove(l,i) end end
    if #l==0 then tags[tg]=nil end
  end
end

-- Разрешение пути
local function resolve(id,d,p)
  local parts=splitName(id)
  local file=parts[1]
  local sub=subKey(parts)
  local base=(p and p.path) or d.path
  local path=(file=="main") and "main" or (base.."."..file)
  return path,sub
end

-- Корутины: создание/очередь/обслуживание
local function clearThread(id)
  local t=threads[id]; if not t then return end
  if t.co then threadOfCo[t.co]=nil end
  threads[id]=nil
end

local function ensureThread(id)
  local t=threads[id]
  if t and t.co then return t end
  local q={}
  local co=coroutine.create(function()
    while true do
      local job=q[1]
      if not job then coroutine.yield("idle")
      else table.remove(q,1); job() end
    end
  end)
  threads[id]={co=co,q=q}
  threadOfCo[co]=id
  return threads[id]
end

local function resumeThread(id)
  local t=threads[id]; if not t or not t.co then return end
  if coroutine.status(t.co)=="dead" then clearThread(id) return end
  local ok,err=coroutine.resume(t.co,"tick")
  if not ok then print("Scene coroutine error:",id,err); clearThread(id) end
end

local function pushJob(id,fn)
  local t=ensureThread(id)
  t.q[#t.q+1]=fn
  resumeThread(id)
end

-- Создание группы и загрузка модуля (без вызова create/show)
local function create(id,parent,p,d)
  if lock[id] then return nil,nil end
  lock[id]=true
  local path,_=resolve(id,d,p)
  local ok,mod=pcall(require,path)
  if not ok then print("Scene require failed:",path,mod); lock[id]=nil; return nil,nil end
  if type(mod)~="table" then mod = package.loaded[path] end
  if type(mod)~="table" then print("Scene module must be table:",path); lock[id]=nil; return nil,nil end
  local g=display.newGroup(); parent:insert(g); g.x,g.y,g.alpha,g.isVisible=0,0,1,true; g._sceneObj=mod
  lock[id]=nil
  return g,mod
end

local function runEffect(name,o,n,p,d,id,gn)
  (effects[name or d.transition] or effects.none)(o,n,p or{},d,id,gn)
end

-- Открытие
local function open(reg,order,parent,id,p,d)
  p=p or{}
  if lock[id] then return reg[id] and reg[id].group end
  kill(id)
  gen[id]=(gen[id] or 0)+1; local gn=gen[id]
  local oldTopId=last(order)
  local oldTop=oldTopId and reg[oldTopId] and reg[oldTopId].group or nil
  local entry=reg[id]
  local cont=(p.delete==false and p.continue==true)
  local allow=(p.cache~=false and d.cache) or alwaysCache[id]
  if entry and allow and cont then
    local g=entry.group
    if g and g.parent then g.isVisible=true; g.alpha=1; g.x,g.y=0,0; g:toFront() end
    runEffect(p.transition or d.transition,(oldTop~=g) and oldTop or nil,g,p,d,id,gn)
    push(order,id)
    attachTags(id,p.tags or entry.tags)
    history[#history+1]={id=id,type=(reg==overlays and "overlay" or "scene")}
    -- Возобновим логику: show можно добавить задачей
    if entry.module and type(entry.module.show)=="function" then pushJob(id,function() entry.module.show(entry.module,p) end) end
    return g
  end
  local path,sub=resolve(id,d,p)
  if p.delete==true and path~="main" then package.loaded[path]=nil end
  local g,mod=create(id,parent,p,d)
  if not g or not mod then print("Open failed:",id); return entry and entry.group end
  reg[id]={name=id,group=g,module=mod,params=p.params,tags=p.tags,sub=sub}
  push(order,id)
  runEffect(p.transition or d.transition,oldTop,g,p,d,id,gn)
  attachTags(id,p.tags)
  history[#history+1]={id=id,type=(reg==overlays and "overlay" or "scene")}
  -- Вызовы create/create_sub и show через корутину-очередь
  if sub then
    local fn=mod["create_"..sub]; if type(fn)=="function" then pushJob(id,function() fn(g,p and p.params) end) end
  else
    if type(mod.create)=="function" then pushJob(id,function() mod.create(g,p and p.params) end) end
  end
  if type(mod.show)=="function" then pushJob(id,function() mod.show(mod,p) end) end
  return g
end

-- Закрытие
local function close(reg,order,id,p,d)
  p=p or{}
  local target=id or last(order)
  if not target then return end
  kill(target)
  gen[target]=(gen[target] or 0)+1; local gn=gen[target]
  local e=reg[target]; if not e or not isValid(e.group) then reg[target]=nil; detachTags(target); clearThread(target); return end
  local g=e.group
  runEffect(p.transition or d.transition,g,nil,p,d,target,gn)
  local h=tm.performWithDelay(p.time or d.time,function()
    -- hide тоже как задача, чтобы внутри него работал wait()
    if e.module and type(e.module.hide)=="function" then pushJob(target,function() e.module.hide(e.module,p) end) end
    -- После постановки hide можно очистить/удалить
    clearThread(target) -- завершаем корутину (hide отработает в новой очереди до очистки визуально)
    if p.delete==false or alwaysCache[target] then
      g.isVisible=false; g.alpha=1; g.x,g.y,g.xScale,g.yScale=0,0,1,1
    else
      safeRemove(g); reg[target]=nil; detachTags(target)
    end
    for i=#order,1,-1 do if order[i]==target then table.remove(order,i) end end
  end)
  track(target,h,"tm")
end

-- Утилиты
local function getGroup(reg,order,id) local target=id or last(order); local e=target and reg[target] or nil; return e and e.group or nil end
local function setParams(reg,order,id,params)
  local target=id or last(order); local e=target and reg[target] or nil; if not e then return end
  e.params=params
  local mo=e.module
  if not mo then return end
  if type(mo.setParams)=="function" then pushJob(target,function() mo.setParams(mo,params) end)
  elseif type(mo.params)=="function" then pushJob(target,function() mo.params(mo,params) end)
  elseif type(mo.onParams)=="function" then pushJob(target,function() mo.onParams(mo,params) end)
  end
end
local function getParams(reg,order,id) local target=id or last(order); local e=target and reg[target] or nil; return e and e.params or nil end

-- API
function m.newScene(id,p) local g=open(scenes,sceneOrder,scenesRoot,id,p,m.defaultSettings); overlaysRoot:toFront(); return g end
function m.newOverlay(id,p) local g=open(overlays,overlayOrder,overlaysRoot,id,p,m.defaultSettings); overlaysRoot:toFront(); return g end

function m.goto(id,p)
  p=p or{}
  local current=last(sceneOrder)
  local cont=(p.continue==true and p.delete==false)
  if current and not cont then m.closeScene(nil,p) end
  return m.newScene(id,p)
end
function m.gotoOverlay(id,p)
  p=p or{}
  local current=last(overlayOrder)
  local cont=(p.continue==true and p.delete==false)
  if current and not cont then m.closeOverlay(nil,p) end
  return m.newOverlay(id,p)
end

function m.closeScene(id,p) close(scenes,sceneOrder,id,p,m.defaultSettings); overlaysRoot:toFront() end
function m.closeOverlay(id,p) close(overlays,overlayOrder,id,p,m.defaultSettings); overlaysRoot:toFront() end

function m.setParamsScene(id,params) setParams(scenes,sceneOrder,id,params) end
function m.setParamsOverlay(id,params) setParams(overlays,overlayOrder,id,params) end
function m.getParamsScene(id) return getParams(scenes,sceneOrder,id) end
function m.getParamsOverlay(id) return getParams(overlays,overlayOrder,id) end
function m.getScene(id) return getGroup(scenes,sceneOrder,id) end
function m.getOverlay(id) return getGroup(overlays,overlayOrder,id) end
function m.getCurrentSceneName() return last(sceneOrder) end
function m.getCurrentOverlayName() return last(overlayOrder) end
function m.addEffect(name,fn) effects[name]=fn end
function m.addEffectNames() local l={} for k in pairs(effects) do l[#l+1]=k end return l end

function m.getScenesByTag(tag) local r={} for _,id in ipairs(tags[tag] or {}) do local e=scenes[id]; if e and e.group then r[#r+1]=e.group end end return r end
function m.getSceneByTag(tag) local a=m.getScenesByTag(tag) return a and a[1] end
function m.closeByTag(tag) local a=tags[tag]; if not a then return end for _,id in ipairs(a) do m.closeScene(id,{}) end tags[tag]=nil end

function m.getHistory() return history end
function m.clearHistory() history={} end
function m.back()
  if #history<=1 then return end
  local cur=table.remove(history)
  if cur.type=="overlay" then m.closeOverlay(cur.id,{delete=true}) else m.closeScene(cur.id,{delete=true}) end
  local prev=history[#history]; if not prev then return end
  if prev.type=="overlay" then m.gotoOverlay(prev.id,{delete=false,continue=true}) else m.goto(prev.id,{delete=false,continue=true}) end
end
function m.jumpTo(i)
  local e=history[i]; if not e then return end
  if e.type=="overlay" then m.gotoOverlay(e.id,{delete=false,continue=true}) else m.goto(e.id,{delete=false,continue=true}) end
end

function m.devTools()
  if devToolsGroup and devToolsGroup.removeSelf then devToolsGroup:removeSelf() end
  devToolsGroup=display.newGroup(); overlaysRoot:insert(devToolsGroup)
  local bg=display.newRect(devToolsGroup,display.contentCenterX,display.contentCenterY,display.actualContentWidth,display.actualContentHeight)
  bg:setFillColor(0,0,0,0.6)
  local y=40
  local function line(t) local tx=display.newText(devToolsGroup,t,display.contentCenterX,y,native.systemFont,14); tx:setFillColor(1,1,1); y=y+20 end
  line("DevTools")
  line("Scenes:"); for i,id in ipairs(sceneOrder) do line(i..": "..id) end
  line("Overlays:"); for i,id in ipairs(overlayOrder) do line(i..": "..id) end
  line("Tags:"); for tg,list in pairs(tags) do line(tg.." -> "..table.concat(list,",")) end
  line("History:"); for i,e in ipairs(history) do line(i..": "..e.id.." ["..e.type.."]") end
  devToolsGroup:toFront(); return devToolsGroup
end
function m.closeDevTools() if devToolsGroup and devToolsGroup.removeSelf then devToolsGroup:removeSelf() end devToolsGroup=nil end

function m.preload(spec,opts)
  opts=opts or{}
  local base={cache=true,delete=false,transition="none",time=0,path=(opts.path or m.defaultSettings.path)}
  local function preloadOne(reg,ord,parent,id)
    if reg[id] and reg[id].group then return end
    local g=open(reg,ord,parent,id,base,m.defaultSettings)
    if g then g.isVisible=false end
    for i=#ord,1,-1 do if ord[i]==id then table.remove(ord,i) end end
  end
  if spec.scenes then for _,n in ipairs(spec.scenes) do preloadOne(scenes,sceneOrder,scenesRoot,n) end end
  if spec.subscenes then for _,pair in ipairs(spec.subscenes) do preloadOne(scenes,sceneOrder,scenesRoot,pair[1]..":"..pair[2]) end end
  if spec.overlays then for _,n in ipairs(spec.overlays) do preloadOne(overlays,overlayOrder,overlaysRoot,n) end end
end

function m.addAlwaysCacheScene(id) alwaysCache[id]=true end
function m.removeAlwaysCacheScene(id) alwaysCache[id]=nil end

_G.wait=function(ms)
  ms=ms or 0
  local co=coroutine.running()
  if not co then return end
  local id=threadOfCo[co]; if not id then return end
  local h=tm.performWithDelay(ms,function() resumeThread(id) end)
  track(id,h,"tm")
  return coroutine.yield("wait")
end

return m