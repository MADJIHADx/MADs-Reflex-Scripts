require "base/internal/ui/reflexcore"
madhudspeed =
{
};

function madhudspeed:initialize()
	self.userData = loadUserData();
	CheckSetDefaultValue(self, "userData", "table", {});
	CheckSetDefaultValue(self.userData, "upsIncrement", "number", 50);
	local color = Color(125,255,125,180);
	CheckSetDefaultValue(self.userData, "bColor", "table", color);
	local color = Color(255,255,255,220);
	CheckSetDefaultValue(self.userData, "nColor", "table", color);
end;

function clampToNoDecimal(n)
	return math.floor(n * 1) / 1;
end;

function madhudspeed:drawOptions(x, y)
	uiLabel("Speed Display Increment:", x, y);
	local ygap = 40;
	local Width = 200;
	local Start = 240;
	local user = self.userData;
	user.upsIncrement = clampToNoDecimal(uiEditBox(user.upsIncrement, x + Start + Width + 10, y, 60));

	local y = y + ygap;
	-----------------------------------------------------------
	---------------copy pasta from aliasedfrog-----------------
	-----------------------------------------------------------
	uiLabel("Bars Colour:", x, y);
	local user = self.userData;
	local col = user.color;
	user.bColor = user.bColor or {r = col.r, g = col.g, b = col.b, a = col.a};
	user.bColor = uiColorPicker(x + 15,y + ygap, user.bColor,{});

	local y = y + 200 + ygap;

	uiLabel("Numbers Colour:", x, y);
	local user = self.userData; --TODO Does this need to be here as well?
	local col = user.color; --TODO Does this need to be here as well?
	user.nColor = user.nColor or {r = col.r, g = col.g, b = col.b, a = col.a};
	user.nColor = uiColorPicker(x + 15,y + ygap, user.nColor,{});
	-------------------------------------------------------------
	---------------end copy pasta from aliasedfrog---------------
	-------------------------------------------------------------
	saveUserData(user);
end;

registerWidget("madhudspeed");
mhspeed = 0;

function madhudspeed:draw() --TODO A lot of this stuff probably should be before draw() maybe??
	if not shouldShowHUD() or not isRaceMode() then return end;
	local speedscale = 1; --scales the Y stuff

	--TODO Make these available in the widget prefs
	local topy = 400 * speedscale; --Bounding Box
	local bottomy = 0; --Bounding Box (always 0?)
	local speedmetercolor = self.userData.bColor; --Colour of the bars
	local textcolour = self.userData.nColor; --Colour of the numbers
	local yoffset = topy/2; --centers the bars on the y axis
	local bartotextxoffset = 5;
	local lerpspeedscale = 30;
	local lerpspeed = clamp(lerpspeedscale * deltaTimeRaw, 0.0001, 1); --IDEA maybe add easing, like fast in slow out?

	--precision speed text indicator box params
	local boxheight = 20;
	local boxwidth = 51.5; --TODO maybe make this dynamic or scissor it for 9999+ ups?
	local boxoffset = 10;

	--static helpers
	local player = getPlayer();
	local speed = math.ceil(player.speed);
	mhspeed = lerp(mhspeed, speed, lerpspeed);
	local lerpdspeed = round(mhspeed);
	local ylocation = lerpdspeed * speedscale; --Here the Y location changes by speed

	local linewidth = 25;
	local linewidthhalf = linewidth/2; --used to centre lines on the x axis
	local linewidthsub = linewidth/5; --used to centre lines on the x axis

	local lineheight = 2.5;
	local upsincpref = self.userData.upsIncrement;
	local upsincrement = upsincpref * speedscale;

	nvgBeginPath();
	nvgRect(linewidth/2 + boxoffset, -boxheight/2, boxwidth, boxheight);
	nvgStrokeColor(speedmetercolor);
	nvgStrokeWidth(lineheight);
	nvgStroke();

	--numbers inside speed indicator box
	nvgFontSize(18);
	nvgFontFace("Volter__28Goldfish_29");
	nvgTextAlign(NVG_ALIGN_RIGHT, NVG_ALIGN_MIDDLE);
	nvgFillColor(textcolour);
	nvgText(linewidth * 2 + linewidthhalf + boxoffset, 0, speed);

	--draws the moving bars loop
	for bardrawloop = (bottomy + -topy), ylocation, upsincrement do
		if (ylocation - bardrawloop) <= topy and (ylocation - bardrawloop) >= bottomy then do
			nvgBeginPath();
			nvgMoveTo(-linewidthhalf,(ylocation + -yoffset - bardrawloop));
			nvgLineTo(linewidthhalf, (ylocation + -yoffset - bardrawloop));
			nvgStrokeColor(speedmetercolor);
			nvgStrokeWidth(lineheight);
			nvgStroke();
			nvgFontSize(18);
			nvgFontFace("Volter__28Goldfish_29");
			nvgTextAlign(NVG_ALIGN_RIGHT, NVG_ALIGN_MIDDLE);
			nvgFillColor(textcolour);
			nvgText(-linewidthhalf + -bartotextxoffset, (ylocation + -yoffset - bardrawloop), bardrawloop + yoffset);
		end;
	end;
end;
end;
--Thanks to Qualx, AliasedFrog, Bonuspunkt and other dudes I forgot to mention in #reflex for helping me with lua questions.
