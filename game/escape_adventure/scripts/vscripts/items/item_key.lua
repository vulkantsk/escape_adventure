LinkLuaModifier( "modifier_item_key_simple", "items/item_key", 0 )
LinkLuaModifier( "modifier_item_key_enique", "items/item_key", 0 )


item_key_simple = class{}

function item_key_simple:GetIntrinsicModifierName()
	return "modifier_item_key_simple"
end


modifier_item_key_simple = class({
    IsHidden                = function(self) return true end,
    GetAttributes           = function(self) return 
    	MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE 
    end,
    DeclareFunctions        = function(self) return 
        {
           MODIFIER_EVENT_ON_DEATH,
        } end,

})


function modifier_item_key_simple:OnDeath(data)
		local unit = data.unit
		local hAbility = self:GetAbility()
		local caster = self:GetCaster()
	    local vLocation = caster:GetAbsOrigin()

	    if unit == caster then 	            
	        caster:DropItemAtPositionImmediate(hAbility, vLocation)
	    end
end

item_key_enique = class{}

function item_key_enique:GetIntrinsicModifierName()
	return "modifier_item_key_enique"
end


modifier_item_key_enique = class({
    IsHidden                = function(self) return true end,
    GetAttributes           = function(self) return 
    	MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE 
    end,
    DeclareFunctions        = function(self) return 
        {
           MODIFIER_EVENT_ON_DEATH,
        } end,

})


function modifier_item_key_enique:OnDeath(data)
		local unit = data.unit
		local hAbility = self:GetAbility()
		local caster = self:GetCaster()
	    local vLocation = hAbility.spawn_point or caster:GetAbsOrigin()

	    if unit == caster then 	            
	        caster:DropItemAtPositionImmediate(hAbility, vLocation)
	    end
end
