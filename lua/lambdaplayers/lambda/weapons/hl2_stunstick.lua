local IsValid = IsValid
local util_Effect = util.Effect

local stunstickGlow = Material("effects/blueflare1")

table.Merge( _LAMBDAPLAYERSWEAPONS, {

    stunstick = {
        model = "models/weapons/w_stunbaton.mdl",
        origin = "Half-Life 2",
        prettyname = "Stunstick",
        holdtype = "melee",
        killicon = "weapon_stunstick",
        ismelee = true,
        bonemerge = true,
        keepdistance = 40,
        attackrange = 55,
        dropentity = "weapon_stunstick",

        damage = 40,
        rateoffiremin = 0.8,
        rateoffiremax = 1.25,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE,
        attacksnd = "Weapon_StunStick.Swing",
        hitsnd = "Weapon_StunStick.Melee_Hit",
        
        -- Custom effect similar to player stunstick
        OnDraw = function( lambda, wepent )
            if IsValid( wepent ) then

                local size = LambdaRNG( 4, 6 )
                local drawPos = ( wepent:GetPos() - wepent:GetForward() * 12 - wepent:GetRight() + wepent:GetUp() )
                local color = Color( 255, 255, 255 )

                render.SetMaterial( stunstickGlow )
                render.DrawSprite( drawPos, size*2, size*2, color)

            end
        end,
        
        OnDeploy = function( lambda, wepent )
            wepent:EmitSound( "Weapon_StunStick.Activate" )
        end,
        
        -- Emit sparks on hit
        OnAttack = function( self, wepent, target )
            if !IsValid( target ) then return end -- Some things never change eh?
            
            local effect = EffectData( )
                effect:SetOrigin( target:WorldSpaceCenter() ) -- World space center is the same as GetPos + ObbCenter
                effect:SetMagnitude( 1 )
                effect:SetScale( 2 )
                effect:SetRadius( 4 )
            util_Effect( "StunstickImpact", effect, true, true)

            return false
        end,

        islethal = true,
    }

})