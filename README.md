# lua-ui

Lua UI library based on blessed and blessed-contrib

## Description

This library is a reimplementation of the
[blessed](https://github.com/chjj/blessed) library in Lua. Because the blessed
library is open sourced and licensed with the MIT license (as of 14-10-16), I'm
able to implement the API as close as possible. Any callback-based functions
will be implemented in coroutines, however, to provide a smoother transition to
an asynchronous framework.
