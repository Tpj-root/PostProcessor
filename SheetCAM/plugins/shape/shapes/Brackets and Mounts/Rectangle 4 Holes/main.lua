--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: Rectangle w/ 4 holes

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
   hw = shape.holeHoriz / 2
   hh = shape.holeVert / 2

   Circle(-hw, -hh, shape.holeDia)
   Circle( hw, -hh, shape.holeDia)
   Circle(-hw,  hh, shape.holeDia)
   Circle( hw,  hh, shape.holeDia)
end

AddNumControl("width", TR("Width"), sc.unitLINEAR, 101.6, 0.0254, 6096, "width.png")
AddNumControl("height", TR("Height"), sc.unitLINEAR, 101.6, 0.0254, 6096, "height.png")
AddNumControl("holeHoriz", TR("Horizontal Hole Spacing"), sc.unitLINEAR, 76.2, 0, 6096, "hHole.png")
AddNumControl("holeVert", TR("Vertical Hole Spacing"), sc.unitLINEAR, 76.2, 0, 6096, "vHole.png")
AddNumControl("holeDia", TR("Hole Diameter"), sc.unitLINEAR, 12.7, 0, 6096, "holeDia.png")
AddNumControl("filletRad", TR("Fillet Radius"), sc.unitLINEAR, 12.7, 0, 6096, "fillet.png")
