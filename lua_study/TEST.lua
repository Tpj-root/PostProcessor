-- Fake post environment for runtime test

post = {
    Text = function(txt)
        io.write(txt)
    end,
    Number = function(value, fmt)
        io.write(string.format(fmt or "%.3f", value) .. "\n")
    end,
    NonModalNumber = function(label, val, fmt)
        io.write(label .. string.format(fmt or "%.3f", val) .. " ")
    end,
    ModalText = function(txt)
        io.write(txt .. " ")
    end,
    Eol = function()
        io.write("\n")
    end
}

math.toint = function(x) return math.floor(x + 0.5) end
math.hypot = function(x, y) return math.sqrt(x^2 + y^2) end

-- Sample input values
scale = 1
metric = 1
inch = 0
lineNumber = 10
currentX = 0
currentY = 0
curx = 0
cury = 0
endX = 10
endY = 5
arcAngle = 90
arcCentreX = 5
arcCentreY = 2.5
toolClass = ""
drillZ = -2
safeZ = 5

-- Paste your Lua functions here
-- ↓↓↓ paste full code here ↓↓↓
-- (Paste from OnInit() to OnDrill())
function OnAbout(event)
   ctrl = event:GetTextCtrl()
   ctrl:AppendText("Burny 2.5 and 3\n")
   ctrl:AppendText("\n")
   ctrl:AppendText("Uses incremental I,J.\n")
end


--   Created 30/6/2006
-- Added drilling 13/5/2010

toolClass = "" --a fudge to make the post work with earlier versions of SheetCam

function OnInit()
   nolines = true
   post.Text("%\n")
   nolines = nil
   if(scale == metric) then
      post.Text ("G71\n") --metric mode
   else
      post.Text ("G70\n") --inch mode
   end
   post.Text ("G91\nG40\n")
   bigarcs = 1 --stitch arc segments together
   minArcSize = 0.2 --arcs smaller than this are converted to moves
   curx =0
   cury =0
end

function OnNewLine()
   if nolines then return end
   post.Text ("N")
   post.Number (lineNumber, "0000")
   lineNumber = lineNumber + 10
end

function OnFinish()
   endX = 0
   endY = 0
   OnRapid()
   post.Text ("M30\n")
end

function OnRapid()
   if (math.hypot(endX - currentX, endY - currentY) < 0.01) then return end
   if(endX >= 1e17 and endY >= 1e17) then return end
--   post.Text("G0");
   doxy()
   post.Eol()
end

function OnMove()
   if (math.hypot(endX - currentX, endY - currentY) < 0.01) then return end
--   post.ModalText("G1");
   doxy()
   post.Eol()
end

function doxy()
   if(endX < 1e17) then
      tmp = (endX * scale) - curx
      tmp = math.toint(tmp * 1000)/1000
      curx = curx + tmp
      if(tmp ~=0) then
         post.NonModalNumber("Y",tmp,"0.0##")
      end
   end

   if(endY < 1e17) then
      tmp = (endY * scale) - cury
      tmp = math.toint(tmp * 1000)/1000
      cury = cury + tmp
      if(tmp ~=0) then
         post.NonModalNumber("X",-tmp,"0.0##")
      end
   end
end

function OnArc()
   if(arcAngle <0) then
      post.ModalText ("G3")
   else
      post.ModalText ("G2")
   end
--   post.CancelModaltext()
   local cx = curx
   local cy = cury
   doxy()
   if((arcCentreX - currentX) ~=0) then
      post.NonModalNumber ("J", -((arcCentreX * scale) - cx), "0.0##")
   end
   if((arcCentreY - currentY) ~=0) then
      post.NonModalNumber ("I", (arcCentreY * scale) - cy, "0.0##")
   end
   post.Eol()
end

function OnPenDown()
   if(toolClass == "MarkerTool") then
      post.Text("M08\n")
   else
      post.Text("M04\n")
   end
end

function OnPenUp()
   if(toolClass == "MarkerTool") then
      post.Text("M09\n")
   else
      post.Text("M03\n")
   end
end


function OnDrill()
   OnRapid()
   OnPenDown()
   endZ = drillZ
   OnMove()
   OnPenUp()
   endZ = safeZ
   OnRapid()
end


-- Run test
OnInit()  -- %
--           G71
OnRapid()  --
OnMove()  --
OnArc()  --
OnPenDown()  --
OnPenUp()  --
OnDrill()  --
OnFinish()  -- M30
