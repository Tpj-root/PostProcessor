--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: PARALLELOGRAM

--CREATED BY: David McCullough

shape = {}

function shape.Calculate()
	Line(0,0,shape.width,0)
	Line(shape.width,0,shape.width+(shape.height*math.tan(math.pi/2-shape.angle)),shape.height)
	Line(shape.width+(shape.height*math.tan(math.pi/2-shape.angle)),shape.height,0+(shape.height*math.tan(math.pi/2-shape.angle)),shape.height)
	Line(0+(shape.height*math.tan(math.pi/2-shape.angle)),shape.height,0,0)  
   end

AddNumControl("width", TR("Width"), sc.unitLINEAR, 101.6, 0.0254, 6096, "width.png")
AddNumControl("height", TR("Height"), sc.unitLINEAR, 152.4, 0.0254, 6096, "height.png")
AddNumControl("angle", TR("Corner Angle"), sc.unitANGULAR, math.pi/2, 0.000175, math.pi - .000175, "angle.png")

