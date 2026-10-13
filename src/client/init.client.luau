--!strict
-- Client bootstrap: loads every ModuleScript in Controllers/, calls init() on all, then start() on all.

type Controller = {
	init: (() -> ())?,
	start: (() -> ())?,
}

local controllersFolder = script:WaitForChild("Controllers")
local controllers: { [string]: Controller } = {}

for _, child in controllersFolder:GetChildren() do
	if child:IsA("ModuleScript") then
		controllers[child.Name] = require(child) :: any
	end
end

for _, controller in controllers do
	local init = controller.init
	if init then
		init()
	end
end

for _, controller in controllers do
	local start = controller.start
	if start then
		task.spawn(start)
	end
end
