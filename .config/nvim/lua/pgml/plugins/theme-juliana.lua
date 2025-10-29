return {
	src = "pgml/nvim-juliana",
	init = function()
		require "nvim-juliana".setup {
			colors = {
				--bg2 = "#343D46",
				bg2 = "#2E3842"
			}
		}
	end
}
