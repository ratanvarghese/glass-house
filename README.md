# Glass House

Glass House is an unfinished roguelike. Development is still ongoing.

## Requirements

+ A Lua 5.1 interpreter: [LuaJIT](https://luajit.org) is recommended. Glass House *can* run on the standard Lua 5.1 interpreter, but is very slow. Other versions of Lua are not supported at all.
+ [Serpent](https://luarocks.org/modules/paulclinger/serpent)
+ [TermFX](https://luarocks.org/modules/gunnar_z/termfx) (for manual testing)
+ [Lua Quickcheck](https://luarocks.org/modules/primordus/lua-quickcheck) (for property-based testing)

## Running Tests

It is assumed the user is in a command line at the project root directory, and the user is testing using LuaJIT. 

To test manually, run `luajit src/main.lua`.
To test manually using stdio instead of TermFX, run `luajit src/main.lua -s`.
To run property-based tests, run `lqc test/lqc/*`.
To run the fuzzer, run `luajit test/fuzz.lua`.

## Symbols

Currently only ASCII 'graphics' are supported. The symbols might change in future commits.
+ `@` is the player, as per roguelike tradition
+ `#` is a wall
+ ` ` is a dark floor
+ `.` is a lit floor
+ `<` is the staircase to the next level
+ `A` is a monster
+ `D` is also a monster

## Current Features and Controls

Controls are very likely to change in future commits.
+ Save and quit (`q`)
+ Walk (`W`, `A`, `S`, `D`)
+ Turn lantern on or off (`1`)
+ Drop lantern (`f`)
+ Pick up lantern (by walking onto it)
+ Punch a monster (by walking into it)

Unlike in NetHack, there is no diagonal movement. Levels are non-persistent, and the player cannot return to previous levels anyway. This is intended behaviour.

Players are fully healed every time they climb a staircase. In fact, they are also given a new lantern. This is the expected behaviour for the current code, but will be changed in future.

Players have 1000 HP: this is to keep testing convenient. With a maximum HP of 10 or 20, Glass House is fine for a human player but too tough for the fuzzer.

There currently isn't any win condition.

## License

Glass House is licensed under the GPL. See the `LICENSE` file for details.
