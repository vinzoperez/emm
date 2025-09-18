HUDService = HUDService or {}

local health_icon_material = PNGMaterial "emm2/hud/health.png"
local speed_icon_material = PNGMaterial "emm2/hud/speed.png"
local airaccel_icon_material = PNGMaterial "emm2/hud/airaccel.png"

function HUDService.KeyDown(key)
	return IsValid(LocalPlayer():GetObserverTarget()) and (bit.band(SpectateService.buttons, key) ~= 0) or LocalPlayer():KeyDown(key)
end

function HUDService.InitContainers()
	HUDService.container = HUDService.CreateContainer()

	HUDService.container:AddConvarAnimator("hud_padding_x", "padding_x")
	HUDService.container:AddConvarAnimator("hud_padding_y", "padding_y")

	HUDService.container:SetAttribute("color", function ()
		return HUDService.animatable_color.smooth
	end)

	local ang = SettingsService.Get "hud_angle"

	HUDService.left_section = HUDService.CreateSection(Angle(0, -ang, 0))
	HUDService.middle_section = HUDService.CreateSection(nil, math.Remap(ang, 0, 35, 0, 0.41))
	HUDService.right_section = HUDService.CreateSection(Angle(0, ang, 0))

	HUDService.quadrant_a = HUDService.CreateQuadrant(HUDService.left_section)
	HUDService.quadrant_b = HUDService.CreateQuadrant(HUDService.middle_section, {layout_justification_x = JUSTIFY_CENTER})
	HUDService.quadrant_c = HUDService.CreateQuadrant(HUDService.right_section, {layout_justification_x = JUSTIFY_END})
	HUDService.quadrant_d = HUDService.CreateQuadrant(HUDService.left_section, {layout_justification_y = JUSTIFY_CENTER})

	HUDService.quadrant_e = HUDService.CreateQuadrant(HUDService.middle_section, {
		layout_justification_x = JUSTIFY_CENTER,
		layout_justification_y = JUSTIFY_CENTER
	})

	HUDService.quadrant_f = HUDService.CreateQuadrant(HUDService.right_section, {
		layout_justification_x = JUSTIFY_END,
		layout_justification_y = JUSTIFY_CENTER
	})

	HUDService.quadrant_g = HUDService.CreateQuadrant(HUDService.left_section, {
		layout_justification_y = JUSTIFY_END,
		alpha = 0,
		child_margin = MARGIN * 4
	})

	HUDService.quadrant_h = HUDService.CreateQuadrant(HUDService.middle_section, {
		layout_justification_x = JUSTIFY_CENTER,
		layout_justification_y = JUSTIFY_END,
		alpha = 0,
		child_margin = MARGIN * 4
	})

	HUDService.quadrant_i = HUDService.CreateQuadrant(HUDService.right_section, {
		layout_justification_x = JUSTIFY_END,
		layout_justification_y = JUSTIFY_END,
		alpha = 0,
		child_margin = MARGIN * 4
	})

	HUDService.crosshair_container = HUDService.container:Add(HUDService.CreateCrosshairContainer())
	HUDService.crosshair_meter_container = HUDService.container:Add(HUDService.CreateCrosshairContainer(true))
	
end

