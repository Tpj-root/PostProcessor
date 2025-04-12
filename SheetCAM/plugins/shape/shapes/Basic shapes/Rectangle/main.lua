--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: RECTANGLE

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
	   
   end

AddNumControl("width", TR("Width"), sc.unitLINEAR, 50.8, 0.0254, 6096, "width.png")
AddNumControl("height", TR("Height"), sc.unitLINEAR, 101.6, 0.0254, 6096, "height.png")
AddNumControl("filletRad", TR("Fillet radius"), sc.unitLINEAR, 6.35, 0, 10000, "fillet.png")