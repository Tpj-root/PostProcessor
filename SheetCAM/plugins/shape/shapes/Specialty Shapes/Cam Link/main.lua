--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: Cam Link

--CREATED BY: David McCullough

shape = {}

function shape.Calculate()
   local ir1 = shape.id1 / 2
   local outr1 = shape.od1 / 2
   local ir2 = shape.id2 / 2
   local outr2 = shape.od2 / 2
   local alpha = math.asin((outr1-outr2)/(shape.ctr))
   local point1x = outr1*math.sin(alpha)
   local point1y = outr1*math.cos(alpha)
   local point2x = shape.ctr+outr2*math.sin(alpha)
   local point2y = outr2*math.cos(alpha)
    
	Circle(0,0,shape.id1)
	Circle(shape.ctr,0,shape.id2)
	Line(point1x,point1y,point2x,point2y)
	ArcA(point2x,point2y,shape.ctr,0,math.pi-(2*alpha))
	Line(point2x,-point2y,point1x,-point1y)
	ArcA(point1x,-point1y,0,0,math.pi+(2*alpha))
	   
   end

AddNumControl("ctr", TR("Pin Center Distance"), sc.unitLINEAR, 152.4, 0.0254, 6096, "center.png")
AddNumControl("id1", TR("Left Hole Dia"), sc.unitLINEAR, 76.2, 0, 6096, "id1.png")
AddNumControl("od1", TR("Left End Dia"), sc.unitLINEAR, 152.4, 0.0254, 6096, "od1.png")
AddNumControl("id2", TR("Right Hole Dia"), sc.unitLINEAR, 25.4, 0, 6096, "id2.png")
AddNumControl("od2", TR("Right End Dia"), sc.unitLINEAR, 50.8, 0.0254, 6096, "od2.png")

