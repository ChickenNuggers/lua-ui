--- functions and definitions for colors
-- @module colors
-- vim:set noet sts=0 sw=3 ts=3:
local colors = {
	cache = {};
};

--- Generate a virtual color from RGB color.
-- @param r Red color value
-- @param g Green color value
-- @param b Blue color value
function colors.match(r, g, b)
	local hash = (r << 16) | (g << 8) | b;
	if colors.cache[hash] then
		return colors.cache[hash];
	end
	
	local ldiff = math.huge;
	local li = -1;
	
	for i=1, #colors.vcolors do
		local c = colors.vcolors[i];
		local diff = colors.color_distance(r, c[1], g, c[2], b, c[3]);
		if diff == 0 then
			li = i;
			break;
		end

		if diff < ldiff then
			ldiff = diff; -- essentially math.min
			li = i;
		end
	end

	colors.cache[hash] = li;
	return li;
end

--- Return a padded 2-wide hex string from integer input.
-- @param var Integer to convert to hex (will be shortened to <256>)
local function hex(var)
	if var <= 0xf then
		return "0" .. string.format("%x", var);
	else
		return string.format("%x", var % 0x100);
	end
end

--- Return a hex output from RGB values.
-- @param r Red color value
-- @param g Green color value
-- @param b Blue color value
function colors.RGB_to_hex(r, g, b)
	return "#" .. hex(r) .. hex(g) .. hex(b);
end

--- Return a set of RGB values from hex input.
-- @param hex #rrgggbb-formatted color code
function colors.hex_to_RGB(hex)
	if #hex == 4 then
		hex = hex[1] .. hex[2]:rep(2) .. hex[3]:rep(2) .. hex[4]:rep(2);
	end
	local color = tonumber(hex:sub(2), 16);
	local r, g, b = (color >> 16) & 0xff, (color >> 8) & 0xff, color & 0xff;
	return r, g, b;
end

--- Use this function to calculate approx. distance in color.
-- http://stackoverflow.com/questions/1633828
-- @param r1 First RGB red
-- @param r2 Second RGB red
-- @param g1 First RGB green
-- @param g2 Second RGB green
-- @param b1 First RGB blue
-- @param b2 Second RGB blue
function colors.color_distance(r1, r2, g1, g2, b1, b2)
	return (30 * (r1 - r2)) ^ 2 + (59 * (g1 - g2)) ^ 2 + (11 * (b1 - b2)) ^ 2;
end

--- Mix colors as though they are in a 3-d XYZ and go midway.
-- @param r1 First RGB red
-- @param r2 Second RGB red
-- @param g1 First RGB green
-- @param g2 Second RGB green
-- @param b1 First RGB blue
-- @param b2 Second RGB blue
-- @param alpha Alpha value to use in mixing
function colors.mix_colors(r1, r2, g1, g2, b1, b2, alpha)
	alpha = alpha or 0.5;
	r1 = r1 + (r2 - r1) * alpha | 0;
	g1 = g1 + (g2 - g1) * alpha | 0;
	b1 = b1 + (b2 - b1) * alpha | 0;

	return colors.match(r1, g1, b1);
end

-- ::TODO:: colors.blend
-- maybe?

--- Reduce possible amount of colors.
-- @param color Color to reduce
-- @param total Total amount of possible colors
function colors.reduce(color, total)
	if color >= 16 and total <= 16 then
		return colors.ccolors[color];
	elseif color >= 8 and total <= 8 then
		color = color ~ 8;
	elseif color >= 2 and total <= 2 then
		return color % 2;
	end
end

colors.xterm = {
	"#000000"; -- black
	"#cd0000"; -- red3
	"#00cd00"; -- green3
	"#0000ee"; -- blue3
	"#cd00cd"; -- magenta3
	"#00cdcd"; -- cyan3
	"#e5e5e5"; -- gray90
	"#7f7f7f"; -- gray50
	"#ff0000"; -- red
	"#00ff00"; -- green
	"#ffff00"; -- yellow
	"#5c5cff"; -- rgb:5c/5c/ff
	"#ff00ff"; -- magenta
	"#00ffff"; -- cyan
	"#ffffff"; -- white
};

do -- colors || vcolors
	local _colors = {};
	local vcolors = {};

	local function push(i, r, g, b)
		_colors[i] = colors.RGB_to_hex(r, g, b);
		vcolors[i] = {r, g, b};
	end

	for i, v in ipairs(colors.xterm) do -- 0-15
		local c = tonumber(v:sub(2), 16);
		push(i, (c >> 16) & 0xff, (c >> 8) & 0xff, c & 0xff);
	end

	for r=0, 5 do -- 16-231
		for g=0, 5 do
			for b=0, 5 do
				local i = 16 + r * 36 + g * 6 + b;
				push(i, r * 40 + 55, g * 40 + 55, b * 40 + 55);
			end
		end
	end

	for g=0, 23 do -- 232-255 are grayscale
		local l = g * 10 + 8;
		push(232 + g, l, l, l);
	end

	colors.colors = _colors;
	colors.vcolors = vcolors;
end

do -- ccolors
	local old_colors = {};
	local old_vcolors = {};

	for k, v in pairs(colors.colors) do
		old_colors[k] = v;
	end
	for k, v in pairs(colors.vcolors) do
		old_vcolors[k] = v;
	end

	colors.colors = {
		old_colors[1], old_colors[2], old_colors[3], old_colors[4],
		old_colors[5], old_colors[6], old_colors[7], old_colors[8]
	};
	colors.vcolors = {
		old_vcolors[1], old_vcolors[2], old_vcolors[3], old_vcolors[4],
		old_vcolors[5], old_vcolors[6], old_vcolors[7], old_vcolors[8]
	};

	colors.ccolors = {};
	for k, v in pairs(old_colors) do
		colors.ccolors[k] = colors.match(colors.hex_to_RGB(v));
	end

	colors.colors = old_colors;
	colors.vcolors = old_vcolors
end

colors.names = {
  -- special
  default = -1;
  normal = -1;
  bg = -1;
  fg = -1;
  -- normal
  black = 0;
  red = 1;
  green = 2;
  yellow = 3;
  blue = 4;
  magenta = 5;
  cyan = 6;
  white = 7;
  -- light
  lightblack = 8;
  lightred = 9;
  lightgreen = 10;
  lightyellow = 11;
  lightblue = 12;
  lightmagenta = 13;
  lightcyan = 14;
  lightwhite = 15;
  -- bright
  brightblack = 8;
  brightred = 9;
  brightgreen = 10;
  brightyellow = 11;
  brightblue = 12;
  brightmagenta = 13;
  brightcyan = 14;
  brightwhite = 15;
  -- alternate spellings
  grey = 8;
  gray = 8;
  lightgrey = 7;
  lightgray = 7;
  brightgrey = 7;
  brightgray = 7;
};

-- ::TODO:: ncolors?

return colors;
