vim.o.tabstop = 8
vim.o.softtabstop = 8
vim.o.shiftwidth = 8
vim.o.expandtab = false

pcall(vim.treesitter.start)

local function remove_unused_imports()
	local rows = {}
	for _, d in ipairs(vim.diagnostic.get(0)) do
		local line = vim.api.nvim_buf_get_lines(0, d.lnum, d.lnum + 1, false)[1] or ""
		if d.message:lower():find("unused import") and line:find("^%s*import%s") then
			rows[d.lnum] = true
		end
	end
	local sorted = vim.tbl_keys(rows)
	table.sort(sorted, function(a, b) return a > b end)
	for _, row in ipairs(sorted) do
		vim.api.nvim_buf_set_lines(0, row, row + 1, false, {})
	end
end

local imports_group = vim.api.nvim_create_augroup("OdinUnusedImports", { clear = false })
vim.api.nvim_clear_autocmds({ group = imports_group, buffer = 0 })
vim.api.nvim_create_autocmd("BufWritePre", { group = imports_group, buffer = 0, callback = remove_unused_imports })

--vim.api.nvim_create_autocmd("BufWritePre", {
--	buffer = 0,
--	callback = function()
--		if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/formatting" }) > 0 then
--			vim.lsp.buf.format({ async = false })
--		end
--	end,
--})

local rules = {
	{ "^(%s*[%w_, ]-:)%s*([^:=%s].*)$", " " },
	{ "^(%s*[%w_]+)%s*::%s*(.*)$", " :: " },
	{ "^(%s*[%w_%.]+)%s*(:?=)%s*([^=].*)$" },
}

