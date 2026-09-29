-- LocalScript -> StarterPlayer > StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local MAX = 500

local speedValue = 16
local flySpeed = 50
local flyHeight = 20      -- độ cao (studs) so với điểm bắt đầu bay
local flying = false
local startY = 0
local holdUp, holdDown = false, false
local bv, bg

local function char() return player.Character or player.CharacterAdded:Wait() end
local function hum() return char():WaitForChild("Humanoid") end
local function hrp() return char():WaitForChild("HumanoidRootPart") end

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "ChinhDepTraiMenu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(o, r) local c = Instance.new("UICorner", o) c.CornerRadius = UDim.new(0, r) end

local function makeDraggable(obj)
	local dragging, startPos, startInput
	obj.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, startPos, startInput = true, obj.Position, i.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - startInput
			obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 230, 0, 250)
main.Position = UDim2.new(0.5, -115, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
corner(main, 12)
makeDraggable(main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -50, 0, 32)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "chính đẹp trai"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 30, 0, 24)
minBtn.Position = UDim2.new(1, -38, 0, 4)
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 20
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
corner(minBtn, 6)

-- vòng tròn khi thu nhỏ
local circle = Instance.new("TextButton", gui)
circle.Size = UDim2.new(0, 70, 0, 70)
circle.Position = UDim2.new(0, 20, 0.4, 0)
circle.Text = "chính đẹp trai"
circle.TextWrapped = true
circle.TextScaled = true
circle.Font = Enum.Font.GothamBold
circle.TextColor3 = Color3.new(1, 1, 1)
circle.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
circle.Visible = false
corner(circle, 35)
makeDraggable(circle)

local function row(label, y, default)
	local l = Instance.new("TextLabel", main)
	l.Size = UDim2.new(0, 110, 0, 28)
	l.Position = UDim2.new(0, 10, 0, y)
	l.BackgroundTransparency = 1
	l.Text = label
	l.TextColor3 = Color3.new(1, 1, 1)
	l.Font = Enum.Font.Gotham
	l.TextSize = 14
	l.TextXAlignment = Enum.TextXAlignment.Left
	local t = Instance.new("TextBox", main)
	t.Size = UDim2.new(0, 90, 0, 28)
	t.Position = UDim2.new(0, 130, 0, y)
	t.Text = tostring(default)
	t.ClearTextOnFocus = false
	t.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	t.TextColor3 = Color3.new(1, 1, 1)
	t.Font = Enum.Font.Gotham
	t.TextSize = 14
	corner(t, 6)
	return t
end

local function button(text, x, y, w, color)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.new(0, w, 0, 32)
	b.Position = UDim2.new(0, x, 0, y)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	corner(b, 8)
	return b
end

local speedBox = row("Tốc độ chạy (≤500)", 42, speedValue)
local flySpeedBox = row("Tốc độ bay (≤500)", 78, flySpeed)
local heightBox = row("Độ cao bay", 114, flyHeight)
local flyBtn = button("BAY: TẮT", 10, 154, 210, Color3.fromRGB(70, 70, 90))
local upBtn = button("▲ Lên", 10, 194, 100, Color3.fromRGB(40, 150, 90))
local downBtn = button("▼ Xuống", 120, 194, 100, Color3.fromRGB(190, 110, 30))

local function num(box, default, min, max)
	local n = tonumber(box.Text) or default
	n = math.clamp(n, min, max)
	box.Text = tostring(n)
	return n
end

speedBox.FocusLost:Connect(function() speedValue = num(speedBox, 16, 0, MAX) end)
flySpeedBox.FocusLost:Connect(function() flySpeed = num(flySpeedBox, 50, 1, MAX) end)
heightBox.FocusLost:Connect(function() flyHeight = num(heightBox, 20, -1000, 100000) end)

minBtn.MouseButton1Click:Connect(function() main.Visible = false circle.Visible = true end)
circle.MouseButton1Click:Connect(function() main.Visible = true circle.Visible = false end)

upBtn.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then holdUp = true end
end)
upBtn.InputEnded:Connect(function() holdUp = false end)
downBtn.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then holdDown = true end
end)
downBtn.InputEnded:Connect(function() holdDown = false end)

-- ===== BAY =====
local function stopFly()
	flying = false
	flyBtn.Text = "BAY: TẮT"
	flyBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
	if bv then bv:Destroy() bv = nil end
	if bg then bg:Destroy() bg = nil end
	pcall(function() hum().PlatformStand = false end)
end

local function startFly()
	local root = hrp()
	flying = true
	startY = root.Position.Y
	flyBtn.Text = "BAY: BẬT"
	flyBtn.BackgroundColor3 = Color3.fromRGB(40, 170, 90)
	bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	bv.Velocity = Vector3.zero
	bv.Parent = root
	bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
	bg.P = 9e4
	bg.Parent = root
	hum().PlatformStand = true
end

flyBtn.MouseButton1Click:Connect(function()
	if flying then stopFly() else startFly() end
end)

RunService.RenderStepped:Connect(function(dt)
	local h = hum()
	if not flying and h.WalkSpeed ~= speedValue then h.WalkSpeed = speedValue end

	if flying and bv and bg then
		local root = hrp()
		if holdUp then flyHeight += 40 * dt end
		if holdDown then flyHeight -= 40 * dt end
		if UIS:IsKeyDown(Enum.KeyCode.E) then flyHeight += 40 * dt end
		if UIS:IsKeyDown(Enum.KeyCode.Q) then flyHeight -= 40 * dt end
		heightBox.Text = tostring(math.floor(flyHeight))

		local move = h.MoveDirection -- theo camera, dùng được cần điều khiển trên điện thoại
		local vy = math.clamp((startY + flyHeight - root.Position.Y) * 5, -flySpeed, flySpeed)
		bv.Velocity = Vector3.new(move.X * flySpeed, vy, move.Z * flySpeed)
		bg.CFrame = workspace.CurrentCamera.CFrame
	end
end)

player.CharacterAdded:Connect(function() flying = false stopFly() end)
