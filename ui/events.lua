--- Manage events in a window via this control
-- @module events
-- vim:set noet sts=0 sw=3 ts=3:

local EventHandler = {};

setmetatable(EventHandler, {
	__call = function(self)
		local new_object = setmetatable({
			handlers = {}
		}, {__index = EventHandler});
	end
});

--- Add a new listener callback to await events.
-- @param event Name of the event to listen for
-- @param listener Function to trigger when the event is received
function EventHandler:add_listener(event, listener)
	if not self.handlers[event] then
		self.handlers[event] = {};
	end
	self.handlers[event][#self.handlers[event] + 1] = listener;
	self:emit("new_listener", {event, listener});
end

--- Remove a specific listener hadnling a specific event.
-- @param event Name of the event to search for the listener to remove
-- @param listener Listener function to remove
function EventHandler:remove_listener(event, listener)
	if not self.handlers[event] then
		return;
	end
	for k, v in pairs(self.handlers[event]) do
		if v == listener then
			self.handlers[event][k] = nil;
		end
	end
	self:_emit("remove_listener", {event, listener});
end

--- Wrapper function
-- @see EventHandler:add_handler
function EventHandler:on(...) return self:add_listener(...) end

--- Wrapper function
--@see EventHandler:remove_listener
function EventHandler:off(...) return self:remove_listener(...) end

--- Remove all listeners for an event.
-- @param event Name of event to stop listening for
function EventHandler:clear_listeners_for(event)
	if not self.handlers[event] then
		return;
	end
	self.handlers[event] = nil; -- garbage collect
end

function EventHandler:clear_all_listeners()
	self.handlers = {}; -- garbage collect old one because no references?
end

--- Run a listener for an event, then remove the listener.
-- @param event Event to listen for
-- @param listener Function to call exactly once
function EventHandler:once(event, listener)
	return self:on(event, function(...)
		listener(...);
		self:off(event, listener);
	end);
end

--- Basic function for managing handlers
-- @local
-- @param type Type of handlers to run
-- @param args Arguments to pass to handlers
function EventHandler:_emit(type, args)
	local handlers = self.handlers[type];
	if #handlers == 0 then
		if type == "error" then
			return error(unpack(args));
		end
		return
	end

	local has_failed = false;
	for i=1, #handlers do
		if not pcall(handlers[i], unpack(args)) then
			has_failed = true
		end
	end
	return not has_failed;
end

--- Call all necessary handlers for a received event
-- @param type
-- @param ... Arguments to pass to handlers
function EventHandler:emit(type, ...)
	self:_emit("event", {...});

	if type == "screen" then
		return self:_emit(type, {...});
	end

	if not self:_emit(type, {...}) then
		return false;
	end

	type = "element " .. type;

	local handler = self;
	while handler do
		if handler.handlers[type] and #handler.handlers[type] > 0 then
			if not handler:_emit(type, {...}) then
				return false;
			end
		end
		handler = handler.parent;
	end
	return true;
end

return EventHandler;