local function align_fields(l1, l2)
	local lines = vim.api.nvim_buf_get_lines(0, l1 - 1, l2, false)
	local parsed, widths, walrus = {}, {}, {}

	local above = vim.fn.prevnonblank(l1 - 1)
	if above > 0 then
		local prev = vim.fn.getline(above)
		local depth = #prev:match("^\t*")
		local opens = prev:find("[{(:]%s*$") ~= nil
		local want = depth + (opens and 1 or 0)
		local have, first
		for _, line in ipairs(lines) do
			if line:find("%S") then
				local n = #line:match("^\t*")
				have = math.min(have or n, n)
				first = first or line
			end
		end
		if first and first:find("^%s*case[%s:]") then
			want = math.max(depth - (prev:find("[{:]%s*$") and 0 or 1), 0)
		end
		if have and have ~= want then
			for i, line in ipairs(lines) do
				if line:find("%S") then
					lines[i] = string.rep("\t", want) .. line:sub(have + 1)
				end
			end
		end
	end

	for i, line in ipairs(lines) do
		for r, rule in ipairs(rules) do
			local head, a, b = line:match(rule[1])
			if head then
				local key = r .. line:match("^%s*")
				local sep, rest = rule[2], a
				if not sep then
					sep, rest = a, b
					walrus[key] = walrus[key] or a == ":="
				end
				parsed[i] = { key, head, sep, rest }
				widths[key] = math.max(widths[key] or 0, #head)
				break
			end
		end
	end

	for i, p in pairs(parsed) do
		local key, head, sep, rest = p[1], p[2], p[3], p[4]
		if sep == "=" or sep == ":=" then
			sep = ((walrus[key] and sep == "=") and "  " or " ") .. sep .. " "
		end
		lines[i] = head .. string.rep(" ", widths[key] - #head) .. sep .. rest
	end

	vim.api.nvim_buf_set_lines(0, l1 - 1, l2, false, lines)
end

vim.api.nvim_buf_create_user_command(0, "AlignFields", function(o)
	align_fields(o.line1, o.line2)
end, { range = true })

vim.keymap.set("x", "<leader>a", ":AlignFields<cr>", { buffer = true, silent = true })

local function split_params(s)
	local parts, depth, start = {}, 0, 1
	for i = 1, #s do
		local c = s:sub(i, i)
		if c:match("[%(%[{]") then
			depth = depth + 1
		elseif c:match("[%)%]}]") then
			depth = depth - 1
		elseif c == "," and depth == 0 then
			table.insert(parts, vim.trim(s:sub(start, i - 1)))
			start = i + 1
		end
	end
	local last = vim.trim(s:sub(start))
	if last ~= "" then
		table.insert(parts, last)
	end
	return parts
end

local function matching_paren(s, open)
	local depth = 0
	for i = open, #s do
		local c = s:sub(i, i)
		if c == "(" then
			depth = depth + 1
		elseif c == ")" then
			depth = depth - 1
			if depth == 0 then
				return i
			end
		end
	end
end

local function paren_depth(s, from)
	local depth = 0
	for i = from, #s do
		local c = s:sub(i, i)
		if c == "(" then
			depth = depth + 1
		elseif c == ")" then
			depth = depth - 1
		end
	end
	return depth
end

local function wrap_params(each)
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local line = vim.api.nvim_get_current_line()
	local open = line:find("proc[^(]*%(") or 1
	open = line:find("(", open, true)
	if not open then
		return
	end

	local count = vim.api.nvim_buf_line_count(0)
	local text, last = line, row
	local function next_line()
		return vim.trim(vim.api.nvim_buf_get_lines(0, last, last + 1, false)[1])
	end

	while paren_depth(text, open) > 0 and last < count do
		text = text .. " " .. next_line()
		last = last + 1
	end
	if paren_depth(text, open) > 0 then
		return
	end
	if not text:find("{%s*$") and last < count and next_line() == "{" then
		text = text .. " {"
		last = last + 1
	end

	local close = matching_paren(text, open)
	local params = split_params(text:sub(open + 1, close - 1))
	local tail = text:sub(close)
	local brace = tail:find("%s*{%s*$")
	if brace then
		tail = tail:sub(1, brace - 1)
	end

	local ret_open = tail:match("^%)%s*%->%s*()%(")
	local rets, ret_rest
	if ret_open then
		local ret_close = matching_paren(tail, ret_open)
		rets = split_params(tail:sub(ret_open + 1, ret_close - 1))
		for i, r in ipairs(rets) do
			rets[i] = (r:gsub(":%s+", ": "))
		end
		ret_rest = tail:sub(ret_close)
		tail = tail:sub(1, ret_open) .. table.concat(rets, ", ") .. ret_rest
	end

	local indent = line:match("^%s*")
	local limit = vim.bo.textwidth > 0 and vim.bo.textwidth or 80
	local head = text:sub(1, open)
	local suffix = brace and " {" or ""
	local function fits(s)
		return vim.fn.strdisplaywidth(s) <= limit
	end

	local joined = head .. table.concat(params, ", ")
	local out

	if (not each or #params < 2) and fits(joined .. tail .. suffix) then
		out = { joined .. tail .. suffix }
	else
		local cont = indent .. string.rep(" ", vim.fn.strdisplaywidth(head) - vim.fn.strdisplaywidth(indent))
		local cur = head
		out = {}

		for i, p in ipairs(params) do
			local piece = p .. (i < #params and "," or tail)
			local sep = i == 1 and "" or " "
			if i > 1 and (each or not fits(cur .. sep .. piece)) then
				table.insert(out, cur)
				cur = cont .. piece
			else
				cur = cur .. sep .. piece
			end
		end
		if #params == 0 then
			cur = cur .. tail
		end
		table.insert(out, cur)

		if #out > 1 and brace then
			table.insert(out, indent .. "{")
		else
			out[#out] = out[#out] .. suffix
		end

		local too_long = false
		for _, l in ipairs(out) do
			if not fits(l) then
				too_long = true
			end
		end

		if too_long and #params > 0 then
			out = { head }
			for _, p in ipairs(params) do
				table.insert(out, indent .. "\t" .. p .. ",")
			end
			table.insert(out, indent .. tail .. suffix)
		end
	end

	vim.api.nvim_buf_set_lines(0, row - 1, last, false, out)
end

local CONDITION_KEYWORDS = {
	"^%s*}%s*else%s+if%s+",
	"^%s*else%s+if%s+",
	"^%s*if%s+",
	"^%s*for%s+",
	"^%s*when%s+",
}

local function split_condition(cond, base)
	local parts, depth, start, i = {}, 0, 1, 1
	while i <= #cond do
		local c = cond:sub(i, i)
		local op = cond:sub(i, i + 1)
		if c:match("[%(%[{]") then
			depth = depth + 1
		elseif c:match("[%)%]}]") then
			depth = depth - 1
		elseif depth == base and (op == "||" or op == "&&") then
			table.insert(parts, vim.trim(cond:sub(start, i + 1)))
			start = i + 2
			i = i + 1
		end
		i = i + 1
	end
	table.insert(parts, vim.trim(cond:sub(start)))
	return parts
end

local function wrap_condition(each)
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local line = vim.api.nvim_get_current_line()

	local head_end
	for _, pattern in ipairs(CONDITION_KEYWORDS) do
		head_end = select(2, line:find(pattern))
		if head_end then
			break
		end
	end
	if not head_end then
		return false
	end

	local count = vim.api.nvim_buf_line_count(0)
	local text, last = line, row
	local function next_line()
		return vim.trim(vim.api.nvim_buf_get_lines(0, last, last + 1, false)[1])
	end

	while (paren_depth(text, 1) > 0 or text:find("||%s*$") or text:find("&&%s*$")) and last < count do
		text = text .. " " .. next_line()
		last = last + 1
	end
	if not text:find("{%s*$") and last < count and next_line() == "{" then
		text = text .. " {"
		last = last + 1
	end

	local brace = text:find("%s*{%s*$")
	if not brace then
		return false
	end

	local header = text:sub(1, brace - 1)
	local cond = header:sub(head_end + 1)
	local base = (cond:sub(1, 1) == "(" and matching_paren(cond, 1) == #cond) and 1 or 0
	local parts = split_condition(cond, base)
	if #parts < 2 then
		return false
	end

	local indent = line:match("^%s*")
	local limit = vim.bo.textwidth > 0 and vim.bo.textwidth or 80
	local function fits(s)
		return vim.fn.strdisplaywidth(s) <= limit
	end

	local out
	if not each and fits(header .. " {") then
		out = { header .. " {" }
	else
		local cont = indent .. "\t"
		local cur = header:sub(1, head_end) .. parts[1]
		out = {}

		for i = 2, #parts do
			if each or not fits(cur .. " " .. parts[i]) then
				table.insert(out, cur)
				cur = cont .. parts[i]
			else
				cur = cur .. " " .. parts[i]
			end
		end
		table.insert(out, cur)

		if #out > 1 then
			table.insert(out, indent .. "{")
		else
			out[1] = out[1] .. " {"
		end
	end

	vim.api.nvim_buf_set_lines(0, row - 1, last, false, out)
	return true
end

vim.keymap.set("n", "<leader>a", function()
	if not wrap_condition(false) then
		wrap_params(false)
	end
end, { buffer = true })
vim.keymap.set("n", "<leader>ga", function()
	if not wrap_condition(true) then
		wrap_params(true)
	end
end, { buffer = true })
