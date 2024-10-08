require "ISUI/ISPanel"
require "ISButton"  
require "SFQuest_Database"

-- SFQuest_Database.WorldPool use this table of npcs
-- example:
-- SFQuest_Database.WorldPool, {
--     identity = "Questyno_Grif",
--     square = "9331x8640x0",
--     name = "IGUI_SFQuest_Questyno_Grif_Name",
--     faction = "LaResistenza",
--     picture = "media/textures/Picture_Grif.png",
-- } 
-- we can use getText(name)

-- temp.WorldEvent['8353x8579x1']={}
-- temp.WorldEvent['8353x8579x1'].identity='Questyno_RonaldPerez';
-- temp.WorldEvent['8353x8579x1'].dialoguecode='SFQuest_Questyno_RonaldPerez_Begin';
-- temp.WorldEvent['8353x8579x1'].quest='Questyno_RonaldPerez';


-- temp.ClickEvent[1]={}
-- temp.ClickEvent[1].square='8757x6545x0';
-- temp.ClickEvent[1].address='EventoAngelicaStella13';
-- temp.ClickEvent[1].actiondata='time;50;anim;loot';
-- temp.ClickEvent[1].commands='updateobjective;Questyno_AngelicaStella13;1;Completed';

--we can improve this database with more proprieties like the npc role (benzinaio)

local originalISWorldMap_render = ISWorldMap.render;
local originalISWorldMap_createChildren = ISWorldMap.createChildren;
ISWorldMap.showQuestGiver = true  
ISWorldMap.showQuestItem = true  

local npcWorldDb = SFQuest_Database.WorldPool


-- Lista degli NPC con le loro coordinate

local getQuest = getTexture("media/textures/esclamativo.png")
local completeQuest = getTexture("media/textures/interrogativo.png")
local benzinagive = getTexture("media/textures/benzinagive.png")
local benzinatake = getTexture("media/textures/benzinatake.png")
local clickevent = getTexture("media/textures/clickevent.png")
local hidequest = getTexture("media/textures/hide-quest.png")
local hidequestitem = getTexture("media/textures/hide-quest-star.png")

-- local npcToDraw = {}



function ISWorldMap:handleQuestGiver(state)
    self.showQuestGiver = state
end
function ISWorldMap:handleQuestItem(state)
    self.showQuestItem = state
end





local function getWorldEventProgress()
    local tempWorldEvent = {}
    local player = getPlayer()
    if player:getModData().missionProgress and player:getModData().missionProgress.WorldEvent then
        for k2,v2 in pairs(player:getModData().missionProgress.WorldEvent) do
            local squareTable = luautils.split(k2, "x");
            local x, y, z = tonumber(squareTable[1]), tonumber(squareTable[2]), tonumber(squareTable[3]);
            local completed = v2.dialoguecode and v2.dialoguecode:find("Complete") and true or false
            local npcName = v2.identity
            -- print("WorldEvent: ", k2, npcName)
            local gas_station_attendant = false

            for k, v in pairs(npcWorldDb) do
                if v.identity == npcName then
                    npcName = getText(v.name)
                    -- print("trovato npc: ", npcName)
                    if v.occupation == "gas_station_attendant" then
                        gas_station_attendant = true
                    end
                    break
                end
            end

            table.insert(tempWorldEvent, {
                x = x,
                y = y,
                name = npcName,
                completed = completed,
                gas_station_attendant = gas_station_attendant
            })
            -- print("tempWorldEvent inserito in tabella con nome: ", npcName)
        end
    end
    return tempWorldEvent
end

