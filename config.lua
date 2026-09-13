--
-- For more information on config.lua see the Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--

local apa = math.max( 480, math.min( display.pixelHeight, display.pixelWidth )/(2.4) )

application =
{
	content =
	{
		width = apa,
		height = apa*display.pixelHeight/display.pixelWidth,
		scale = "letterbox",
		fps = 60,
	},
}