function HUDService.InitKeyEchoes()
	HUDService.key_echos = HUDService.quadrant_h:Add(KeyEchos.New())

	HUDService.key_forward = HUDService.key_echos:Add(KeyEcho.New {
		origin_justification_x = JUSTIFY_CENTER,
		origin_justification_y = JUSTIFY_START,
		position_justification_x = JUSTIFY_CENTER,
		position_justification_y = JUSTIFY_START,
		arrow = "↑",
		key = IN_FORWARD
	})

	HUDService.key_left = HUDService.key_echos:Add(KeyEcho.New {
		origin_justification_x = JUSTIFY_START,
		origin_justification_y = JUSTIFY_CENTER,
		position_justification_x = JUSTIFY_START,
		position_justification_y = JUSTIFY_CENTER,
		arrow = "←",
		key = IN_MOVELEFT
	})

	HUDService.key_back = HUDService.key_echos:Add(KeyEcho.New {
		origin_justification_x = JUSTIFY_CENTER,
		origin_justification_y = JUSTIFY_CENTER,
		position_justification_x = JUSTIFY_CENTER,
		position_justification_y = JUSTIFY_CENTER,
		arrow = "↓",
		key = IN_BACK
	})

	HUDService.key_right = HUDService.key_echos:Add(KeyEcho.New {
		origin_justification_x = JUSTIFY_END,
		origin_justification_y = JUSTIFY_CENTER,
		position_justification_x = JUSTIFY_END,
		position_justification_y = JUSTIFY_CENTER,
		arrow = "→",
		key = IN_MOVERIGHT
	})

	HUDService.key_sprint = HUDService.key_echos:Add(KeyEcho.New {
		origin_justification_x = JUSTIFY_START,
		origin_justification_y = JUSTIFY_END,
		position_justification_x = JUSTIFY_START,
		position_justification_y = JUSTIFY_END,
		font = "KeyEchoSmall",
		text = "SPRINT",
		key = IN_SPEED
	})

	HUDService.key_duck = HUDService.key_echos:Add(KeyEcho.New {
		origin_justification_x = JUSTIFY_CENTER,
		origin_justification_y = JUSTIFY_END,
		position_justification_x = JUSTIFY_CENTER,
		position_justification_y = JUSTIFY_END,
		font = "KeyEchoSmall",
		text = "DUCK",
		key = IN_DUCK
	})

	HUDService.key_jump = HUDService.key_echos:Add(KeyEcho.New {
		origin_justification_x = JUSTIFY_END,
		origin_justification_y = JUSTIFY_END,
		position_justification_x = JUSTIFY_END,
		position_justification_y = JUSTIFY_END,
		font = "KeyEchoSmall",
		text = "JUMP",
		key = IN_JUMP
	})
	HUDService.key_attack1 = HUDService.key_echos:Add(KeyEcho.New {
		origin_justification_x = JUSTIFY_START,
		origin_justification_y = JUSTIFY_START,
		position_justification_x = JUSTIFY_START,
		position_justification_y = JUSTIFY_START,
		font = "KeyEchoSmall",
		text = "M1",
		key = IN_ATTACK
	})
	HUDService.key_attack2 = HUDService.key_echos:Add(KeyEcho.New {
		origin_justification_x = JUSTIFY_END,
		origin_justification_y = JUSTIFY_START,
		position_justification_x = JUSTIFY_END,
		position_justification_y = JUSTIFY_START,
		font = "KeyEchoSmall",
		text = "M2",
		key = IN_ATTACK2
	})
end

function HUDService.InitMeters()
	local function Health()
		return GetObservingPlayer():Health()
	end

	local function Speed()
		return math.Round(GetObservingPlayer():GetVelocity():Length2D())
	end

	local function Airaccel()
		return GetObservingPlayer().can_airaccel and GetObservingPlayer().stamina.airaccel:GetStamina() or 0
	end

	if SettingsService.Get "show_hud_meters" then
		HUDService.health_meter = HUDMeter.New("g", {
			show_value = true,
			hide_value_on_empty = true,
			hide_value_on_full = true,
			icon_material = health_icon_material,
			value_func = Health
		})

		HUDService.speed_meter = HUDMeter.New("h", {
			show_value = true,
			hide_value_on_empty = true,
			icon_material = speed_icon_material,
			value_func = Speed,
			value_divider = HUD_SPEED_METER_DIVIDER,
			sub_value = true,
			units = "u/s",
		})

		HUDService.airaccel_meter = HUDMeter.New("i", {
			icon_material = airaccel_icon_material,
			value_func = Airaccel
		})
	end

	if SettingsService.Get "show_crosshair_meters" then
		HUDService.crosshair_meter_container:Add(CrosshairMeter.New {
			value_func = Health,
			angle = CROSSHAIR_METER_ARC_ANGLE
		})

		HUDService.crosshair_meter_container:Add(CrosshairMeter.New {
			show_value = true,
			hide_value_on_empty = true,
			value_func = Speed,
			value_divider = HUD_SPEED_METER_DIVIDER,
			sub_value = true
		})

		HUDService.crosshair_meter_container:Add(CrosshairMeter.New {
			value_func = Airaccel,
			angle = -CROSSHAIR_METER_ARC_ANGLE
		})
	end
end

function HUDService.InitCrosshairLines()
	HUDService.crosshair_lines = HUDService.crosshair_container:Add(CrosshairLines.New())