local function getClickEventProgress()
    local tempClickEvent = {}
    local player = getPlayer()
    if player:getModData().missionProgress and player:getModData().missionProgress.ClickEvent then
        for k2, v2 in ipairs(player:getModData().missionProgress.ClickEvent) do
            local squareTable = luautils.split(v2.square, "x");
            local x, y, z = tonumber(squareTable[1]), tonumber(squareTable[2]), tonumber(squareTable[3]);
            -- dal commands del ClickEvent acquisisco il guid della quest attiva (category2)
            local commands = luautils.split(v2.commands, ";");
            local questId = commands[2]
            -- print("clickevent per questId: ", questId)
            local clickEventName = ""
            for k, v in ipairs(player:getModData().missionProgress.Category2) do
                if v.guid == questId then
                    clickEventName = getText(v.text)
                    -- print("clickEventName: ", clickEventName)
                    break
                end
            end

            table.insert(tempClickEvent, {
                x = x,
                y = y,
                name = clickEventName
            })
            -- print("tempClickEvent inserito in tabella con nome: ", clickEventName)
        end
    end
    return tempClickEvent
end

local worldEventDb = {}
local clickEventDb = {}

local originalISWorldMap_ShowWorldMap = ISWorldMap.ShowWorldMap
function ISWorldMap:ShowWorldMap(...)
    originalISWorldMap_ShowWorldMap(self, ...)
    worldEventDb = getWorldEventProgress()
    clickEventDb = getClickEventProgress()
    print("dentro ShowWorldMap")
end

function ISWorldMap:createChildren(...)
    originalISWorldMap_createChildren(self, ...)
    
    self.questGiverBtn = ISButton:new(self.width - 20 - 456, self.height - 20 - 48, 48, 48, "", self, function(self) self:handleQuestGiver(not self.showQuestGiver) end)
    self.questGiverBtn:setImage(self.showQuestGiver and getQuest or hidequest)
    self.questGiverBtn:initialise()
    self.questGiverBtn:instantiate()
    self:addChild(self.questGiverBtn)
    self.questItemBtn = ISButton:new(self.width - 20 - 524, self.height - 20 - 48, 48, 48, "", self, function(self) self:handleQuestItem(not self.showQuestItem) end)
    self.questItemBtn:setImage(self.showQuestItem and clickevent or hidequestitem)
    self.questItemBtn:initialise()
    self.questItemBtn:instantiate()
    self:addChild(self.questItemBtn)
    -- self.worldEventDb = getWorldEventProgress()
    -- self.clickEventDb = getClickEventProgress()
    -- print("dentro createChildren")
    -- a quanto pare non viene richiamato ogni volta che viene riaperta la mappa
end


function ISWorldMap:render()
    originalISWorldMap_render(self)
    
    self.questItemBtn:setImage(self.showQuestItem and clickevent or hidequestitem)
    self.questGiverBtn:setImage(self.showQuestGiver and getQuest or hidequest)

    if worldEventDb and #worldEventDb > 0 and self.showQuestGiver then
        -- print("dentro render worldEventDb")
        for i, v in ipairs(worldEventDb) do    
            local x = math.floor(self.mapAPI:worldToUIX(v.x, v.y))
            local y = math.floor(self.mapAPI:worldToUIY(v.x, v.y))
            local completed = v.completed
            if v.gas_station_attendant then
                if completed then
                    self:drawTextureScaledAspect(benzinagive, x, y, 32, 32, 1, 1, 1, 1)
                else
                    self:drawTextureScaledAspect(benzinatake, x, y, 32, 32, 1, 1, 1, 1)
                end
            else
                if completed then
                    self:drawTextureScaledAspect(completeQuest, x, y, 32, 32, 1, 1, 1, 1)
                else
                    self:drawTextureScaledAspect(getQuest, x, y, 32, 32, 1, 1, 1, 1)
                end
            end
            self:drawText(v.name, x - 10, y + 32, 0, 0, 0, 1, UIFont.Small)
        end
    end
    if clickEventDb and #clickEventDb > 0 and self.showQuestItem then
        -- print("dentro render clickEventDb")
        for i, v in ipairs(clickEventDb) do    
            local x = math.floor(self.mapAPI:worldToUIX(v.x, v.y))
            local y = math.floor(self.mapAPI:worldToUIY(v.x, v.y))
            local name = v.name
            self:drawTextureScaledAspect(clickevent, x, y, 32, 32, 1, 1, 1, 1)
            self:drawText(name, x - 35, y + 32, 0, 0, 0, 1, UIFont.Small)       
        end
    end
end


