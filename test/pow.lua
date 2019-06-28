local serpent = require("serpent")
local power = require("src.power")


math.randomseed(os.time())
print(serpent.block(power.make_all()))
