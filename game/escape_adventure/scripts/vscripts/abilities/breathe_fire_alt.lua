breathe_fire_alt = class({})

--------------------------------------------------------------------------------

function breathe_fire_alt:OnSpellStart()
	self.start_radius = self:GetSpecialValueFor( "start_radius" )
	self.end_radius = self:GetSpecialValueFor( "end_radius" )
	self.speed = self:GetSpecialValueFor( "speed" )
	self.fire_damage = self:GetSpecialValueFor( "fire_damage" ) 	
	

	local vPos = nil
	if self:GetCursorTarget() then
		vPos = self:GetCursorTarget():GetOrigin()
	else
		vPos = self:GetCursorPosition()
	end
	self.range = (self:GetCaster():GetOrigin() - vPos):Length2D()

	local vDirection = vPos - self:GetCaster():GetOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()

	self.speed = self.speed * ( ( self.range ) / ( self.range -self.start_radius ) )

--	local effect_name = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf"
	local effect_name = "particles/fire_trap/trap_breathe_fire.vpcf"

	local info = {
		EffectName = effect_name,
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(), 
		fStartRadius = self.start_radius,
		fEndRadius = self.end_radius,
		vVelocity = vDirection * self.speed,
		fDistance = self.range,
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	}

	ProjectileManager:CreateLinearProjectile( info )
	
--	EmitSoundOn( "Conquest.FireTrap.Generic", self:GetCaster() )
	self:GetCaster():EmitSound( "Conquest.FireTrap.Generic")
end

--------------------------------------------------------------------------------

function breathe_fire_alt:OnProjectileHit( hTarget, vLocation )
	local fireDamage = self.fire_damage

	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then

		local damageSource = self:GetCaster()
		if self:GetCaster() ~= nil and self:GetCaster().KillerToCredit ~= nil then
			damageSource = self:GetCaster().KillerToCredit
		end

		local damage = {
			victim = hTarget,
			attacker = damageSource,
			damage = fireDamage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}

		ApplyDamage( damage )
	end

	return false
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------