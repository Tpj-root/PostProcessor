--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: Donut

shape = {}

function shape.Calculate()
   local dd1 = shape.diameter1
   local dd2 = shape.diameter2
    
	Circle(0, 0, dd1)
	Circle(0, 0, dd2)
	
 end

AddNumControl("diameter1", TR("Inside Diameter"), sc.unitLINEAR, 50.8, 0.0254, 6096, "insidediameter.png")
AddNumControl("diameter2", TR("Outside Diameter"), sc.unitLINEAR, 101.6, 0.0254, 6096, "outsidediameter.png")

