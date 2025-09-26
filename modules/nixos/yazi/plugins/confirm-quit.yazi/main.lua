local M = {}

M.entry = function()
	local yes = ya.confirm {
		pos = { "center", w = 60, h = 10 },
		title = "Quit?",
		content = ui.Text("Are you sure you want to quit?"):wrap(ui.Wrap.YES),
	}
	if yes then
		ya.emit("quit", {})
	end
end

return M
