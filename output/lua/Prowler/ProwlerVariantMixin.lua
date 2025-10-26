-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\ProwlerVariantMixin.lua
--
-- ==============================================================================================

Script.Load("lua/Globals.lua")

ProwlerVariantMixin = CreateMixin(ProwlerVariantMixin)
ProwlerVariantMixin.type = "ProwlerVariant"

ProwlerVariantMixin.kDefaultModelName = PrecacheAsset("models/alien/prowler/prowler.model")
ProwlerVariantMixin.kDefaultViewModelName = PrecacheAsset("models/alien/prowler/prowler_view.model")
local kProwlerAnimationGraph = PrecacheAsset("models/alien/prowler/prowler.animation_graph")

ProwlerVariantMixin.networkVars =
{
    prowlerVariant = "enum kProwlerVariants",
}

ProwlerVariantMixin.optionalCallbacks =
{
    GetClassNameOverride = "Allows for implementor to specify what Entity class it should mimic",
}

function ProwlerVariantMixin:__initmixin()
    
    PROFILE("ProwlerVariantMixin:__initmixin")
    
    self.prowlerVariant = kDefaultProwlerVariant

    if Client then
        self.dirtySkinState = true
        self.forceSkinsUpdate = true
        self.initViewModelEvent = true
        self.clientProwlerVariant = nil
    end

end

-- For Hallucinations, they don't have a client.
function ProwlerVariantMixin:ForceUpdateModel()
    self:SetModel(self:GetVariantModel(), kProwlerAnimationGraph)
end

function ProwlerVariantMixin:GetVariant()
    return self.prowlerVariant
end

--Only used for Hallucinations
function ProwlerVariantMixin:SetVariant(variant)
    assert(variant)
    assert(kProwlerVariants[variant])
    self.prowlerVariant = variant
end

function ProwlerVariantMixin:GetVariantModel()
    return ProwlerVariantMixin.kDefaultModelName
end

function ProwlerVariantMixin:GetVariantViewModel()
    return ProwlerVariantMixin.kDefaultViewModelName
end

if Server then

    -- Usually because the client connected or changed their options
    function ProwlerVariantMixin:OnClientUpdated(client, isPickup)

        if not Shared.GetIsRunningPrediction() then
            Player.OnClientUpdated( self, client, isPickup )

            local data = client.variantData
            if data == nil then
                return
            end

            if self.GetIgnoreVariantModels and self:GetIgnoreVariantModels() then
                return
            end

            --Note, Skulks use two models for all their skins, Shadow is the only special-case
            if GetHasVariant( kProwlerVariantsData, client.variantData.prowlerVariant, client ) or client:GetIsVirtual() then
                assert(client.variantData.prowlerVariant ~= -1)
                local isModelSwitch = 
                    (
                        (self.prowlerVariant == kProwlerVariants.shadow and client.variantData.prowlerVariant ~= kProwlerVariants.shadow) or
                        (self.prowlerVariant ~= kProwlerVariants.shadow and client.variantData.prowlerVariant == kProwlerVariants.shadow)
                    ) or
                    (
                        (self.prowlerVariant == kProwlerVariants.auric and client.variantData.prowlerVariant ~= kProwlerVariants.auric) or
                        (self.prowlerVariant ~= kProwlerVariants.auric and client.variantData.prowlerVariant == kProwlerVariants.auric)
                    )

                self.prowlerVariant = client.variantData.prowlerVariant

                if isModelSwitch then
                --only when switch going From or To the Shadow skin
                    local modelName = self:GetVariantModel()
                    assert( modelName ~= "" )
                    self:SetModel(modelName, kProwlerAnimationGraph)

                    -- Trigger a weapon skin update, to update the view model
                    self:UpdateWeaponSkin(client)
                end
            else
                Log("ERROR: Client tried to request skulk prowlerVariant they do not have yet")
            end
        end

    end

end


if Client then

    function ProwlerVariantMixin:OnProwlerSkinChanged()
        if self.clientProwlerVariant == self.prowlerVariant and not self.forceSkinsUpdate then
            return false
        end
        
        self.dirtySkinState = true
        
        if self.forceSkinsUpdate then
            self.forceSkinsUpdate = false
        end
    end

    function ProwlerVariantMixin:OnUpdatePlayer(deltaTime)
        PROFILE("ProwlerVariantMixin:OnUpdatePlayer")
        if not Shared.GetIsRunningPrediction() then
            if ( self.clientProwlerVariant ~= self.prowlerVariant ) or ( Client.GetLocalPlayer() == self and self.initViewModelEvent ) then
                self.initViewModelEvent = false --ensure this only runs once
                self:OnProwlerSkinChanged()
            end
        end
    end

    function ProwlerVariantMixin:OnModelChanged(hasModel)
        if hasModel then
            self.forceSkinsUpdate = true
            self:OnProwlerSkinChanged()
        end
    end

    function ProwlerVariantMixin:OnUpdateViewModelEvent()
        self.forceSkinsUpdate = true
        self:OnProwlerSkinChanged()
    end

    local kMaterialIndex = 0 --same for world & view
    local kViewMaterialHornIndex = 0
    local kViewMaterialBodyIndex = 1

    function ProwlerVariantMixin:OnUpdateRender()
        PROFILE("ProwlerVariantMixin:OnUpdateRender")

        if self.dirtySkinState then
        --Note: overriding with the same material, doesn't perform changes to RenderModel

            local className = self.GetClassNameOverride and self:GetClassNameOverride() or self:GetClassName()

            --Handle world model
            local worldModel = self:GetRenderModel()
            if worldModel and worldModel:GetReadyForOverrideMaterials() then

                if self.prowlerVariant ~= kDefaultProwlerVariant and self.prowlerVariant ~= kProwlerVariants.shadow then

                    local worldMat = GetPrecachedCosmeticMaterial( className, self.prowlerVariant )
                    worldModel:SetOverrideMaterial( kMaterialIndex, worldMat )

                else
                --reset model materials to baked/compiled ones
                    worldModel:ClearOverrideMaterials()
                end
                
                self:SetHighlightNeedsUpdate()
            else
                return false--bail now, so we can try again (model not fully loaded)
            end

            --Handle View model
            if self:GetIsLocalPlayer() then

                local viewModelEnt = self:GetViewModelEntity()
                if viewModelEnt then

                    local viewModel = viewModelEnt:GetRenderModel()
                    if viewModel and viewModel:GetReadyForOverrideMaterials() then

                        if self.prowlerVariant ~= kDefaultProwlerVariant and self.prowlerVariant ~= kProwlerVariants.shadow then
                            local viewMat = GetPrecachedCosmeticMaterial( className, self.prowlerVariant, true )
                            viewModel:SetOverrideMaterial( kViewMaterialHornIndex, viewMat[1] )
                            viewModel:SetOverrideMaterial( kViewMaterialBodyIndex, viewMat[2] )
                        else
                        --Default and Shadow model use bot default view model and default textures
                            viewModel:ClearOverrideMaterials()
                        end

                    else
                        return false
                    end

                    viewModelEnt:SetHighlightNeedsUpdate()
                end
            end

            self.dirtySkinState = false
            self.clientProwlerVariant = self.prowlerVariant
        end

    end

end
