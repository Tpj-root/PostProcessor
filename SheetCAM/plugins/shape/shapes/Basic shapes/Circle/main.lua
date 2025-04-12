--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: CIRCLE

shape = {}

function shape.Calculate()
   local dd = shape.diameter
    
	Circle(0, 0, dd)
	
 end

AddNumControl("diameter", TR("Diameter"), sc.unitLINEAR, 101.6, 0.0254, 6096, "diameter.png")

