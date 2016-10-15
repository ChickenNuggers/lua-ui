--- blessed/blessed-contrib based UI library for Lua.
-- @module ui
-- @author Ryan "ChickenNuggers" <ryan@hashbang.sh>
-- @license MIT
-- @release 0.1.0
-- vim:set noet sts=0 sw=3 ts=3:

local ui = {};

-- @see program.apply()
function ui:call(...)
	return self.program.apply(nil, {...});
end

setmetatable(ui, {
	__call = ui.call,
	__index = function(name)
		return require("ui." .. name);
	end
});

return ui;
