MINIGAME.name = "Styles"
MINIGAME.color = COLOR_GOLD
MINIGAME.default_state = "Playing"
MINIGAME.default_player_class = "Stylist"
MINIGAME.required_players = 0

hook.Add("CreateMinigameHookSchemas", "Styles", function()
    MinigameNetService.CreateHookSchema("SetStyle", {"entity", "string"})
end)

MINIGAME:AddPlayerClass({
    name = "Stylist",
    display_name = false
}, {
    active_style = "default",
    float_force = 450
})

MINIGAME:RemoveAdjustableSetting "states.Playing.time"

function MINIGAME.player_classes.Stylist:SetupMove(move)
    if not GhostService.Alive(self) then return end

    if move:KeyDown(IN_ATTACK) then
        if self.active_style == "unreal" then
            local vel = move:GetVelocity()

            local aimVector = self:EyeAngles():Forward()
            aimVector.z = 0
            aimVector:Normalize()

            local push = aimVector * (1000 * FrameTime())
            move:SetVelocity(vel + push)
        elseif self.active_style == "float" then
            self.floatSound = CreateSound(self, "npc/manhack/mh_engine_loop1.wav")
            self.floatSound:PlayEx(0.3,100)

            
            if AiraccelService.HasStamina(self) then
                local vel = move:GetVelocity()
                vel.z = vel.z + self.float_force * FrameTime()
                move:SetVelocity(vel)
                
            end
        end
    end
    if move:KeyReleased(IN_ATTACK) then
        if self.floatSound then
            self.floatSound:Stop()
            self.floatSound = nil
        end
    end
end

if SERVER then
    function MINIGAME:SetStyle(ply, styleName)
        local dyn = ply.dynamic_player_class
        dyn.active_style = styleName
        MinigameService.CallNetHookWithoutMethod(ply.lobby, "SetStyle", ply, styleName)
    end

    hook.Add("PlayerSay", "StylesCommand", function(ply, text)
        local args = string.Explode(" ", string.Trim(text))
        if #args == 0 then return end

        local cmd = string.lower(args[1])
        if cmd == "!style" then
            local style = args[2] and string.lower(args[2]) or "default"

            local lobby = ply.lobby
            if lobby and lobby.prototype.name == "Styles" then
                lobby.prototype:SetStyle(ply, style)
                
            else
                ply:ChatPrint("You are not in the Styles minigame!")
				
            end
            return ""
        elseif cmd == "!styles" then
            local lobby = ply.lobby
            if lobby and lobby.prototype.name == "Styles" then
                ply:ChatPrint("[EMM] List Of Styles: default, unreal, float (!style <string>)" )
            end
            return ""
        end

    end)
else
    MINIGAME:AddHookNotification("SetStyle", function(self, involves_local_ply, ply, style)
        if involves_local_ply then
            NotificationService.PushText("You set your style to " .. style)
        end
    end)
end
