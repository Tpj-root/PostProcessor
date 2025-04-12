--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: Lap Joint

-- CREATED BY: David McCullough, adapted from code by Les Newell

shape = {}

function shape.Calculate()
   local hw = shape.width / 2
   local hh = shape.height / 2
   local r = shape.filletRad
   Line(-hw, -hh + r, -hw, hh - r)
   ArcA(-hw, hh - r, -hw + r, hh - r, math.pi/2)
   Line(-hw + r, hh, hw - r, hh)
   ArcA(hw - r, hh, hw - r, hh - r, math.pi/2)
   Line(hw, hh - r, hw, -hh + r)
   ArcA(hw, -hh + r, hw - r, -hh + r, math.pi/2)
   Line(hw - r, -hh, -hw + r, -hh)
   ArcA(-hw + r, -hh, -hw + r, -hh + r, math.pi/2)

   hw = (shape.holeHoriz * (shape.holeHNo - 1)) / 2
   hh = (shape.holeVert * (shape.holeVNo - 1)) / 2
   local x = -hw
   local y = hh
   for p=1,shape.holeHNo do
      Circle(x, y, shape.holeDia)
      x = x + shape.holeHoriz
   end
   x = -hw
   y = -hh
   for p=1,shape.holeHNo do
      Circle(x, y, shape.holeDia)
      x = x + shape.holeHoriz
   end
   x = -hw
   y = hh - shape.holeVert
   for q=1,shape.holeHNo do
		for p=2,shape.holeVNo - 1 do
			Circle(x, y, shape.holeDia)
			y = y - shape.holeVert
		end
		x = x + shape.holeHoriz
		y = hh - shape.holeVert
	end
end

AddNumControl("width", TR("Width"), sc.unitLINEAR, 203.2, 0.0254, 6096, "width.png")
AddNumControl("height", TR("Height"), sc.unitLINEAR, 101.6, 0.0254, 6096, "height.png")
AddNumControl("holeHNo", TR("Horizontal Hole Number"), sc.unit0DECPLACE, 4, 1, 100, "hHoleNo.png")
AddNumControl("holeHoriz", TR("Horizontal Hole Spacing"), sc.unitLINEAR, 50.8, 0, 6096, "hHole.png")
AddNumControl("holeVNo", TR("Vertical Hole Number"), sc.unit0DECPLACE, 4, 1, 100, "vHoleNo.png")
AddNumControl("holeVert", TR("Vertical Hole Spacing"), sc.unitLINEAR, 25.4, 0, 6096, "vHole.png")
AddNumControl("holeDia", TR("Hole Diameter"), sc.unitLINEAR, 12.7, 0.0254, 6096, "holeDia.png")
AddNumControl("filletRad", TR("Fillet Radius"), sc.unitLINEAR, 12.7, 0, 6096, "fillet.png")


