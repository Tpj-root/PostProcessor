--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: Rectangle w/ multiple holes

--CREATED BY: Les Newell, modified by David McCullough

shape = {}

function shape.Calculate()
   EnableControl("ctrDia", shape.ctrShape == 1 or shape.ctrShape == 3)
   EnableControl("inOutShape", shape.ctrShape == 4)
   EnableControl("ctrS1", shape.ctrShape == 2)
   EnableControl("ctrS2", shape.ctrShape == 2)
   EnableControl("ctrfilletRad", shape.ctrShape == 2)
   EnableControl("sides", shape.ctrShape == 3)
   EnableControl("ctrAng", shape.ctrShape == 3 or shape.ctrShape == 2)
   EnableControl("ctrOffX", shape.ctrShape == 1 or shape.ctrShape == 2 or shape.ctrShape == 3)
   EnableControl("ctrOffY", shape.ctrShape == 1 or shape.ctrShape == 2 or shape.ctrShape == 3)
   
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
   y = hh - shape.holeVert
   for p=2,shape.holeVNo - 1 do
      Circle(-hw, y, shape.holeDia)
      Circle(hw, y, shape.holeDia)
      y = y - shape.holeVert
   end
   if shape.ctrShape == 1 then --round
      Circle(0 + shape.ctrOffX,0 + shape.ctrOffY, shape.ctrDia)
   elseif shape.ctrShape == 2 then --rectangle
      local chw = shape.ctrS1 / 2
      local chh = shape.ctrS2 / 2
      local cr = shape.ctrfilletRad
	  local Xoff = shape.ctrOffX
	  local Yoff = shape.ctrOffY
      Line(-chw + Xoff, -chh + cr + Yoff, -chw + Xoff, chh - cr + Yoff)
      ArcA(-chw + Xoff, chh - cr + Yoff, -chw + cr + Xoff, chh - cr + Yoff, math.pi/2)
      LineTo(chw - cr + Xoff, chh + Yoff)
      ArcA(chw - cr + Xoff, chh + Yoff, chw - cr + Xoff, chh - cr + Yoff, math.pi/2)
      LineTo(chw + Xoff, -chh + cr + Yoff)
      ArcA(chw + Xoff, -chh + cr + Yoff, chw - cr + Xoff, -chh + cr + Yoff, math.pi/2)
      LineTo(-chw + cr + Xoff, -chh + Yoff)
      ArcA(-chw + cr + Xoff, -chh + Yoff, -chw + cr + Xoff, -chh + cr + Yoff, math.pi/2)
   elseif shape.ctrShape == 3 then --polygon

      local inc = (math.pi * 2) / shape.sides
      local a = shape.ctrAng
	  local xOff = shape.ctrOffX
	  local yOff = shape.ctrOffY
      if(shape.sides % 2) == 0 then --make sure even sided shapes have the flat at the bottom when angle = 0
         a = a + (inc / 2)
      end
      local rad = shape.ctrDia / 2
      
      if shape.inOutShape == 0 then -- Inscribed
         rad = rad / math.cos(inc/2)
      end
      
      for count = 0, shape.sides do
         local x = math.sin(a) * rad
         local y = math.cos(a) * rad
         if(count == 0) then
            MoveTo(x + xOff,y + yOff)
         else
            LineTo(x + xOff,y + yOff)
         end
         a = a + inc
      end
   end
end

AddNumControl("width", "Width", sc.unitLINEAR, 101.6, 0.0254, 6096, "width.png")
AddNumControl("height", "Height", sc.unitLINEAR, 101.6, 0.0254, 6096, "height.png")
AddNumControl("holeHNo", "Horizontal Hole Number", sc.unit0DECPLACE, 4, 0, 100, "hHoleNo.png")
AddNumControl("holeHoriz", "Horizontal Hole Spacing", sc.unitLINEAR, 25.4, 0, 6096, "hHole.png")
AddNumControl("holeVNo", "Vertical Hole Number", sc.unit0DECPLACE, 4, 0, 100, "vHoleNo.png")
AddNumControl("holeVert", "Vertical Hole Spacing", sc.unitLINEAR, 25.4, 0, 6096, "vHole.png")
AddNumControl("holeDia", "Hole Diameter", sc.unitLINEAR, 12.7, 0, 6096, "holeDia.png")
AddNumControl("filletRad", "Fillet Radius", sc.unitLINEAR, 12.7, 0, 6096, "fillet.png")
AddChoiceControl("ctrShape", "Center Hole Shape", {"None","Round","Rectangle","Polygon"}, "")
AddNumControl("ctrDia", "Center Hole Size", sc.unitLINEAR, 12.7, 0.0254, 6096, "ctrDia.png")
AddChoiceControl("inOutShape", "Shape Location", {"Inscribed","Circumscribed"}, "location.png")
AddNumControl("ctrS1", "Center Hole Width", sc.unitLINEAR, 12.7, 0.0254, 6096, "ctrWidth.png")
AddNumControl("ctrS2", "Center Hole Height", sc.unitLINEAR, 25.4, 0.0254, 6096, "ctrHeight.png")
AddNumControl("ctrfilletRad", "Center Fillet Radius", sc.unitLINEAR, 3.175, 0, 6096, "ctrFillet.png")
AddNumControl("sides", "Number of sides", sc.unit0DECPLACE, 5, 3, 6096, "ctrSides.png")
AddNumControl("ctrAng", "Center Hole Angle", sc.unitANGULAR, 0, -math.pi*2, math.pi*2, "ctrAng.png")
AddNumControl("ctrOffX", "Center Hole X Offset", sc.unitLINEAR, 0, -6096, 6096, "ctrOffX.png")
AddNumControl("ctrOffY", "Center Hole Y Offset", sc.unitLINEAR, 0, -6096, 6096, "ctrOffY.png")