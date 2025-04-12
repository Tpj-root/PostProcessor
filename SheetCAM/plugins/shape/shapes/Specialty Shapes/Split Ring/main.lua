--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: Split Ring

-- CREATED BY: David McCullough

shape = {}

function shape.Calculate()
   local dd1 = shape.diameter1
   local dd2 = shape.diameter2
   local rr1 = shape.diameter1 / 2
   local rr2 = shape.diameter2 / 2
   local c = sc.Coord2D(0,0)
   e = c:ArcPoint(-shape.angle+(math.pi/2),rr2)
    MoveTo(0,0)
	Line(rr1,0,rr2,0)
	ArcA(rr2,0,0,0,math.pi*2-shape.angle)
	MoveTo(rr1,0)
	ArcA(rr1,0,0,0,math.pi*2-shape.angle)
	LineTo(e.x,e.y)
	
 end

AddNumControl("diameter1", TR("Inside Diameter"), sc.unitLINEAR, 50.8, 0.0254, 6096, "id.png")
AddNumControl("diameter2", TR("Outside Diameter"), sc.unitLINEAR, 101.6, 0.0254, 6096, "od.png")
AddNumControl("angle", TR("Opening Angle"), sc.unitANGULAR, 1.570795, 0.000175, 6.283005, "angle.png")
