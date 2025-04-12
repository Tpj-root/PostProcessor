--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: CONVEX RECTANGLE

shape = {}

function shape.Calculate()
   local hw = shape.width / 2
   local hh = shape.height / 2
    MoveTo(0,0)
	Line(-hw, hh, -hw, -hh)
    Line(-hw, -hh, hw, -hh)
	Line(hw, -hh, hw, hh)
	ArcA(hw, hh, 0, hh, -math.pi)
	   
   end

AddNumControl("width", TR("Width"), sc.unitLINEAR, 101.6, 0.0254, 6096, "width.png")
AddNumControl("height", TR("Height"), sc.unitLINEAR, 152.4, 0.0254, 6096, "height.png")
