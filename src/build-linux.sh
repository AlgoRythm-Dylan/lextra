#######
# SOME GCC OPTIONS AND WHAT THEY DO:
#
# -llua
#   Links the Lua library. Required for all compilations
# -fPIC
#   Makes items position-independant. Required for all compilations
# -Wall
#   Displays warnings
#######
# lua.h, lualib.h, and lauxlib.h have been provided in src for convenience.
# this does NOT link the library, and does NOT provide any definitions for
# the functions you need. It just makes it easy to include the header files.
# You still need an installation of lua
#######

# Compile lncurses statically (to a .a) to remove the dependancy
gcc -static -o ../lncurses.a -Wall ncurses.h
# Create the .so that will be imported from Lua
gcc -shared -o ../libncurses.so -fPIC -llua -Wall libncurses.c lua.h lualib.h lauxlib.h
# Note: I REALLY HOPE THIS GONNA WORK