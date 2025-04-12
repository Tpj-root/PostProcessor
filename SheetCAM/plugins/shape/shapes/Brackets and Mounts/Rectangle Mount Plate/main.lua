--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: Mount Plate

--CREATED BY: David McCullough

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
   local shw = shape.slotHoriz / 2
   local shh = shape.slotVert / 2
   local shl = shape.slotLength / 2
   local sr = shape.slotDia / 2
   local xOff = shape.ctrOffX
   local yOff = shape.ctrOffY
   
   Line(-shw - shl + xOff, -shh - sr + yOff, -shw + shl + xOff, -shh - sr + yOff)
   ArcA(-shw + shl + xOff, -shh - sr + yOff, -shw + shl + xOff, -shh + yOff, -math.pi)
   Line(-shw + shl + xOff, -shh + sr + yOff, -shw - shl + xOff, -shh + sr + yOff)
   ArcA(-shw - shl + xOff, -shh + sr + yOff, -shw - shl + xOff, -shh + yOff, -math.pi)
   
   Line(shw - shl + xOff, -shh - sr + yOff, shw + shl + xOff, -shh - sr + yOff)
   ArcA(shw + shl + xOff, -shh - sr + yOff, shw + shl + xOff, -shh + yOff, -math.pi)
   Line(shw + shl + xOff, -shh + sr + yOff, shw - shl + xOff, -shh + sr + yOff)
   ArcA(shw - shl + xOff, -shh + sr + yOff, shw - shl + xOff, -shh + yOff, -math.pi)
   
   Line(-shw - shl + xOff, shh - sr + yOff, -shw + shl + xOff, shh - sr + yOff)
   ArcA(-shw + shl + xOff, shh - sr + yOff, -shw + shl + xOff, shh + yOff, -math.pi)
   Line(-shw + shl + xOff, shh + sr + yOff, -shw - shl + xOff, shh + sr + yOff)
   ArcA(-shw - shl + xOff, shh + sr + yOff, -shw - shl + xOff, shh + yOff, -math.pi)
   
   Line(shw - shl + xOff, shh - sr + yOff, shw + shl + xOff, shh - sr + yOff)
   ArcA(shw + shl + xOff, shh - sr + yOff, shw + shl + xOff, shh + yOff, -math.pi)
   Line(shw + shl + xOff, shh + sr + yOff, shw - shl + xOff, shh + sr + yOff)
   ArcA(shw - shl + xOff, shh + sr + yOff, shw - shl + xOff, shh + yOff, -math.pi)

end

AddNumControl("width", TR("Width"), sc.unitLINEAR, 101.6, 0.0254, 6096, "width.png")
AddNumControl("height", TR("Height"), sc.unitLINEAR, 101.6, 0.0254, 6096, "height.png")
AddNumControl("slotHoriz", TR("Horizontal Slot Spacing"), sc.unitLINEAR, 50.8, 0, 6096, "hHole.png")
AddNumControl("slotVert", TR("Vertical Slot Spacing"), sc.unitLINEAR, 50.8, 0, 6096, "vHole.png")
AddNumControl("slotLength", TR("Slot Length"), sc.unitLINEAR, 25.4, 0, 6096, "slotlength.png")
AddNumControl("slotDia", TR("Slot Width"), sc.unitLINEAR, 12.7, 0.0254, 6096, "holeDia.png")
AddNumControl("filletRad", TR("Corner Radius"), sc.unitLINEAR, 12.7, 0, 6096, "fillet.png")
AddNumControl("ctrOffX", TR("Slot Group X Offset"), sc.unitLINEAR, 0, -6096, 6096, "ctrOffX.png")
AddNumControl("ctrOffY", TR("Slot Group Y Offset"), sc.unitLINEAR, 0, -6096, 6096, "ctrOffY.png")

