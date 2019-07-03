if [ -d out ]; then
	rm -rf out
fi

mkdir out
luajit tools/combine.lua lib/*.lua src/*.lua ui/std.lua ui/cmdutil.lua ui/rogueffi.lua > out/body.lua
luajit -b out/body.lua out/body.h
gcc src/wrapper.c -rdynamic -l:libluajit-5.1.a -ldl -lm -I/usr/include/luajit-2.1 -Iout -o out/glass-house
