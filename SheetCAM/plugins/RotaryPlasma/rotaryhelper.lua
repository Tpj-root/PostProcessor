--[[
You must add the following code to the END of your post file:

--Set this to the number of units for one full revolution of the A axis. For example 360 = 360 degrees.
unitsPerRev=360
package.path = sc.Globals:Get().thisDir .. "/plugins/RotaryPlasma/?.lua"
require("rotaryhelper")

--change this to 1 if your machine is a robot
--defaults to 0
isRobot = 0

--maximum error when converting arcs to multiple line segments.
--Smaller numbers give better resolution but larger code size.
--defaults to 0.1
arcResolution = 0.1

--maximum angle to move when cutting.
--Smaller numbers increase accuracy on square pipe corners but increase code size.
--defaults to 0.087266 radians (10 degrees)
maxRotation = 0.087266

-- Rapids will move the shortest distance to the next cut but may cause machines with limited rotation
-- to 'wind up'. Set this to 0 to disable optimisation.
--defaults to 1
optimiseRapids = 1 


--Set this to false if your code does not do a reference cycle
ignorePierceHeightMove = true

]]



qryGETX     = 0
qryGETY     = 1
qryGETZ     = 2
qryGETA     = 3
qrySETX     = 4
qrySETY     = 5
qrySETZ     = 6
qrySETZMOVE = 7
qryCHKEND   = 8
qryINIT     = 9
qryRAPIDY   = 10
qrySETXSTART= 11
qrySETYSTART= 12
qrySETZSTART= 13
qryRESETROT = 14
qryGETF     = 15
qryGETSAFEZ = 16
qrySETUNITS = 17
qryENDY     = 18
qrySETMAXANGLE = 19
qryOPTIMISERAPIDS = 20



endA = 0

rotaryVals = {}
rotaryVals.z = 0
rotaryVals.cx = 0
rotaryVals.cy = 0
rotaryVals.cz = 0
isRobot = 0

--rename onMove etc in the post. We can now hijack the OnMove etc calls and add the rotary stuff.
DoMove = OnMove
DoRapid = OnRapid
DoInit = OnInit
DoArc = OnArc
DoSetFeed = OnSetFeed
DoPenDown = OnPenDown
DoPenUp = OnPenUp


function OnInit()
   if not arcResolution or arcResolution < 0.0001 then
      arcResolution = 0.1
   end
   
   if(sc.GetPluginId == nil) then
      wx.wxLogMessage("This post is not compatible with this version of SheetCam")
      post.Error("This post is not compatible with this version of SheetCam")
   end
   dllId = sc.GetPluginId("RotaryPlasma")
   if(dllId < 0) then
      wx.wxLogMessage("The Rotary plasma plugin is not loaded")
      post.Error("The Rotary plasma plugin is not loaded")
   end
   if(unitsPerRev == nil) then
      post.Error("Units per rev not defined")
   end
   endA = 0
   rotaryVals.z = 0
   rotaryVals.cx = 0
   rotaryVals.cy = 0
   rotaryVals.cz = 0
   rotaryVals.f = 0
   if(sc.QueryDll(qryINIT, unitsPerRev, dllId) == nil) then
      post.Error("The Rotary plasma plugin is not enabled.\nPlease enable this plugin in Options->plugin options")
   end
   
   if maxRotation then
      sc.QueryDll(qrySETMAXANGLE, maxRotation, dllId)
   end
   if optimiseRapids then
      sc.QueryDll(qryOPTIMISERAPIDS, optimiseRapids, dllId)
   end
   
   sc.QueryDll(qrySETUNITS, scale, dllId);
   rotaryVals.lastFeed = 1e17
   DoInit()
   endX = 1e38
   endY = 1e38
   endA = 1e38
   endZ = sc.QueryDll(qryGETSAFEZ, 0, dllId) + safeZ
   DoRapid()
end

function OnRapid()
   
   local tx = endX
   local ty = endY
   local tz = endZ
   if(endX >= 1e17 or endY >= 1e17) then return end
   sc.QueryDll(qrySETXSTART, endX, dllId)
   sc.QueryDll(qrySETYSTART, endY, dllId)
   sc.QueryDll(qrySETZSTART, endZ, dllId)
   if(endZ >= safeZ) then
      local z
      if(endZ > 1e17) then
         z = sc.QueryDll(qryGETSAFEZ, 0, dllId) + safeZ
         endZ = 0
      else
         if(currentY > 1e17) then
            z = sc.QueryDll(qryCHKEND, endY, dllId)
         else
            z = sc.QueryDll(qryCHKEND, currentY, dllId)
         end
      end
--      rotaryVals.z = z
      if(z > rotaryVals.z and currentX < 1e17 and currentY < 1e17) then
         endX = rotaryVals.cx
         endY = rotaryVals.cy
         endZ = z + endZ
         DoRapid()
         endX = tx
         endY = ty
         endZ = tz
      end
      rotaryVals.z = z + endZ
   else
      sc.QueryDll(qrySETZ, endZ, dllId)
      rotaryVals.z = sc.QueryDll(qryGETZ, 0, dllId)
      if(ignorePierceHeightMove and endZ < currentZ and endZ == pierceHeight) then
         endX = tx
         endY = ty
         endZ = tz
         return
      end
   end
   OnRapid2()
   endX = tx
   endY = ty
   endZ = tz
