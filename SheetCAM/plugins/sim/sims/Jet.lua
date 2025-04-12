function OnAbout(event)
   ctrl = event:GetTextCtrl()
   ctrl:AppendText("Simulator post processor for plasma\n")
end


--   Created 15/8/2008


function OnInit()
   post.SetEncoding(wx.wxFONTENCODING_UTF8)
   post.Text("CL \"" .. _("Torch on") .. "\"\n")   --index=1
   post.Text("CL \"" .. _("Waiting") .. "\"\n")    --index=2

   post.Text("CN \"" .. _("Feed rate") .. "\" " .. sc.unitFEED .. "\n")  --index=1
   post.Text("CT \"" .. _("Code snippet") .. "\"\n") --special case - auto filled by sim.lua

   post.Text("DC\n")

   post.Text ("SZ ", safeZ)
   post.Eol()

   post.Text("TS 0")
   post.Eol()

   post.Text ("ZO ", materialTop)
   post.Eol()

   bigArcs = 1 --stitch arc segments together
   minArcSize = 0.05 --arcs smaller than this are converted to moves
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


function OnPenDown()
   if (preheat > 0.001) then
      endZ = cutHeight
      OnRapid()
      post.Text("TS 1")
      post.Eol();
      DoPause(preheat)
   end
   endZ = pierceHeight
--   local ex = endX
--   local ey = endY
   endX = currentX
   endY = currentY
   OnRapid()
   post.Text("SL 1 1\n")
   post.Text("TL ",materialThick + pierceHeight - materialTop)
   post.Eol();
   post.Text("TS 2")
   post.Eol();
   DoPause(pierceDelay)
   endZ = cutHeight
   OnMove()
end

function DoPause(delay)
   if (delay > 0.001) then
      post.Text("SL 2 1\n")
      post.Text("PS ",pierceDelay)
      post.Eol()
      post.Text("SL 2 0\n")
   end
end

function OnPenUp()
   post.Text("SL 1 0\n")
   post.Text("TL ",1)
   post.Eol();
   post.Text("TS ",0)
   post.Eol();
   DoPause(endDelay)
end




function OnDrill()
   OnRapid()
   currentX = endX
   currentY = endY
   OnPenDown()
   endZ = drillZ
   OnMove()
   OnPenUp()
   endZ = safeZ
   OnRapid()
end

function OnSetFeed()
   post.Text ("SN 1 ", feedRate)
   post.Eol()
   post.Text ("FR ", feedRate)
   post.Eol()
   if (feedRate <= 0) then
      post.Warning("WARNING: Feed rate is zero")
   end

end

function OnToolChange()
   post.Text("TD ",toolDia)
   post.Eol();
   post.Text("TL 1")
   post.Eol();
   post.Text("TT \"",toolClass , "\"")
   post.Eol();
   post.Text("TS 0")
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

function OnComment()
   post.Text(" " , commentText, "\n")
end
