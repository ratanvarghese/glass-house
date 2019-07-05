local filename = arg[1]
local buffername = arg[2] or "BUFFER"
local f = assert(io.open(filename))

io.write("unsigned char ", buffername, "[] = {\n  ")
local size = f:seek("end")
f:seek("set")
local c = true
local i = 0
while c do
	c = f:read(1)
	if c then
		io.write(string.format("0x%0.2x", string.byte(c)))
		local pos = f:seek()
		io.write(",")
		if (pos % 12) == 0 then
			io.write("\n  ")
		else
			io.write(" ")
		end
	end
end
io.write("0x00")
io.write("\n};\n")

io.write("unsigned int ", buffername, "_len = ", size, ";\n")

f:close()
