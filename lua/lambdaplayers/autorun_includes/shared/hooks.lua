
local IsValid = IsValid
local ipairs = ipairs
local table_remove = table.remove
local RealTime = RealTime
local Left = string.Left
local placeholdercolor = Color( 255,136,0)

if SERVER then

    local hitScales = {
        [HITGROUP_HEAD]     = GetConVar("sk_player_head"),
        [HITGROUP_LEFTARM]  = GetConVar("sk_player_arm"),
        [HITGROUP_RIGHTARM] = GetConVar("sk_player_arm"),
        [HITGROUP_CHEST]    = GetConVar("sk_player_chest"),
        [HITGROUP_STOMACH]  = GetConVar("sk_player_stomach"),
        [HITGROUP_LEFTLEG]  = GetConVar("sk_player_leg"),
        [HITGROUP_RIGHTARM] = GetConVar("sk_player_leg")
    }
    hook.Add("ScalePlayerDamage", "LambdaPlayers_DmgScale", function( ply,hit,dmginfo )
        if !ply.IsLambdaPlayer or !dmginfo:IsBulletDamage() then return end
        if hit == HITGROUP_HEAD then
            dmginfo:ScaleDamage( 0.5 )
        elseif hit == HITGROUP_LEFTARM or hit == HITGROUP_RIGHTARM or hit == HITGROUP_LEFTLEG or hit == HITGROUP_RIGHTLEG then
            dmginfo:ScaleDamage( 4 )
        end
        dmginfo:ScaleDamage( ( hitScales[ hit ] and hitScales[ hit ]:GetFloat() or 1.0 ) )
    end)

elseif CLIENT then
    
    local DrawText = draw.DrawText
    local tostring = tostring

    hook.Add( "HUDPaint", "LambdaPlayers_NameDisplay", function()
        local sw, sh = ScrW(), ScrH()
        local traceent = LocalPlayer():GetEyeTrace().Entity


        if LambdaIsValid( traceent ) and traceent.IsLambdaPlayer then
            local name = traceent:GetLambdaName()
            local colvec = traceent:GetPlyColor()
            local hp = traceent:GetNW2Float( "lambda_health", "NAN" )
            
            DrawText( name, "lambdaplayers_displayname", sw / 2, sh / 1.95, placeholdercolor, TEXT_ALIGN_CENTER )
            DrawText( tostring( hp ) .. "%", "ChatFont", sw / 2, sh / 1.87, placeholdercolor, TEXT_ALIGN_CENTER)
        end
    
    end )

    -- Zeta's old voice pop up
    local function LegacyVoicePopUp( x, y, name, icon, volume, alpha )
        if #name > 17 then name = Left( name, 17 ) .. "..." end

        local popupColor = Color(0, 255 * volume, 0, alpha )
        draw.RoundedBox(4, x, y, 230, 50, popupColor)
        surface.SetDrawColor( Color(255, 255, 255, alpha ) )
        surface.SetMaterial( icon )
        surface.DrawTexturedRect(x + 5, y + 9, 32, 32)
        draw.DrawText( name, "VoicePopupText", x + 40, y + 12, Color( 255, 255, 255, alpha ), TEXT_ALIGN_LEFT )
    end

    -- Lambda's newer and accurate Voice Pop up
    local function LambdaVoicePopUp( x, y, name, icon, volume, alpha )
        if #name > 20 then name = Left( name, 20 ) .. "..." end
        
        local popupColor = Color(0, 255 * volume, 0, alpha )
        draw.RoundedBox(4, x - 24, y, 250, 40, popupColor)
        surface.SetDrawColor( Color(255, 255, 255, alpha ) )
        surface.SetMaterial( icon )
        surface.DrawTexturedRect(x - 19, y + 5, 32, 32)
        draw.DrawText( name, "VoicePopupText", x + 16, y + 7, Color( 255, 255, 255, alpha ), TEXT_ALIGN_LEFT )
    end

    local allowvoicepopups = GetConVar( "lambdaplayers_voice_voicepopups" )
    local xvar = GetConVar( "lambdaplayers_voice_voicepopupxpos" )
    local yvar = GetConVar( "lambdaplayers_voice_voicepopupypos" )

    hook.Add( "HUDPaint", "lambdaplayervoicepopup", function()
        if !allowvoicepopups:GetBool() then return end

        for k, v in ipairs( _LAMBDAPLAYERS_Voicechannels ) do
            local w, h = ScrW(), ScrH()
            local x, y = ( w - xvar:GetFloat() ), ( h - yvar:GetFloat() )
            y = y + k*-60

            v[ "alpha" ] = v[ "alpha" ] or 245

            local volume = 0
            local invalid = false
            local snd = v[ 1 ]
            local name, icon, length = v[ 2 ], v[ 3 ], RealTime() + v[ 4 ]
            if !IsValid( snd ) or snd:GetState() == GMOD_CHANNEL_STOPPED then
                invalid = true
            else 
                local l, r = snd:GetLevel()
                volume = l + r
            end

            if RealTime() > length or invalid then
                v[ "alpha" ] = v[ "alpha" ] - 1
            end

            if v[ "alpha" ] <= 0 then
                table_remove( _LAMBDAPLAYERS_Voicechannels, k )
            else

                LambdaVoicePopUp( x, y, name, icon, volume, v[ "alpha" ] )

            end
        end
    end )


end