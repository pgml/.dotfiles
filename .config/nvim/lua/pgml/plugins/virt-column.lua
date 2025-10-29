return {
	src = "lukas-reineke/virt-column.nvim",
	init = function()
		require "virt-column".setup({ char = "│" })
	end
}
