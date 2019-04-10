# lextra

Lua was created with this objective in mind: *small*

lextra was created with the opposite in mind.

# Why tho

Lua has two use cases, and it really boils down to
"who has the wheel?":

The most common use case is to embed
it into your project and speed up development by writing a
simple language (Lua) rather than a complicated one (c++).
In this case, small is good!

A less-common use case for Lua is to create applications
using Lua as the main codebase, and delegating tasks to
other languages (Usually c/c++). In this case, small is bad!
That's why this is the less common application for Lua.

This library should help with the first use case, but is really
targeted at the second. lextra hopes to create a "standard",
general-purpose library which makes Lua a viable language
for application development on it's own.


# Why lextra?

Current bonuses include:

- Configurable design (lextra_config.lua)