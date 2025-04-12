--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: TRAPEZOID

-- CREATED BY: David McCullough

shape = {}

function shape.Calculate()
	Line(0,0,shape.base,0)
	Line(shape.base,0,shape.base-shape.rightoffset,shape.rightheight)
	Line(shape.base-shape.rightoffset,shape.rightheight,0+shape.leftoffset,shape.leftheight)
	Line(0+shape.leftoffset,shape.leftheight,0,0)  
   end

AddNumControl("base", TR("Base"), sc.unitLINEAR, 101.6, 0.0254, 6096, "base.png")
AddNumControl("leftheight", TR("Left Height"), sc.unitLINEAR, 152.4, 0.0254, 6096, "leftheight.png")
AddNumControl("rightheight", TR("Right Height"), sc.unitLINEAR, 101.6, 0.0254, 6096, "rightheight.png")
AddNumControl("leftoffset", TR("Left Offset"), sc.unitLINEAR, 0, -6096, 6096, "leftoffset.png")
AddNumControl("rightoffset", TR("Right Offset"), sc.unitLINEAR, 25.4, -6096, 6096, "rightoffset.png")
