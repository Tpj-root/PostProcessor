--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: U Lug

--CREATED BY: David McCullough

shape = {}

function shape.Calculate()
   local ihw = shape.iWidth / 2
   local outRad = shape.oWidth / 2
   local thick = outRad - ihw
    MoveTo(-ihw,0)
	Line(-ihw, 0, -ihw, shape.height - outRad)
	ArcA(-ihw, shape.height - outRad, 0, shape.height - outRad, math.pi)
    LineTo(ihw, 0)
	LineTo(ihw + thick, 0)
	LineTo(ihw + thick, shape.height - outRad)
	ArcA(ihw + thick, shape.height - outRad, 0, shape.height - outRad, -math.pi)
	LineTo(-ihw - thick, 0)
	LineTo(-ihw, 0)
   end

AddNumControl("iWidth", TR("Inside Width"), sc.unitLINEAR, 25.4, 0.0254, 6096, "insideWidth.png")
AddNumControl("oWidth", TR("Outside Width"), sc.unitLINEAR, 101.6, 0.0254, 6096, "outsideWidth.png")
AddNumControl("height", TR("Overall Height"), sc.unitLINEAR, 152.4, 0.0254, 6096, "height.png")