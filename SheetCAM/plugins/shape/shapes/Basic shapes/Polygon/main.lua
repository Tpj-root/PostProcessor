-- Circle(x, y, diameter) -- circle
-- Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
-- MoveTo( x, y) -- Set Current Position
-- LineTo(x , y) -- Line from current position to X, Y.
-- ArcA(startX, startY, CentreX, centreY, angle) -- ngle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: INSCRIBED / CIRCUMSCRIBED CIRCLE Polygon

shape = {}

function shape.Calculate()

   local inc = (math.pi * 2) / shape.sides
   local a = shape.angle
   if(shape.sides % 2) == 0 then --make sure even sided shapes have the flat at the bottom when angle = 0
      a = a + (inc / 2)
   end
   local rad = shape.od / 2
   
   if shape.inOutShape == 0 then -- Inscribed
      rad = rad / math.cos(inc/2)
   end
   
   for count = 0, shape.sides do
      local x = math.sin(a) * rad
      local y = math.cos(a) * rad
      if(count == 0) then
         MoveTo(x,y)
      else
         LineTo(x,y)
      end
      a = a + inc
   end
end

AddNumControl("od", TR("Circle Diameter"), sc.unitLINEAR, 152.4, 0.0254, 6096, "circle.png")
AddNumControl("sides", TR("Number of Sides"), sc.unit0DECPLACE, 5, 3, 6096, "sides.png")
AddNumControl("angle", TR("Angle"), sc.unitANGULAR, 0, -math.pi * 2, math.pi * 2, "angle.png")
AddChoiceControl("inOutShape", TR("Shape Location"), {TR("Inscribed"),TR("Circumscribed")}, "location.png")

