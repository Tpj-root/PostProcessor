--Circle(x, y, diameter) -- circle
--Line( x1, y1, x2, y2) -- Line from X1, Y1 to X2, Y2
--MoveTo( x, y) -- Set Current Position
--LineTo(x , y) -- Line from current position to X, Y.
--ArcA(startX, startY, CentreX, centreY, angle) -- angle in Radians, Positive Angle Clockwise

-- line with zero length = "point"

-- SHAPE NAME: Lifting Lug

-- CREATED BY: David McCullough

shape = {}

function shape.Calculate()
   local hw = shape.width / 2
   local hh = shape.height / 2
   local od = shape.odiameter
   local id = shape.idiameter
   local ir = shape.idiameter / 2
   local outr = shape.odiameter / 2
   local slantht1 = shape.height - shape.strht - outr
   local slantwd1 = (shape.width - shape.odiameter) / 2
   local alpha = math.atan(slantwd1/slantht1)
   local slantht2 = slantht1 + math.sin(alpha) * outr
   local slantwd2 = slantwd1 + outr - (math.cos(alpha) * outr)
   
   
    Line(0, 0, shape.width, 0)
	Line(shape.width, 0, shape.width, shape.strht)
	Line(shape.width, shape.strht, shape.width - slantwd2, shape.strht + slantht2)
	ArcA(shape.width - slantwd2, shape.strht + slantht2, hw, shape.height - outr, -(math.pi - (2 * alpha)))
	LineTo(0, shape.strht)
	LineTo(0, 0)
	Circle(hw, shape.height - outr, id)
	
	   
   end

AddNumControl("width", TR("Width"), sc.unitLINEAR, 152.4, 0.0254, 6096, "width.png")
AddNumControl("height", TR("Height"), sc.unitLINEAR, 152.4, 0.0254, 6096, "height.png")
AddNumControl("idiameter", TR("Inside Diameter"), sc.unitLINEAR, 57.15, 0, 6096, "idiameter.png")
AddNumControl("odiameter", TR("Outside Diameter"), sc.unitLINEAR, 101.6, 0.0254, 6096, "odiameter.png")
AddNumControl("strht", TR("Straight Height"), sc.unitLINEAR, 12.7, 0, 6096, "straightht.png")

