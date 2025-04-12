function OnAbout(event)
   ctrl = event:GetTextCtrl()
   ctrl:AppendText("Simulator post processor for milling\n")
end

post.SetOptions(post.ARC_SEGMENTS)

function OnInit()
   post.SetEncoding(wx.wxFONTENCODING_UTF8)
   post.Text("CL \"" .. _("Spindle CW") .. "\"\n")   --index=1
   post.Text("CL \"" .. _("Spindle CCW") .. "\"\n")  --index=2
   post.Text("CL \"" .. _("Flood coolant") .. "\"\n")--index=3
   post.Text("CL \"" .. _("Mist coolant") .. "\"\n") --index=4

   post.Text("CN \"" .. _("Feed rate") .. "\" " .. sc.unitFEED .. "\n")  --index=1
   post.Text("CN \"" .. _("Spindle speed") .. "\" " .. sc.unitRPM .. "\n")--index=2

   post.Text("CT \"" .. _("Tool") .. "\"\n")         --index=1
   post.Text("DC\n")

   post.Text ("SZ ", safeZ)
   post.Eol()
   post.Text("TS ",0)
   post.Eol()
   post.Text ("ZO ", materialTop)
   post.Eol()


   bigArcs = 1 --stitch arc segments together
   minArcSize = 0.05 --arcs smaller than this are converted to moves
   feedPerRev = nil
end

function OnNewLine()
end


function OnFinish()
end

function OnRapid()
   if(endX > 10000000) then
      endX = currentX
      if(endX > 10000000) then
         endX = 0
      end
   end
   if(endY > 10000000) then
      endY = currentY
      if(endY > 10000000) then
         endY = 0
      end
   end
   if(endZ > 10000000) then
      endZ = currentZ
      if(endZ > 10000000) then
         endZ = safeZ
      end
   end
   post.Text ("RM")
   post.Text (" ", endX)
   post.Text (" ", endY)
   post.Text (" ", (endZ + toolOffset))
   post.Eol()
end

function OnMove()
   if(endX > 10000000) then
      endX = currentX
      if(endX > 10000000) then
         endX = 0
      end
   end
   if(endY > 10000000) then
      endY = currentY
      if(endY > 10000000) then
         endY = 0
      end
   end
   if(endZ > 10000000) then
      endZ = currentZ
      if(endZ > 10000000) then
         endZ = 0
      end
   end
   post.Text ("MV")
   post.Text (" ", endX)
   post.Text (" ", endY)
   post.Text (" ", (endZ + toolOffset))
   post.Eol()
end

function OnArc()
   post.Text("AR ")
   post.Text (" ", arcCentreX)
   post.Text (" ", arcCentreY)
   post.Text (" ", endZ + toolOffset)
   post.Text (" ", arcAngle)
   post.Eol()
end


function OnSpindleCW()
   post.Text("SL 1 1\n")
   post.Text("SL 2 0\n")
   post.Text("TS 1")
   post.Eol();
end

function OnSpindleCCW()
   post.Text("SL 1 0\n")
   post.Text("SL 2 1\n")
   post.Text("TS 2")
   post.Eol();
end

function OnSpindleOff()
   post.Text("SL 1 0\n")
   post.Text("SL 2 0\n")
   post.Text("TS 0")
   post.Eol();
end

function OnComment()
  post.Text(" ",commenttext,"\n")
end

function OnToolChange()
   post.Text("ST 1 \"T", tool, " " ,toolName, "\"")
   post.Eol();
   post.Text("TD ",toolDia)
   post.Eol();
   post.Text("TA ",toolAngle)
   post.Eol();
   post.Text("TL ",toolFluteLength)
   post.Eol();
   post.Text("TT \"",toolClass , "\"")
   post.Eol();
   post.Text("TS ",0)
   post.Eol();
end

function OnSpindleChanged()
   post.Text("SN 2 ",spindleSpeed)
   post.Eol();
end

function OnNewOperation()
   post.Text("OP ",operationIndex)
   post.Eol();
end

function OnNewPart()
   post.Text("PT ",partIndex)
   post.Eol();
end


function OnFloodOn()
   post.Text("SL 3 1\n")
   post.Text("SL 4 0\n")
end

function OnMistOn()
   post.Text("SL 3 0\n")
   post.Text("SL 4 1\n")
end

function OnCoolantOff()
   post.Text("SL 3 0\n")
   post.Text("SL 4 0\n")
end

function OnDrill()
   OnRapid()
   depth = drillStart
   buffer = plungeSafety
   endZ = depth + buffer
   OnRapid()
   if(drillRetract < buffer) then
     buffer = drillRetract
   end
   while depth > drillZ do
      OnRapid()
      depth = depth - drillPeck
      if (depth < drillZ) then
         depth = drillZ
      end
      endZ = depth
      OnMove()
      if (depth > drillZ) then --retract if we need to take another bite
         endZ = endZ + drillRetract
         if (endZ > safeZ) then
            endZ = safeZ
         end
         OnRapid()
      end
      endZ = depth + buffer
   end
   if (endZ < safeZ) then
      endZ = safeZ
      OnRapid()
   end
end

function OnSetFeed()
   post.Text ("SN 1 ", feedRate)
   post.Eol()
   fr = feedRate
   if(feedPerRev) then
      fr = fr * spindleSpeed
   end
   post.Text ("FR ", fr)
   post.Eol()
   if (feedRate <= 0) then
      post.Warning("WARNING: Feed rate is zero")
   end
end

function OnTapStart()
   feedPerRev = true
end

function OnAutoTap()
   clearance = 1 --tapping clearance height

--move to hole X,Y coordinates
   OnRapid()

--move to tapping clearance height
   clearance = clearance + drillStart
   endZ = clearance
   OnRapid()

--feed to depth
   feedRate = tapPitch * underFeed
   OnSetFeed()
   endZ = drillZ
   OnMove()

--retract to engage reverse clutch
   endZ = drillZ + tapTravel
   feedRate = 10000
   OnSetFeed()
   OnMove()

--feed out
   feedRate = tapPitch * reverseMult * underFeed
   OnSetFeed()
   endZ = tapTravel + clearance
   OnMove()

--retract to clearance plane
   endZ = safeZ
   OnRapid()

end

function OnRigidTap()
   clearance = 1 --tapping clearance height

   spindlecache = spindleSpeed

--spindle forwards
   if(spindleDir == 1) then
      OnSpindleCW()
   else
      OnSpindleCCW()
   end


--move to hole X,Y coordinates
   OnRapid()

--move to tapping clearance height
   endZ = clearance + drillStart
   OnRapid()

--tap to depth, correcting for underfeed
   feedRate = tapPitch * underFeed
   OnSetFeed()
   feedRate = feedRate * spindleSpeed
   depthfix = (drillStart - drillZ) * (1 - underFeed)
   endZ = drillZ + depthfix
   OnMove()

--reverse spindle
   OnSpindleOff()
   spindleSpeed = spindlecache * reverseMult
   if(spindleDir == -1) then
      OnSpindleCW()
   else
      OnSpindleCCW()
   end

--feed out
   feedRate = tapPitch * reverseMult * underFeed
   OnSetFeed()
   endZ = clearance + drillStart
   OnMove()

--stop spindle and restore speed to tapping speed
   OnSpindleOff()
   spindleSpeed = spindlecache
   OnSetFeed()


--retract to clearance plane
   endZ = safeZ
   OnRapid() --retract to clearance plane

end


function OnTapEnd()
   feedPerRev = nil
end
