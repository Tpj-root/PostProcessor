--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: Triangular Gusset

shape = {}

function shape.Calculate()
   local c = sc.Coord2D(0,0)
   Line(shape.chamfer, 0, shape.s1, 0)
   Line(shape.s1,0,shape.s1,shape.edge)
   local ang = (math.pi / 2) - shape.angle
   local ang2 = ang - (math.pi / 2)
   e = c:ArcPoint(ang, shape.s2)
   f = e:ArcPoint(ang2, -shape.edge)
   LineTo(f.x, f.y)
   LineTo(e.x, e.y)
   e = c:ArcPoint(ang, shape.chamfer)
   LineTo(e.x, e.y)
   LineTo(shape.chamfer, 0)   
end

AddNumControl("s1", TR("Width"), sc.unitLINEAR, 101.6, 0.0254, 6096, "width.png")
AddNumControl("s2", TR("Height"), sc.unitLINEAR, 101.6, 0.0254, 6096, "height.png")
AddNumControl("edge", TR("Edge Chamfer"), sc.unitLINEAR, 12.7, 0, 6096, "edge.png")
AddNumControl("angle", TR("Angle"), sc.unitANGULAR, math.pi / 2, 0.000175, 3.141415, "angle.png")
AddNumControl("chamfer", TR("Corner Chamfer"), sc.unitLINEAR, 12.7, 0, 6096, "chamfer.png")
