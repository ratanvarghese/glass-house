#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

#include "body.h" /*Generated during build*/

int main(int argc, char** argv) {
	lua_State *L = luaL_newstate();
	luaL_openlibs(L);

	lua_createtable(L, argc, 1);
	for(int i = 0; i < argc; i++) {
		lua_pushstring(L, argv[i]);
		lua_rawseti(L, -2, i);
	}
	lua_setglobal(L, "arg");

	luaL_loadstring(L, BUFFER);
	lua_call(L, 0, 0);
	return 0;
}