end

surface.CreateFont("ScoreboardTitle", {
	font = "Helvetica",
	size = 32,
	weight = 800
})

surface.CreateFont("ScoreboardPlayer", {
	font = "Helvetica",
	size = 22,
	weight = 800,
})

local PLAYER_LINE = {
	Init = function(self)
		self.AvatarButton = self:Add("DButton")
		self.AvatarButton:Dock(LEFT)
		self.AvatarButton:DockMargin(3,3,0,3)
		self.AvatarButton:SetSize(32,32)
		self.AvatarButton:SetContentAlignment(5)
		self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

		self.Avatar = vgui.Create("AvatarImage", self.AvatarButton)
		self.Avatar:SetSize(32,32)
		self.Avatar:SetMouseInputEnabled(false)

		self.Name = self:Add("DLabel")
		self.Name:Dock(FILL)
		self.Name:SetFont("ScoreboardPlayer")
		self.Name:SetTextColor( Color(100,100,100,0))
		self.Name:DockMargin(0,0,0,0)
		
		self.MutePanel = self:Add("DPanel")
		self.MutePanel:SetSize(36, self:GetTall())
		self.MutePanel:Dock(RIGHT)
		function self.MutePanel:Paint(w,h)
			draw.RoundedBox(0,0,0,w,h, Color(50,50,50,0))
		end

		self.Mute = self.MutePanel:Add("DButton")
		self.Mute:SetSize(32,32)
		self.Mute:Dock(FILL)
		self.Mute:SetContentAlignment(5)

		self.Ping = self:Add("DLabel")
		self.Ping:Dock(RIGHT)
		self.Ping:DockMargin(0,0,2,0)
		self.Ping:SetWidth(50)
		self.Ping:SetFont("ScoreboardPlayer")
		self.Ping:SetTextColor(Color(100,100,100,0))
		self.Ping:SetContentAlignment(5)

		self.ScorePanel = self:Add("DPanel")
		self.ScorePanel:SetSize(60, self:GetTall())
		self.ScorePanel:Dock(RIGHT)
		self.ScorePanel:DockMargin(0,0,4,0)
		function self.ScorePanel:Paint(w,h)
			draw.RoundedBox(0,0,0,w,h, Color(100,100,100,0))
		end

		self.Velocity = self.ScorePanel:Add("DLabel")
		self.Velocity:Dock(FILL)
		self.Velocity:SetFont("ScoreboardDefault")
		self.Velocity:SetTextColor(Color(100,100,100, 0))
		self.Velocity:SetContentAlignment(5)
		

		self:Dock(TOP)
		self:SetHeight(38)
		self:DockMargin(10,0,10,2)

	end,

	Setup = function(self, pl)
		self.Player = pl
		self.Avatar:SetPlayer(pl)
		self:Think(self)

	end,

	Think = function(self)
		if (!IsValid(self.Player)) then
			self:SetZPos(9999)
			self:Remove()
		end
		self.Name:SetTextColor(Color(255,255,255))
		self.Velocity:SetTextColor(Color(255,255,255))
		self.Ping:SetTextColor(Color(255,255,255))

		local plySpeed = self.Player:GetVelocity():Length() / 10
		local rounded = math.ceil(plySpeed) * 10 / 10
		self.Velocity:SetText( tostring(rounded))

		if (self.PName == nil || self.PName != self.Player:Nick()) then
			self.PName = self.Player:Nick()
			self.Name:SetText(self.PName)
		end
		if (self.NumPing == nil || self.NumPing != self.Player:Ping()) then
			self.NumPing = self.Player:Ping()
			self.Ping:SetText(self.NumPing)
		end
		if (self.Muted == nil || self.Muted != self.Player:IsMuted()) then
			self.Muted = self.Player:IsMuted()
			if (self.Muted) then
				self.Mute:SetImage("icon32/muted.png")
			else
				self.Mute:SetImage("icon32/unmuted.png")
			end

			self.Mute.DoClick = function() self.Player:SetMuted(!self.Muted) end
		end

	end,

	Paint = function(self, w, h)
		if (!IsValid(self.Player)) then
			return 
		end

		if (!self.Player:Alive()) then
			draw.RoundedBox(4,0,0,w,h, Color(10,10,10,150))

		end
		draw.RoundedBox(4,0,0,w,h, Color(10,10,10,150))
	end
}
PLAYER_LINE = vgui.RegisterTable(PLAYER_LINE, "DPanel")

