#include <stdio.h>

#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

#include "body.h"

int main(int argc, char** argv) {
	lua_State *L = lua_open();
	luaL_openlibs(L);

	lua_createtable(L, (argc>0 ? argc-1 : 0), 1); /*zero index not an array element in Lua?*/
	for(int i = 0; i < argc; i++) {
		lua_pushstring(L, argv[i]);
		lua_rawseti(L, -2, i);
	}
	lua_setglobal(L, "arg");

	int error = luaL_loadbuffer(L, luaJIT_BC_body, sizeof(luaJIT_BC_body), "glass-house") || lua_pcall(L, 0, 0, 0);
	if(error) {
		fprintf(stderr, "%s", lua_tostring(L, -1));
	}
	lua_close(L);
	return 0;
}
