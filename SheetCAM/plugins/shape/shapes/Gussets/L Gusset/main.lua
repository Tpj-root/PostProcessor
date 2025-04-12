--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: L Gusset

-- CREATED BY: David McCullough

shape = {}

function shape.Calculate()
    MoveTo(0,0)
	Line(0, 0, shape.oWidth, 0)
    LineTo(shape.oWidth, shape.oHeight - shape.iHeight)
	LineTo(shape.oWidth - shape.iWidth, shape.oHeight - shape.iHeight)
	LineTo(shape.oWidth - shape.iWidth, shape.oHeight)
	LineTo(0, shape.oHeight)
	LineTo(0, 0)
   end

AddNumControl("oWidth", TR("Outer Width"), sc.unitLINEAR, 50.8, 0.0254, 6096, "outWidth.png")
AddNumControl("oHeight", TR("Outer Height"), sc.unitLINEAR, 101.6, 0.0254, 6096, "outHeight.png")
AddNumControl("iWidth", TR("Inner Width"), sc.unitLINEAR, 25.4, 0.0254, 6096, "inWidth.png")
AddNumControl("iHeight", TR("Inner Height"), sc.unitLINEAR, 50.8, 0.0254, 6096, "inHeight.png")