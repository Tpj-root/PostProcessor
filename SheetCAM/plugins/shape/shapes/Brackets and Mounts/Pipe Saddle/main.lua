--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: Pipe Saddle

-- CREATED BY: David McCullough

shape = {}

function shape.Calculate()
   local hw = shape.width / 2
   local hh = shape.height / 2
   local pd = shape.pipediam
   local r = shape.pipediam / 2
   local st = (shape.width - shape.pipediam) / 2
   local xoff = r - math.sqrt((r * r) - (shape.ctroffset * shape.ctroffset))
   local arcstx = shape.width - st - xoff
    MoveTo(0,0)
	Line(0, 0, shape.width, 0)
    Line(shape.width, 0, shape.width, shape.height)
	Line(shape.width, shape.height, arcstx, shape.height)
	ArcA(arcstx, shape.height, hw, shape.height + shape.ctroffset, (math.pi - (2 * (math.asin(shape.ctroffset / r)))))
	Line(st + xoff, shape.height, 0, shape.height)
	Line(0, shape.height, 0, 0)
   end

AddNumControl("width", TR("Width"), sc.unitLINEAR, 101.6, 0.0254, 6096, "width.png")
AddNumControl("height", TR("Height"), sc.unitLINEAR, 152.4, 0.0254, 6096, "height.png")
AddNumControl("pipediam", TR("Pipe Diameter"), sc.unitLINEAR, 50.8, 0.0254, 6096, "pipediam.png")
AddNumControl("ctroffset", TR("Center Offset"), sc.unitLINEAR, 0, -6096, 6096, "ctroffset.png")