local SCORE_BOARD = {
	Init = function(self)

		self.Header = self:Add("Panel")
		self.Header:Dock(TOP)
		self.Header:SetHeight(50)

		self.Name = self.Header:Add("DLabel")
		self.Name:SetFont("ScoreboardTitle")
		self.Name:SetTextColor(Color(255,255,255,250))
		self.Name:Dock(LEFT)
		self.Name:SetWidth(900) -- give it a fixed width
		self.Name:SetContentAlignment(4) -- left aligned

		self.VelocityHeader = self.Header:Add("DLabel")
		self.VelocityHeader:SetFont("ScoreboardDefault")
		self.VelocityHeader:SetTextColor(Color(255,255,255,150))
		self.VelocityHeader:Dock(RIGHT)
		self.VelocityHeader:SetWidth(200) -- reserve space for it
		self.VelocityHeader:SetContentAlignment(6) -- right aligned
		self.VelocityHeader:DockMargin(0,0,20,0)
		
		

		self.Scores = self:Add("DScrollPanel")
		self.Scores:Dock(FILL)
		self.Scores:DockMargin(0,0,0,10)
		local scrollBar = self.Scores:GetVBar()
		scrollBar:DockMargin(-5,0,0,0)

		function scrollBar:Paint(w, h)
			surface.SetDrawColor(10,10,10,0)
			surface.DrawOutlinedRect(0,0,w-1,h-1)
		end
		function scrollBar.btnGrip:Paint(w,h)
			draw.RoundedBox(0,0,0,w,h, Color(150,200,150,0))
		end
	end,

	PerformLayout = function(self)
		self:SetSize(1250,ScrH() - 250)
		self:SetPos(ScrW() / 2 - 1250 / 2, 250/2)

	end,

	Paint = function(self, w, h)
		draw.RoundedBox(8,0,0,w,h,Color(10,10,10,0))

	end,

	Think = function(self, w, h)
		self.Name:SetText("Extended Movement Mod 2 Beta | Vinzo's Version")
		self.VelocityHeader:SetText("velocity")
		for id, pl in pairs(player.GetAll()) do
			if (IsValid(pl.VelocityEntry)) then continue end

			pl.VelocityEntry = vgui.CreateFromTable(PLAYER_LINE, pl.VelocityEntry)
			pl.VelocityEntry:Setup(pl)

			self.Scores:AddItem(pl.VelocityEntry)
		end
	end
}

SCORE_BOARD = vgui.RegisterTable(SCORE_BOARD, "EditablePanel")

function GM:ScoreboardShow()
		if (!IsValid(Scoreboard)) then
			Scoreboard = vgui.CreateFromTable(SCORE_BOARD)
		end
		if (IsValid(Scoreboard)) then
			Scoreboard:Show()
			Scoreboard:MakePopup()
			Scoreboard:SetKeyBoardInputEnabled(false)
		end
	end
function GM:ScoreboardHide()
	if (IsValid(Scoreboard)) then
		Scoreboard:Hide()
	end
end

function HUDService.Init()
	if SettingsService.Get "show_hud" then
		HUDService.animatable_color = AnimatableValue.New(COLOR_WHITE, {
			smooth = true,

			generate = function ()
				return LocalPlayer().color
			end
		})

		HUDService.InitContainers()

		if SettingsService.Get "show_keys" then
			HUDService.InitKeyEchoes()
		end

		HUDService.InitMeters()
		if SettingsService.Get "show_crosshair" then
			HUDService.InitCrosshairLines()
		end

		if not LobbyUIService.open then
			-- if LocalPlayer():Alive() then
				HUDService.ShowAll()
			-- else
			-- 	HUDService.ShowNotifications()
			-- end
		end

		hook.Run "InitHUDElements"
	end
end
hook.Add("InitUI", "HUDService.Init", HUDService.Init)

function HUDService.Reload()
	if HUDService.animatable_color then
		HUDService.animatable_color:Finish()
	end

	local old_container = HUDService.container

	if old_container then
		old_container:AnimateAttribute("alpha", 0, {
			callback = function ()
				old_container:Finish()
			end
		})

		HUDService.container = nil
	end

	if SettingsService.Get "show_hud" then
		HUDService.Init()
		HUDService.ShowAll()
	end
