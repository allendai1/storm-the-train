--!strict
-- Server bootstrap: loads every ModuleScript in Services/, calls init() on all, then start() on all.

type Service = {
	init: (() -> ())?,
	start: (() -> ())?,
}

local servicesFolder = script:WaitForChild("Services")
local services: { [string]: Service } = {}

for _, child in servicesFolder:GetChildren() do
	if child:IsA("ModuleScript") then
		services[child.Name] = require(child) :: any
	end
end

for _, service in services do
	local init = service.init
	if init then
		init()
	end
end

for _, service in services do
	local start = service.start
	if start then
		task.spawn(start)
	end
end
