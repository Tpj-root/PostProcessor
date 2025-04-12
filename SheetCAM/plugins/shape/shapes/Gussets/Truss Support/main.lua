--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: Truss Support

-- CREATED BY: David McCullough

shape = {}

function shape.Calculate()
    local bhw = shape.baseWidth / 2
	local thw = shape.topWidth / 2
	Line(-bhw, shape.vertSide, -bhw, 0)
    LineTo(bhw, 0)
	LineTo(bhw, shape.vertSide)
	LineTo(thw, shape.Height)
	LineTo(-thw, shape.Height)
	LineTo(-bhw, shape.vertSide)
end

AddNumControl("baseWidth", TR("Base Width"), sc.unitLINEAR, 101.6, 0.0254, 6096, "baseWidth.png")
AddNumControl("Height", TR("Overall Height"), sc.unitLINEAR, 50.8, 0.0254, 6096, "Height.png")
AddNumControl("topWidth", TR("Top Width"), sc.unitLINEAR, 25.4, 0.0254, 6096, "topWidth.png")
AddNumControl("vertSide", TR("Side Height"), sc.unitLINEAR, 12.7, 0.0254, 6096, "vertSide.png")