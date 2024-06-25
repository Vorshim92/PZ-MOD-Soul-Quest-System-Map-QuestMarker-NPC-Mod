require "ISUI/ISPanel"
require "ISButton"  

local originalISWorldMap_render = ISWorldMap.render;
local originalISWorldMap_createChildren = ISWorldMap.createChildren;
ISWorldMap.showQuestGiver = true  
ISWorldMap.showQuestItem = true  

-- Lista degli NPC con le loro coordinate
local npcList = {
    {name = "Ezekiel Flynn", x = 9327, y = 8596},
    {name = "Elowen Beckett", x = 9324, y = 8598},
    {name = "John Baker", x = 7744, y = 7760},
    {name = "Ethan Steele", x = 10310, y = 8040},
    {name = "Taylor Blaze", x = 7752, y = 7759},
    {name = "Marcus Kane", x = 8574, y = 11026},
    {name = "Brian White", x = 10812, y = 9077},
    {name = "Richard Brown", x = 7178, y = 9739},
    {name = "Robert Wilson", x = 10182, y = 6764},
    {name = "Alex Mercer", x = 3642, y = 7302},
    {name = "Olivia Chambers", x = 4862, y = 11186},
    {name = "Harper Wells", x = 4866, y = 11186},
    {name = "Grace Chambers", x = 13641, y = 4057},
    {name = "Maya Blackwell", x = 3637, y = 7302},
    {name = "Andrew Turner", x = 13630, y = 4069},
    {name = "Lucas Miller", x = 10353, y = 12406},
    {name = "Gabriel Walker", x = 9295, y = 8580},
    {name = "Dylan Harris", x = 13847, y = 10355},
    {name = "Sergente Grif", x = 9331, y = 8640},
    {name = "Angelica Stella", x = 9331, y = 8640},
    {name = "Heather Thomas", x = 9315, y = 8624},
    {name = "Elia Rima", x = 9334, y = 8613},
    {name = "Bob Repair", x = 9340, y = 8578},
    {name = "Mike Pozzo", x = 9315, y = 8638},
    {name = "Rosa China", x = 9270, y = 8491},
    {name = "Emily Terry", x = 9277, y = 8491},
    {name = "Victoria Secret", x = 10824, y = 9070},
    {name = "Dr. Susan Lee", x = 10822, y = 9072},
    {name = "George Scott", x = 10830, y = 9068},
    {name = "Samuel Young", x = 10823, y = 9068},
    {name = "Xu Mishura", x = 10829, y = 9072},
    {name = "David Turner", x = 10839, y = 9071},
    {name = "Tony Lupo", x = 10161, y = 6621},
    {name = "Rafael Prezioso", x = 10155, y = 6623},
    {name = "Jeffrey Lewis", x = 10149, y = 6622},
    {name = "Cristopher Davis", x = 10161, y = 6628},
    {name = "Pamela Perez", x = 10115, y = 6622},
    {name = "Sam Fisher", x = 10151, y = 6588},
    {name = "Juan Baker", x = 3837, y = 7028, benzinaio = true},
    {name = "Furi Mishura", x = 6688, y = 7467, benzinaio = true},
    {name = "Sandra Harris", x = 6684, y = 6820, benzinaio = true},
    {name = "Eric Adams", x = 7659, y = 7316, benzinaio = true},
    {name = "Ronald Perez", x = 8353, y = 8579, benzinaio = true},
    {name = "Garrett King", x = 10399, y = 8316, benzinaio = true},
    {name = "Marvin Perry", x = 8186, y = 11296, benzinaio = true},
    {name = "Karen Taylor", x = 10144, y = 12787, benzinaio = true},
    {name = "Charles Davis", x = 9285, y = 8482, benzinaio = true},
    {name = "Lincoln Reed", x = 9277, y = 8480},
    {name = "Pyno", x = 9332, y = 8605},
    {name = "James Morris", x = 13635, y = 4064}
};
local getQuest = getTexture("media/textures/esclamativo.png")
local completeQuest = getTexture("media/textures/interrogativo.png")
local benzinagive = getTexture("media/textures/benzinagive.png")
local benzinatake = getTexture("media/textures/benzinatake.png")
local clickevent = getTexture("media/textures/clickevent.png")
local hidequest = getTexture("media/textures/hide-quest.png")
local hidequestitem = getTexture("media/textures/hide-quest-star.png")

-- local npcToDraw = {}

function getNPCByName(npcName)
    for _, npc in ipairs(npcList) do
        if npcName == npc.name:gsub(" ", "") then
            return npc
        end
    end
    return nil
end

function ISWorldMap:handleQuestGiver(state)
    self.showQuestGiver = state
end
function ISWorldMap:handleQuestItem(state)
    self.showQuestItem = state
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
end

function ISWorldMap:render()
    originalISWorldMap_render(self)
    
    self.questItemBtn:setImage(self.showQuestItem and clickevent or hidequestitem)
    self.questGiverBtn:setImage(self.showQuestGiver and getQuest or hidequest)

    local player = getPlayer()

    if player:getModData().missionProgress then
        
        
        if player:getModData().missionProgress.WorldEvent and self.showQuestGiver then
            for k, v in pairs(player:getModData().missionProgress.WorldEvent) do
                if v.identity then
                    local npcName = v.identity:match("Questyno_(%a+)")
                    if npcName then
                        local npc = getNPCByName(npcName)
                        if npc then
                            local x = math.floor(self.mapAPI:worldToUIX(npc.x, npc.y))
                            local y = math.floor(self.mapAPI:worldToUIY(npc.x, npc.y))
                            local completed = v.dialoguecode and v.dialoguecode:find("Complete") and true or false
                            if npc.benzinaio then
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
                            self:drawText(npc.name, x - 10, y + 32, 0, 0, 0, 1, UIFont.Small)
                        end
                    end
                end
            end
        end

        if player:getModData().missionProgress.ClickEvent and #player:getModData().missionProgress.ClickEvent > 0 and self.showQuestItem then
            for k, v in ipairs(player:getModData().missionProgress.ClickEvent) do
                if v.square then
                    local x, y = v.square:match("^(%d+)x(%d+)x%d+$")
                    x, y = tonumber(x), tonumber(y)
                    if x and y then
                        local uiX = math.floor(self.mapAPI:worldToUIX(x, y))
                        local uiY = math.floor(self.mapAPI:worldToUIY(x, y))
                        self:drawTextureScaledAspect(clickevent, uiX, uiY, 32, 32, 1, 1, 1, 1)
                        
                        -- Estrazione del nome dell'evento
                        local eventName = v.address:match("^Evento(.+)")
                        if eventName then
                            local textKey = "IGUI_SFQuest_Questyno_" .. eventName .. "_Text"
                            local text = getText(textKey)
                            self:drawText(text, uiX - 35, uiY + 32, 0, 0, 0, 1, UIFont.Small)       
                        end
                    end
                end
            end
        end

    end
end


