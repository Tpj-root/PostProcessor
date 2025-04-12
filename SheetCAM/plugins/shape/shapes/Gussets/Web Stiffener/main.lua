--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: Web Stiffner

-- CREATED BY: David McCullough

shape = {}

function shape.Calculate()
   Line(shape.chamfer,0,shape.width,0)
   Line(shape.width,0,shape.width,shape.height)
   Line(shape.width,shape.height,shape.chamfer,shape.height)
   Line(shape.chamfer,shape.height,0,shape.height-shape.chamfer)
   Line(0,shape.height-shape.chamfer,0,shape.chamfer)
   Line(0,shape.chamfer,shape.chamfer,0)
end

AddNumControl("width", TR("Width"), sc.unitLINEAR, 50.8, 0.0254, 6096, "width.png")
AddNumControl("height", TR("Height"), sc.unitLINEAR, 101.6, 0.0254, 6096, "height.png")
AddNumControl("chamfer", TR("Corner Chamfer"), sc.unitLINEAR, 12.7, 0, 6096, "chamfer.png")
