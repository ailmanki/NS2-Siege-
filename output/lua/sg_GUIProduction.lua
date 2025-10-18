local function createTech(self, list, techId)

    local tech = list:Create(techId)
    tech.ResearchTime = LookupTechData(techId, kSg_TechDataResearchTimeKey, 1)
    
    local techTree = GetTechTree()
    local techNode
    if techTree then techNode = techTree:GetTechNode(techId) end
    if techNode then tech.researchProgress = techNode:GetResearchProgress() end
    if tech.researchProgress then 
        tech.StartTime = Shared.GetTime() - tech.researchProgress * tech.ResearchTime
    else
        tech.StartTime = Shared.GetTime()
    end
    
    local isMarine = self.TeamIndex == kTeam1Index
    
    local background = tech.Background
    if isMarine then
        background:SetTexture("ui/marine_buildmenu_buttonbg.dds")
    else
        background:SetTexture("ui/alien_buildmenu_buttonbg.dds")
    end
    background:SetSize(kIconSize)
    
    local iconItem = GUIManager:CreateGraphicItem()
    iconItem:SetTexture("ui/buildmenu.dds")
    iconItem:SetSize(kIconSize)
    iconItem:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(techId, isMarine)))
    iconItem:SetColor(kIconColors[self.TeamIndex])
    background:AddChild(iconItem)
    tech.Icon = iconItem
    
    local researchBarBack = GUIManager:CreateGraphicItem()
    researchBarBack:SetIsVisible(false)
    researchBarBack:SetColor(kResearchBackColor)
    researchBarBack:SetSize(Vector(kResearchBarWidth, kResearchBarHeight, 0))
    researchBarBack:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    researchBarBack:SetPosition(Vector(1,1,0))
    background:AddChild(researchBarBack)
    tech.ResearchBarBack = researchBarBack
    
    local researchBar = GUIManager:CreateGraphicItem()
    researchBar:SetColor(kResearchColor)
    researchBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    researchBarBack:AddChild(researchBar)
    tech.ResearchBar = researchBar
    
    return tech
    
end