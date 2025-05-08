local M = {}

local config_path = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local ABinput = config_path .. "cpp/input"
local ABoutput = config_path .. "cpp/output"

-- RunCppAndPython
function M.setup_run_sample()
	vim.api.nvim_create_user_command("RunSample", function()
		local prog_buf = nil
		local filetype = nil

		-- Check the filetype of the current buffer
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			local buf = vim.api.nvim_win_get_buf(win)
			local buf_filetype = vim.api.nvim_buf_get_option(buf, "filetype")
			if buf_filetype == "cpp" or buf_filetype == "python" then
				prog_buf = buf
				filetype = buf_filetype
				break
			end
		end

		if not prog_buf then
			vim.notify("NotFound", vim.log.levels.WARN)
			return
		end

		local filepath = vim.api.nvim_buf_get_name(prog_buf)
		local filename_noext = filepath:gsub("%.cpp$", ""):gsub("%.py$", "")
		local exec_path = filename_noext .. ""

		local cmd
		if filetype == "cpp" then
			cmd = string.format(
				"g++ -std=c++20 -O2 '%s' -o '%s' && '%s' < '%s' > '%s'; echo '\n[Finished]'",
				filepath,
				exec_path,
				exec_path,
				ABinput,
				ABoutput
			)
		elseif filetype == "python" then
			cmd = string.format("python3 '%s' < '%s' > '%s'; echo '\n[Finished]'", filepath, ABinput, ABoutput)
		end

		-- Floating Windows
		local buf = vim.api.nvim_create_buf(false, true)
		local width = math.floor(vim.o.columns * 0.8)
		local height = math.floor(vim.o.lines * 0.8)
		local row = math.floor((vim.o.lines - height) / 2)
		local col = math.floor((vim.o.columns - width) / 2)

		vim.api.nvim_open_win(buf, true, {
			relative = "editor",
			row = row,
			col = col,
			width = width,
			height = height,
			style = "minimal",
			border = "rounded",
		})

		vim.fn.termopen(cmd, {
			on_exit = function()
				vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
			end,
		})

		vim.cmd("startinsert")
	end, {})
end

vim.keymap.set("n", "<leader>ls", ":RunSample<CR>", {
	noremap = true,
	silent = true,
	desc = "RunSample",
})

-- For  WIndows
vim.g.layout_closed = true
function M.setup_layout()
	-- CreateAndAdopt
	vim.api.nvim_create_user_command("Layout", function()
		if vim.g.layout_closed then
			return
		end
		vim.cmd("silent! wall")
		vim.cmd("silent! only")
		vim.cmd("split")

		local height = vim.o.lines
		local width = vim.o.columns

		local bottom_height_ratio = 0.2
		local side_width_ratio = 0.5

		vim.cmd("resize " .. math.floor(height * bottom_height_ratio))
		vim.cmd("wincmd j")

		vim.cmd("edit  " .. ABinput)
		local input_win = vim.api.nvim_get_current_win()
		vim.cmd("vsplit  " .. ABoutput)
		local output_win = vim.api.nvim_get_current_win()

		vim.cmd("vertical resize " .. math.floor(width * side_width_ratio))
		vim.cmd("wincmd l")
		vim.cmd("vertical resize " .. math.floor(width * side_width_ratio))
		vim.cmd("wincmd k")

		for _, win in ipairs({ input_win, output_win }) do
			vim.api.nvim_win_set_option(win, "number", false)
			vim.api.nvim_win_set_option(win, "relativenumber", false)
			vim.api.nvim_win_set_option(win, "cursorline", false)
			vim.api.nvim_win_set_option(win, "winhighlight", "Normal:Normal,FloatBorder:DiagnosticHint")
		end
	end, {})

	--...
	vim.api.nvim_create_autocmd("VimResized", {
		callback = function()
			if not vim.g.layout_closed then
				vim.defer_fn(function()
					vim.cmd("Layout")
				end, 100) -- ...
			end
		end,
	})

	vim.api.nvim_create_user_command("LayoutInitiate", function()
		vim.g.layout_closed = false
		vim.cmd("Layout")
	end, {})

	vim.keymap.set("n", "<leader>li", ":LayoutInitiate<CR>", {
		noremap = true,
		silent = true,
		desc = "LayoutInitial",
	})

	vim.api.nvim_create_user_command("LayoutClose", function()
		local targets = {
			vim.fn.fnamemodify(ABinput, ":p"),
			vim.fn.fnamemodify(ABoutput, ":p"),
		}

		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			local name = vim.api.nvim_buf_get_name(buf)
			for _, target in ipairs(targets) do
				if name == target then
					vim.api.nvim_win_close(win, true)
					if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
						vim.api.nvim_buf_delete(buf, { force = true })
					end
					break
				end
			end
		end
		vim.g.layout_closed = true
	end, {})

	vim.keymap.set("n", "<leader>lc", ":LayoutClose<CR>", {
		noremap = true,
		silent = true,
		desc = "LayoutClose",
	})
end

function M.setup()
	M.setup_run_sample()
	M.setup_layout()
end

return M
