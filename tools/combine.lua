for i, file in ipairs(arg) do
	local f = assert(io.open(file, "r"))
	local text = assert(f:read("*a"))
	f:close()

	local name = file:gsub('[/\\]', '.'):gsub('^%.+', ''):gsub('.lua$', '')
	io.write("package.preload[\"", name, "\"] = (function(...)\n", text, "\nend)\n\n")
end
io.write("require('src.main')")
