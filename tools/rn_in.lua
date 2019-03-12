base = require("src.base")

local cmd_len = arg[1]
local len = cmd_len and cmd_len or (base.MAX_X * base.MAX_Y)

local keys = {
	base.conf.keys.north,
	base.conf.keys.south,
	base.conf.keys.east,
	base.conf.keys.west,
	"$" --intentionally invalid
}

for i=1,len do
	print(keys[math.random(1, #keys)])
end
print(base.conf.keys.quit)