end
hook.Add("OnReloaded", "HUDService.Reload", HUDService.Reload)

local native_hud_elements = {
	"CHudCrosshair",
	"CHudHealth",
	"CHudBattery",
	"CHudAmmo",
	"CHudSecondaryAmmo"
}

function HUDService.ShouldDraw(name)
	if table.HasValue(native_hud_elements, name) then
		return false
	end
end
hook.Add("HUDShouldDraw", "HUDService.ShouldDraw", HUDService.ShouldDraw)

function HUDService.ShowMeters()
	HUDService.quadrant_g:AnimateAttribute("alpha", 255)
	HUDService.quadrant_h:AnimateAttribute("alpha", 255)
	HUDService.quadrant_i:AnimateAttribute("alpha", 255)
end

function HUDService.ShowCrosshair()
	HUDService.crosshair_container:AnimateAttribute("alpha", 255)
	HUDService.crosshair_meter_container:AnimateAttribute("alpha", 255)
end

function HUDService.ShowNotifications()
	HUDService.quadrant_a:AnimateAttribute("alpha", 255)
	HUDService.quadrant_b:AnimateAttribute("alpha", 255)
	HUDService.quadrant_c:AnimateAttribute("alpha", 255)
end

function HUDService.HideMeters()
	HUDService.quadrant_g:AnimateAttribute("alpha", 0)
	HUDService.quadrant_h:AnimateAttribute("alpha", 0)
	HUDService.quadrant_i:AnimateAttribute("alpha", 0)
end

function HUDService.HideCrosshair()
	HUDService.crosshair_container:AnimateAttribute("alpha", 0)
	HUDService.crosshair_meter_container:AnimateAttribute("alpha", 0)
end

function HUDService.HideNotifications()
	HUDService.quadrant_a:AnimateAttribute("alpha", 0)
	HUDService.quadrant_b:AnimateAttribute("alpha", 0)
	HUDService.quadrant_c:AnimateAttribute("alpha", 0)
end

function HUDService.ShowAll()
	HUDService.ShowMeters()
	HUDService.ShowCrosshair()
	HUDService.ShowNotifications()
end

function HUDService.HideAll()
	HUDService.HideMeters()
	HUDService.HideCrosshair()
	HUDService.HideNotifications()
end

function HUDService.SpawnShow()
	if SettingsService.Get "show_hud" and not LobbyUIService.open then
		if HUDService.container then
			HUDService.ShowMeters()
			HUDService.ShowCrosshair()
		end

		if IndicatorService.container and IndicatorService.Visible() then
			IndicatorService.Show()
		end
	end
end
hook.Add("LocalPlayerSpawn", "HUDService.SpawnShow", HUDService.SpawnShow)

function HUDService.DeathHide()
	if SettingsService.Get "show_hud" and not LobbyUIService.open then
		HUDService.HideMeters()
		HUDService.HideCrosshair()

		if IndicatorService.Visible() then
			IndicatorService.Hide()
		end
	end
end
hook.Add("LocalPlayerDeath", "HUDService.DeathHide", HUDService.DeathHide)

function HUDService.LobbyUIShow()
	if SettingsService.Get "show_hud" then
		if GhostService.Alive(LocalPlayer()) then
			HUDService.ShowAll()

			if IndicatorService.Visible() then
				IndicatorService.Show()
			end
		else
			HUDService.ShowNotifications()
		end
	end
end
hook.Add("OnLobbyUIClose", "HUDService.LobbyUIShow", HUDService.LobbyUIShow)

function HUDService.LobbyUIHide()
	if SettingsService.Get "show_hud" then
		HUDService.HideAll()

		if IndicatorService.Visible() then
			IndicatorService.Hide()
		end
	end
end
hook.Add("OnLobbyUIOpen", "HUDService.LobbyUIHide", HUDService.LobbyUIHide)

function HUDService.RenderHooks()
	hook.Run "DrawNametags"
	hook.Run "DrawIndicators"
	hook.Run "DrawCamUI"
end
hook.Add("PostDrawHUD", "HUDService.RenderHooks", HUDService.RenderHooks)
