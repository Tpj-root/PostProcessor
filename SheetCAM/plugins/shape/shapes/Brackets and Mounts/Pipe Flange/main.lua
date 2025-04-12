--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: Pipe Flange

shape = {}

function shape.Calculate()
   EnableControl("id", shape.ctrShape == 0 or shape.ctrShape == 1)

   Circle(0, 0, shape.od)
   
   if shape.ctrShape == 0 then --round
      Circle(0,0,shape.id)
   elseif shape.ctrShape == 1 then --square
      local s = shape.id / 2
      Line(-s, -s, -s, s)
      LineTo(s,s)
      LineTo(s,-s)
      LineTo(-s,-s)
   end
   local inc = ( 2 * math.pi) / shape.nHoles
   local ang = 0
   local pcd = shape.pcd / 2
   for ct=1, shape.nHoles do
      local x = math.sin(ang) * pcd
      local y = math.cos(ang) * pcd
      Circle(x, y, shape.holeDia)
      ang = ang + inc
   end
end

AddNumControl("od", TR("Outer Diameter"), sc.unitLINEAR, 101.6, 0.0254, 6096, "od.png")
AddNumControl("pcd", TR("PCD"), sc.unitLINEAR, 76.2, 0.0254, 6096, "pcd.png")
AddNumControl("nHoles", TR("Number of Holes"), sc.unit0DECPLACE, 4, 1, 6096, "nholes.png")
AddNumControl("holeDia", TR("Hole Diameter"), sc.unitLINEAR, 12.7, 0.0254, 6096, "holedia.png")
AddChoiceControl("ctrShape", TR("Center Hole Shape"), {"Round","Square","None"}, "")
AddNumControl("id", TR("Center Hole Size"), sc.unitLINEAR, 50.8, 0, 6096, "id.png")

