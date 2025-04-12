--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: Straight Lug

--CREATED BY: David McCullough

shape = {}

function shape.Calculate()
   local hw = shape.width / 2
   local hh = shape.height / 2
   local d = shape.diameter
   local r = shape.diameter / 2
   local yOff = shape.ctrOffY
    MoveTo(0,0)
	Line(-hw, hh, -hw, -hh)
    Line(-hw, -hh, hw, -hh)
	Line(hw, -hh, hw, hh)
	ArcA(hw, hh, 0, hh, -math.pi)
	ArcA(-r, hh + yOff, 0, hh + yOff, math.pi)
	LineTo(r, hh -shape.slotLength + yOff)
	ArcA(r, hh -shape.slotLength + yOff, 0, hh -shape.slotLength + yOff, math.pi)
	LineTo(-r, hh + yOff)
   end

AddNumControl("width", TR("Width"), sc.unitLINEAR, 101.6, 0.0254, 6096, "width.png")
AddNumControl("height", TR("Height"), sc.unitLINEAR, 152.4, 0.0254, 6096, "height.png")
AddNumControl("diameter", TR("Diameter"), sc.unitLINEAR, 50.8, 0.0254, 6096, "diameter.png")
AddNumControl("slotLength", TR("Slot Length"), sc.unitLINEAR, 0, 0, 6096, "length.png")
AddNumControl("ctrOffY", TR("Hole Y Offset"), sc.unitLINEAR, 0, -6096, 6096, "holeOffY.png")