local plugins = {}
local plugin_dir = vim.fn.stdpath("config") .. "/lua/pgml/plugins"

for _, file in pairs(vim.fn.readdir(plugin_dir)) do
	if file ~= "init.lua" and file:sub(-4) == ".lua" then
		local plugin_name = file:sub(1, -5)
		local ok, spec = pcall(require, "pgml.plugins." .. plugin_name)

		if not ok then
			vim.notify("Failed to load: " .. plugin_name, vim.log.levels.WARN)
		else
			if spec.enabled ~= false then
				local plugin = spec or {}

				for k, v in pairs(spec) do
					if k ~= "src" then
						plugin[k] = v
					else
						plugin[k] = "https://github.com/" .. v
					end
				end

				table.insert(plugins, plugin)

				if spec.dependencies then
					for _, dep in ipairs(spec.dependencies) do
						table.insert(plugins, { src = "https://github.com/" .. dep })
					end
				end
			end
		end
	end
end

vim.pack.add(plugins)

return plugins
