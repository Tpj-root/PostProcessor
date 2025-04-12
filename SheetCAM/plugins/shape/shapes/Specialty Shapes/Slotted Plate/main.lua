--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: Slotted Plate

-- CREATED BY: David McCullough, adapted from code created by Les Newell.

shape = {}

function shape.Calculate()
   local hw = shape.width / 2
   local hh = shape.height / 2
   local r = shape.filletRad
   Line(-hw, -hh + r, -hw, hh - r)
   ArcA(-hw, hh - r, -hw + r, hh - r, math.pi/2)
   Line(-hw + r, hh, hw - r, hh)
   ArcA(hw - r, hh, hw - r, hh - r, math.pi/2)
   Line(hw, hh - r, hw, -hh + r)
   ArcA(hw, -hh + r, hw - r, -hh + r, math.pi/2)
   Line(hw - r, -hh, -hw + r, -hh)
   ArcA(-hw + r, -hh, -hw + r, -hh + r, math.pi/2)
   
   hw = (shape.slotSpace * (shape.slotNum - 1)) / 2
   hh = shape.slotLength / 2
   sr = shape.slotDia / 2
   local x = -hw + shape.ctrOffX
   local yOff = shape.ctrOffY
   for p=1,shape.slotNum do
	Line(x - sr, 0 - hh + yOff, x - sr, 0 + hh + yOff)
	ArcA(x - sr, 0 + hh + yOff, x, 0 + hh + yOff, math.pi)
	Line(x + sr, 0 + hh + yOff, x + sr, 0 - hh + yOff)
	ArcA(x + sr, 0 - hh + yOff, x, 0 - hh + yOff, math.pi)
	x = x + shape.slotSpace
   end
end

AddNumControl("width", TR("Width"), sc.unitLINEAR, 203.2, 0.0254, 6096, "width.png")
AddNumControl("height", TR("Height"), sc.unitLINEAR, 101.6, 0.0254, 6096, "height.png")
AddNumControl("slotNum", TR("Number of Slots"), sc.unit0DECPLACE, 6, 1, 10000, "nSlots.png")
AddNumControl("slotSpace", TR("Slot Spacing"), sc.unitLINEAR, 25.4, 0, 6096, "slotSpace.png")
AddNumControl("slotLength", TR("Slot Length"), sc.unitLINEAR, 50.8, 0.0254, 6096, "slotLength.png")
AddNumControl("slotDia", TR("Slot Width"), sc.unitLINEAR, 12.7, 0.0254, 6096, "slotDia.png")
AddNumControl("filletRad", TR("Corner Radius"), sc.unitLINEAR, 12.7, 0, 6096, "fillet.png")
AddNumControl("ctrOffX", TR("Slot Group X Offset"), sc.unitLINEAR, 0, -6096, 6096, "slotOffX.png")
AddNumControl("ctrOffY", TR("Slot Group Y Offset"), sc.unitLINEAR, 0, -6096, 6096, "slotOffY.png")
