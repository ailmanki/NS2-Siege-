-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Prowler_Server.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

function Prowler:InitWeapons()

    Alien.InitWeapons(self)
    
    --self:GiveItem(VolleyRappel.kMapName)
    self:GiveItem(AcidSpray.kMapName)

    --self:SetActiveWeapon(VolleyRappel.kMapName)
    self:SetActiveWeapon(AcidSpray.kMapName)    
    
end

function Prowler:InitWeaponsForReadyRoom()
    
    Alien.InitWeaponsForReadyRoom(self)
    
    self:GiveItem(ReadyRoomRappel.kMapName)
    self:SetActiveWeapon(ReadyRoomRappel.kMapName)
    
end

function Prowler:GetTierTwoTechId()
    return kTechId.Rappel
end

function Prowler:GetTierThreeTechId()
    return kTechId.Volley --kTechId.AcidSpray
end