end

function OnRapid2()
--post.Text("   R2  ex = " .. endX .. " ey = " .. endY .. " ez = " .. endZ .. "\n")
   currentX = rotaryVals.cx
   currentY = rotaryVals.cy
   currentZ = rotaryVals.cz
   endY = sc.QueryDll(qryRAPIDY, endY, dllId)
   endZ = rotaryVals.z-- + endZ --sc.QueryDll(qryGETZ, 0, dllId) + rotaryVals.z + endZ
   endA = sc.QueryDll(qryGETA, 0, dllId)
   DoRapid();
   rotaryVals.cx = endX
   rotaryVals.cy = endY
   rotaryVals.cz = endZ
end


function OnMove()
--post.Text("   M  ex=" .. endX .. " ey=" .. endY .. " ez=" .. endZ .. " cx=" .. currentX .. " cy=" .. currentY .. "\n")
   local tx = endX
   local ty = endY
   local tz = endZ
   if(sc.QueryDll(qrySETX, endX, dllId) ~= 0) then
      post.Error(_("Cannot cut on the edge of a flange"))
   end
   sc.QueryDll(qrySETY, endY, dllId)
   sc.QueryDll(qrySETZ, endZ, dllId)
   local x = sc.QueryDll(qryGETX, 0, dllId)
   while (x < 1e17) do
      currentX = rotaryVals.cx
      currentY = rotaryVals.cy
      currentZ = rotaryVals.cz
      endX = x
      endY = sc.QueryDll(qryGETY, 0, dllId)
      endZ = sc.QueryDll(qryGETZ, 0, dllId)
      endA = sc.QueryDll(qryGETA, 0, dllId)
      feedRate = sc.QueryDll(qryGETF, 0, dllId) * rotaryVals.f
      if(DoSetFeed and rotaryVals.lastFeed ~= feedRate) then
         rotaryVals.lastFeed = feedRate
         DoSetFeed()
      end
      DoMove();
      x = sc.QueryDll(qryGETX, 0, dllId)
      rotaryVals.cx = endX
      rotaryVals.cy = endY
      rotaryVals.cz = endZ
   end
   endX = tx
   endY = ty
   endZ = tz
end


function OnArc()
--post.Text("   A  ex=" .. endX .. " ey=" .. endY .. " ez=" .. endZ .. " cx=" .. arcCentreX .. " cy=" .. arcCentreY .." a=" .. arcAngle .. "\n")
   local path = sc.Path()
   path.start.x = currentX
   path.start.y = currentY
   path.ctr.x = arcCentreX
   path.ctr.y = arcCentreY
   path["end"].x = endX
   path["end"].y = endY
   path.angle = arcAngle
   path.startAngle = math.atan2(currentX - arcCentreX, currentY - arcCentreY)
   path["type"] = sc.PATH_ARC

   local tr = sc.Coord2D(-1e17, -1e17)
   local bl = sc.Coord2D(1e17, 1e17)
   path:GetExtents(bl, tr);

--post.Text("  x=" .. currentX .. " y=" .. currentY .. " cx=" .. arcCentreX .. " cy=" .. arcCentreY .. " sa=" .. path.startAngle .. " a=" .. path.angle .. " y1=" .. bl.y .. " y2=" ..tr.y .. "\n")

   sc.QueryDll(qryENDY, bl.y, dllId)
   local a1 = sc.QueryDll(qryGETA, 0, dllId)
   sc.QueryDll(qryENDY, tr.y, dllId)
   local a2 = sc.QueryDll(qryGETA, 0, dllId)

   if(a1 == a2) then
      sc.QueryDll(qrySETXSTART, endX, dllId)
      sc.QueryDll(qrySETYSTART, endY, dllId)
      sc.QueryDll(qrySETZSTART, endZ, dllId)
      endY = sc.QueryDll(qryENDY, endY, dllId)
      local oldY = currentY;
      currentY = sc.QueryDll(qryENDY, currentY, dllId)
      arcCentreY = arcCentreY + (currentY - oldY);
      endZ = sc.QueryDll(qryGETZ, 0, dllId) + endZ
      endA = sc.QueryDll(qryGETA, 0, dllId)
      feedRate = rotaryVals.f
      if(DoSetFeed and rotaryVals.lastFeed ~= feedRate) then
         rotaryVals.lastFeed = feedRate
         DoSetFeed()
      end
--post.Text("  x=" .. currentX .. " y=" .. currentY .. " cx=" .. arcCentreX .. " cy=" .. arcCentreY .. " ex=" .. endX .. " ey=" .. endY .. "\n")
      DoArc()
      rotaryVals.cx = endX
      rotaryVals.cy = endY
      rotaryVals.cz = endZ
      return
   end
   post.ArcAsMoves(arcResolution)
end

function OnSetFeed()
   rotaryVals.f = feedRate
end
