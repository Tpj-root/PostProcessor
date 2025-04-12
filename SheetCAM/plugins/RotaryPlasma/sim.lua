--    _("Rotary plasma") --A bit of fudgery here to force the plugin name to appear in the translation

--globals
panel =  nil  --options panel
auiMgr = nil --aui manager

btnCustomShapes = nil --custom shapes button in plugin options
btnStart    = nil     --start button
btnStep  = nil        --step button
btnPause    = nil     --pause button
btnStop  = nil        --stop button
sldSpeed    = nil     --speed slider
ledArray = {}         --LEDs
textArray = {}        --text boxes
numberArray = {}      --number boxes
froText     = nil     --FRO caption
machineType = nil     --Machine option
statusPanel = nil     --panel for status

snipText = nil       --text box for code snippet (optional)

posX        = nil
posY        = nil
posZ        = nil
posA        = nil
timeBox     = nil
dataFile    = nil
currentString = nil
statusSizer = nil
lineNumber  = 0
moveFunc    = nil
time        = 0

feedOverride = 1

lastDist = 0

stepCount=0
xInc = 0
yInc = 0
zInc = 0
aInc = 0

arcInc = 0
arcAngle = 0
arcRad = 0
arcCX = 0
arcCY = 0

currentX = 0
currentY = 0
currentZ = 0
currentA = 0

stepSize = 3

maxControls = 10
ledControls = 0
numberControls = 0
textControls = 0


frameRate = 25

moveFeed = 100
rapidFeed = 4000
currentFeed = 100

toolScale = 1
minDia  = 0

--notification enums from dll
luaSHOW      = 0
luaHIDE      = 1
luaERROR     = 2

--notification enums to dll
dllPOSX         =0
dllPOSY         =1
dllPOSZ         =2
dllPOSA         =3
dllTOOLDIA      =4
dllTOOLTYPE     =5
dllTOOLLENGTH   =6
dllTOOLANGLE    =7
dllTOOLSTATE    =8
dllTOOLSCALE    =9
dllROBOT        =10
dllEDITCUSTOM   =11

-- tool types for dll
toolPARALLEL   =0
toolV          =1
toolDRILL      =2
toolJET        =3

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

tempFile = wx.wxFile()

function OnSetupButton(event)
    local dialog = wx.wxDialog(wx.wxGetApp():GetTopWindow(),wx.wxID_ANY,_("Settings"))
    ShowOptions(dialog)
    local sizer = wx.wxBoxSizer(wx.wxVERTICAL)
    sizer:Add(optionPanel)
    local button = wx.wxButton(dialog,wx.wxID_OK,"")
    sizer:Add(button,0,wx.wxALL + wx.wxALIGN_CENTER,5)
    dialog:SetSizer(sizer)
    sizer:Fit(dialog)
    dialog:ShowModal()
    OnHideOptions()
end

function OnCustom()
    sc.NotifyDll(dllEDITCUSTOM,0)
end

-- ---------------------------------------------------------------------------
-- Handle the options event
-- note: this is a special event as you don't connect() it!
-- If a function with this name exists it is automatically called

function OnShowOptions(event)
    ShowOptions(event:GetPanel())
    btnCustomShapes = wx.wxButton(event:GetPanel(), wx.wxID_ANY, _("Custom tube shapes..."))
    btnCustomShapes:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED, OnCustom)
    event:GetSizer():Add(optionPanel)
    event:GetSizer():Add(btnCustomShapes)
end

function ShowOptions(parentWindow)
    -- xml style resources (if present)
    xmlResource = wx.wxXmlResource(wx.wxXRC_USE_LOCALE)
    xmlResource:InitAllHandlers()
    local xrcFilename = sc.GetMyPath().."OptionsPanel.xrc"
    xmlResource:Load(xrcFilename)
    optionPanel = wx.wxPanel()
    if not xmlResource:LoadPanel(optionPanel, parentWindow, "OptionsPanel") then
        wx.wxMessageBox("Error loading xrc resources!",
                        "Sim Options",
                        wx.wxOK + wx.wxICON_EXCLAMATION,
                        wx.NULL)
        return
    end
    rapidBox = optionPanel:FindWindow(xmlResource.GetXRCID("ID_RAPIDFEED")):DynamicCast("UnitCtrl")
    rapidBox:SetUnits(sc.unitFEED)
    rapidBox:SetMin(0)
    rapidBox:SetValue(rapidFeed)

    frameBox = optionPanel:FindWindow(xmlResource.GetXRCID("ID_FRAMERATE")):DynamicCast("UnitCtrl")
    frameBox:SetUnits(sc.unit0DECPLACE)
    frameBox:SetMin(2)
    frameBox:SetMax(100)
    frameBox:SetValue(frameRate)

--[[    diaBox = optionPanel:FindWindow(xmlResource.GetXRCID("ID_TOOLDIA")):DynamicCast("UnitCtrl")
    diaBox:SetUnits(sc.unitPERCENT)
    diaBox:SetMin(0)
    diaBox:SetMax(100)
    diaBox:SetValue(toolScale)

    minDiaBox = optionPanel:FindWindow(xmlResource.GetXRCID("ID_TOOLSIZE")):DynamicCast("UnitCtrl")
    minDiaBox:SetMin(0)
    minDiaBox:SetMax(100000)
    minDiaBox:SetValue(minDia)--]]


    maxFROBox = optionPanel:FindWindow(xmlResource.GetXRCID("ID_MAXFRO")):DynamicCast("UnitCtrl")
    maxFROBox:SetUnits(sc.unitPERCENT)
    maxFROBox:SetMin(1)
    maxFROBox:SetMax(1000)
    maxFROBox:SetValue((sldSpeed:GetMax())/100)

    cfg:SetPath("/plugins/RotaryPlasma")
--[[    pickerOff = SetPicker("ID_COLOFF","ToolColOff",127)
    pickerCW = SetPicker("ID_COLCW","ToolColCW",255)
    pickerCCW = SetPicker("ID_COLCCW","ToolColCCW",255)


    sldDetail = optionPanel:FindWindow(xmlResource.GetXRCID("ID_POLYDETAIL")):DynamicCast("wxSlider")
    a,b = cfg:Read("PolyDetail",1)
    sldDetail:SetValue(b)

]]
    machineBox = optionPanel:FindWindow(xmlResource.GetXRCID("ID_MACHINETYPE")):DynamicCast("wxChoice")
    local path = sc.GetMyPath()
    path = path .. "sims/"
    dir = wx.wxDir(path);
    a,fileName = dir:GetFirst("*.lua",wx.wxDIR_FILES)
    machineBox:Clear()
    while fileName ~= "" do
        fileName = wx.wxFileName(fileName):GetName()
        machineBox:Append(fileName)
        a,fileName = dir:GetNext()
    end
    machineBox:SetStringSelection(machineType);
    if(machineBox:GetSelection() < 0) then
        machineBox:SetSelection(0);
    end
end

function SetPicker(id,key,default)
    local picker = optionPanel:FindWindow(xmlResource.GetXRCID(id)):DynamicCast("wxColourPickerCtrl")
    local r
    local g
    local b
    local d
    d,r = cfg:Read(key .. "R",default)
    d,g = cfg:Read(key .. "G",default)
    d,b = cfg:Read(key .. "B",default)
    local colour = wx.wxColour(r,g,b)
    picker:SetColour(colour)
    return(picker)
end


function OnHideOptions()
    rapidFeed = rapidBox:GetValue()
    frameRate = frameBox:GetValue()
--    toolScale = diaBox:GetValue()
--    minDia = minDiaBox:GetValue()
    local fro = (maxFROBox:GetValue() * 100)
    sldSpeed:SetRange(1,fro + 0.5)
    cfg:SetPath("/plugins/RotaryPlasma")
    cfg:Write("MaxFRO",fro)
--    SavePicker(pickerOff,"ToolColOff")
--    SavePicker(pickerCW,"ToolColCW")
--    SavePicker(pickerCCW,"ToolColCCW")
    machineType = machineBox:GetString(machineBox:GetSelection())
--    cfg:Write("PolyDetail", sldDetail:GetValue())
--   sc.NotifyDll(dllTOOLSCALE, toolScale)

end

function SavePicker(picker,key)
    local colour = picker:GetColour()
    cfg:Write(key .. "R",colour:Red())
    cfg:Write(key .. "G",colour:Green())
    cfg:Write(key .. "B",colour:Blue())
end

-- ---------------------------------------------------------------------------
-- Handle the timer event
function OnTimer(event)
    if(moveFunc) then
        moveFunc()
    else
        OnStop()
    end
end


function LinMove()
    if(stepCount <=0) then
      CheckStep()
      return
    end
    if(stepCount <1) then
        lastDist= lastDist + stepCount
        time = time + ((1/frameRate)  * feedOverride * stepCount)
        currentX = currentX + (xInc * stepCount)
        currentY = currentY + (yInc * stepCount)
        currentZ = currentZ + (zInc * stepCount)
        currentA = currentA + (aInc * stepCount)
        stepCount =0
        if(lastDist >= 1) then
            UpdateDisplay();
            lastDist = lastDist -1
        else
            CheckStep()
        end
    else
        lastDist = 0
        time = time + ((1/frameRate)  * feedOverride)
        currentX = currentX + xInc
        currentY = currentY + yInc
        currentZ = currentZ + zInc
        currentA = currentA + aInc
        stepCount = stepCount -1
        UpdateDisplay()
    end
end

function CheckStep()
   moveFunc = Parse
   if(btnStep:GetValue()) then
      UpdateDisplay();
      timer:Stop()
      btnStart:Enable(true)
   else
      moveFunc()
   end
end

function ArcMove()
    if(stepCount <=0) then
      CheckStep()
      return
    end
    if(stepCount <1) then
        lastDist= lastDist + stepCount
        time = time + ((1/frameRate)  * feedOverride * stepCount)
        arcAngle = arcAngle + (arcInc * stepCount)
        currentX = (math.sin(arcAngle) * arcRad) + arcCX
        currentY = (math.cos(arcAngle) * arcRad) + arcCY
        currentZ = currentZ + (zInc * stepCount)
        stepCount =0
        if(lastDist >= 1) then
            UpdateDisplay();
            lastDist = lastDist -1
        else
            CheckStep()
        end
    else
        lastDist = 0
        arcAngle = arcAngle + arcInc
        currentX = (math.sin(arcAngle) * arcRad) + arcCX
        currentY = (math.cos(arcAngle) * arcRad) + arcCY
        currentZ = currentZ + zInc
        time = time + ((1/frameRate)  * feedOverride)
        stepCount = stepCount -1
        UpdateDisplay()
    end
end

function PauseMove()
    if(stepCount <=0) then
      CheckStep()
      return
    end
    time = time + ((1/frameRate)  * feedOverride)
    UpdateDisplay()
    stepCount = stepCount -1
end

function UpdateDisplay()
    posX:SetValue(currentX)
    posY:SetValue(currentY)
    posZ:SetValue(currentZ)
    posA:SetValue(currentA)
    timeBox:SetValue(time)
    sc.NotifyDll(dllPOSX,currentX)
    sc.NotifyDll(dllPOSY,currentY)
    sc.NotifyDll(dllPOSZ,currentZ)
    sc.NotifyDll(dllPOSA,currentA)
end


function Parse()
    if(dataFile == nil or dataFile:read(0) == nil) then
        OnStop(0)
        return
    end
    local getNext = true

    while getNext do
        currentString = dataFile:read()
        if(currentString == nil) then
            getNext = false
            UpdateDisplay()
            OnStop()
            break
        end
        local token = currentString:sub(1,2)
        if(currentString:sub(1,1) == " ") then --code snip
           token = ""
           if(snipText) then
            snipText:SetValue(currentString:sub(2))
           end
        end
        currentString = currentString:sub(4)
        if token == "MV" then
            DoMove(GetNumber(),GetNumber(),GetNumber(),GetNumber(),moveFeed)
            getNext = false
        elseif token == "AR" then
            DoArc(GetNumber(),GetNumber(),GetNumber(),GetNumber())
            getNext = false
        elseif token == "RM" then
            DoMove(GetNumber(),GetNumber(),GetNumber(),GetNumber(),rapidFeed)
            getNext = false
        elseif token == "CL" then
            CreateLED(GetText())
        elseif token == "CT" then
            CreateTextBox(GetText())
        elseif token == "CN" then
            CreateNumberBox(GetText(),GetNumber())
        elseif token == "SL" then
            SetLED(GetNumber(),GetNumber())
        elseif token == "ST" then
            SetTextBox(GetNumber(),GetText())
        elseif token == "SN" then
            SetNumberBox(GetNumber(),GetNumber())
        elseif token == "FR" then
            moveFeed = GetNumber()
            if(moveFeed ==0) then
                getNext = false
                OnStop()
                wx.wxMessageBox("Feed rate is 0. No motion is possible","Sim",wx.wxICON_ERROR)
                break
            end
        elseif token == "RR" then
            rapidFeed = GetNumber()
        elseif token == "DC" then
            DrawControls()
        elseif token == "SX" then
            currentX = GetNumber()
            UpdateDisplay()
        elseif token == "SY" then
            currentY = GetNumber()
            UpdateDisplay()
        elseif token == "SZ" then
            currentZ = GetNumber()
            UpdateDisplay()
        elseif token == "SA" then
            currentA = GetNumber()
            UpdateDisplay()
        elseif token == "OP" then
--            sc.SelectOperation(GetNumber())
        elseif token == "PS" then
            DoPause(GetNumber())
            getNext = false
        elseif token == "PT" then
            sc.SelectPart(GetNumber())
        elseif token == "TD" then
            dia = GetNumber()
            if(dia < minDia) then
                dia = minDia
            end
            sc.NotifyDll(dllTOOLDIA,dia)
        elseif token == "TA" then
            sc.NotifyDll(dllTOOLANGLE,GetNumber())
        elseif token == "TL" then
            sc.NotifyDll(dllTOOLLENGTH,GetNumber())
        elseif token == "TT" then
            GenToolType()
        elseif token == "TS" then
            sc.NotifyDll(dllTOOLSTATE,GetNumber())
        elseif token == "RB" then
            sc.NotifyDll(dllROBOT,1)
        elseif token ~= "" then
            ShowError("Token \"" .. token .."\" not recognised")
        end
        lineNumber = lineNumber +1
--wx.wxLogMessage("Line = " .. lineNumber)
    end
    if(moveFunc ~= Parse and movefunc) then
        moveFunc()
    end
end

function GenToolType()
   local tt = 0
   local tName = GetText()
   if (tName == "VTool") then
      tt = toolV
   else if (tName == "PlasmaTool" or tName == "FlameTool" or
         tName == "WaterTool" or tName == "LaserTool") then
         tt = toolJET
      else if(tname == "DrillTool") then
         tt = toolDRILL
         end
      end
   end
   sc.NotifyDll(dllTOOLTYPE,tt)
end

function DoPause(delay)
    UpdateDisplay()
    stepCount = (delay * frameRate) /feedOverride
    if(stepCount == 0) then
        stepCount = 1
    end
    moveFunc = PauseMove
end

function DoMove(x,y,z,a,f)
    if(f > rapidFeed) then
       f = rapidFeed
    end
    currentFeed = f
    stepSize = (f * feedOverride)/(60 * frameRate)
    xInc = x - currentX
    yInc = y - currentY
    zInc = z - currentZ
    aInc = a - currentA
    local diffBlend = math.sqrt((xInc * xInc) + (yInc * yInc) + (zInc * zInc) + (aInc * aInc))
    stepCount = diffBlend / stepSize
    if(stepCount == 0) then
        return
    end
    xInc = xInc / stepCount
    yInc = yInc / stepCount
    zInc = zInc / stepCount
    aInc = aInc / stepCount
    moveFunc = LinMove
    moveFunc()
end

function DoArc(x,y,z,a)
    currentFeed = moveFeed
    stepSize = (moveFeed * feedOverride)/(60 * frameRate)
    arcCX = x
    arcCY = y
    local dx = currentX - x
    local dy = currentY - y
    arcRad = math.sqrt((dx * dx) + (dy * dy))
    arcAngle = math.atan2(dx,dy)
    local len = math.abs(arcRad * a)
    stepCount = len / stepSize
    if(stepCount == 0) then
        return
    end
    arcInc = a / stepCount
    zInc = (z - currentZ) / stepCount
    moveFunc = ArcMove
    moveFunc()
end

function CreateLED(caption)
    if caption == nil then
        caption = "Error"
    end
    if(ledControls >= maxControls) then
        wx.wxLogMessage("Too many LEDs")
    else
        ledControls = ledControls + 1
        ledArray[ledControls]:SetLabel(caption)
        ledArray[ledControls]:Show(true)
    end
end

function LedDummy(evt)
 --block all mouse events so user can't manually check the box
end


function CreateTextBox(caption)
    if caption == nil then
        caption = "Error"
    end
    if(textControls >= maxControls) then
        wx.wxLogMessage("Too many Text controls")
    else
        textControls = textControls + 1
        local box = textArray[textControls]:GetContainingSizer():DynamicCast("wxStaticBoxSizer"):GetStaticBox()
        box:SetLabel(caption)
        box:Show(true)
        textArray[textControls]:Show(true)
        if(caption == _("Code snippet")) then
         snipText = textArray[textControls]
        end
    end

end

function CreateNumberBox(caption,units)
    if caption == nil or units == nil then
        caption = "Error"
    end
    if(numberControls >= maxControls) then
        wx.wxLogMessage("Too many number controls")
    else
        numberControls = numberControls + 1
        local box = numberArray[numberControls]:GetContainingSizer():DynamicCast("wxStaticBoxSizer"):GetStaticBox()
        box:SetLabel(caption)
        box:Show(true)
        local txt = numberArray[numberControls]
        txt:SetUnits(units)
        txt:SetValue(0)
        txt:Show(true)
    end
end

function SetLED(index,value)
    if(index == nil) then
        ShowError("Missing index")
        return
    end
    local led = ledArray[index]
    if(led == nil) then
        ShowError("LED " .. index .. " Does not exist")
    else
        led:SetValue(value);
    end
end

function SetTextBox(index,value)
    if(index == nil) then
        ShowError("Missing index")
        return
    end
    local box = textArray[index]
    if(box == nil or index > textControls) then
        ShowError("Text box " .. index .. " Does not exist")
    else
        box:SetValue(value);
    end
end

function SetNumberBox(index,value)
    if(index == nil) then
        ShowError("Missing index")
        return
    end
    local box = numberArray[index]
    if(box == nil or index > numberControls) then
        ShowError("Number box " .. index .. " Does not exist")
    else
        box:SetValue(value);
    end
end


function DrawControls()
    if(prevPanel) then
        prevPanel:Destroy()
        prevPanel = nil
    end
    panel:GetSizer():Layout()
    panel:GetSizer():FitInside(panel)
    panel:Refresh()

   siz = panel:GetBestSize()
   info = auiMgr:GetPane(panel)
   info:MinSize(siz:GetWidth(), -1)
   auiMgr:Update()
   info:MinSize(-1, -1)
   auiMgr:Update()
end

function ClearControls()
    for ct=1,maxControls do
        ledArray[ct]:Show(false)

        textArray[ct]:GetContainingSizer():DynamicCast("wxStaticBoxSizer"):GetStaticBox():Show(false)
        textArray[ct]:Show(false)

        numberArray[ct]:GetContainingSizer():DynamicCast("wxStaticBoxSizer"):GetStaticBox():Show(false)
        numberArray[ct]:Show(false)
    end
    ledControls = 0
    numberControls = 0
    textControls = 0
end


function ShowError(msg)
    wx.wxLogMessage (msg .. " on line " .. lineNumber)
end

function GetText()
    if currentString:sub(1,1) ~= "\"" then
        ShowError("Expected a string")
        return(nil)
    end
    term = string.find(currentString,"\"",2,true)
    if(term == nil) then
        ShowError("Expected a string")
        return(nil)
    end
    local ret = currentString:sub(2,term-1)
    if(currentString[term+1] == " ") then
        term = term +1
    end
    currentString = currentString:sub(term + 1)
    return ret
end

function GetNumber()
    term = string.find(currentString," ",2,true)
    if(term == nil) then
        term = currentString:len()
    end
    if(term == 0) then
        ShowError("Expected a number")
        return(0)
    end
    local ret = currentString:sub(1,term)
    ret = tonumber(ret)
    if(ret == nil) then
        ShowError("Expected a number")
        ret =0
    end
    currentString = currentString:sub(term + 1)
    return ret
end

function StartTimer()
    timer:Start((1/frameRate) * 1000)
end


-- ---------------------------------------------------------------------------
-- Handle the start event
function OnStart(event)
   if(moveFunc) then
      StartTimer()
      btnStart:Enable(false)
      return
   end
    sc.NotifyDll(dllTOOLSTATE, false)
    currentX =0
    currentY = 0
    time = 0
    UpdateDisplay()
    encoding = cfg:Read("/Post/encoding")
    cfg:Write("/Post/encoding", wx.wxFONTENCODING_UTF8)
    local fileName = wx.wxFileName(wx.wxStandardPaths.Get():GetUserDataDir() .. "/temp.sim"):GetShortPath()
    sc.RunPost(fileName,sc.GetMyPath().. "sims/"..machineType..".lua")
    cfg:Write("/Post/encoding", encoding)
    dataFile = assert(io.open(fileName,"r"))
    EnableButtons(true)
    ClearControls()
    sc.NotifyDll(dllROBOT,0)
    lineNumber = 1
    moveFunc = Parse
    StartTimer()
    sc.QueryDll(qryRAPIDY, 0)
    currentZ = sc.QueryDll(qryGETZ, 0) + sc.Parts:Get().work.clearance
    currentA = sc.QueryDll(qryGETA, 0)
end

-- ---------------------------------------------------------------------------
-- Handle the pause event
function OnPause(event)
    if(timer:IsRunning()) then
        timer:Stop()
        btnPause:SetLabel(_("Resume"))
    else
        StartTimer()
        btnPause:SetLabel(_("Pause"))
    end
end

-- ---------------------------------------------------------------------------
-- Handle the stop event
function OnStop(event)
    timer:Stop();
    EnableButtons(false);
    btnPause:SetLabel(_("Pause"))
    moveFunc = nil
end

-- ---------------------------------------------------------------------------
-- Handle the slider event
function OnSpeedScroll(event)
    UpdateFRO(event:GetPosition())
end

function UpdateFRO(value)
    local prevOverride = feedOverride
    feedOverride = (value) /100
    if(moveFunc == LinMove) then
        local targX = currentX + (xInc * stepCount)
        local targY = currentY + (yInc * stepCount)
        local targZ = currentZ + (zInc * stepCount)
        local targA = currentA + (aInc * stepCount)
        DoMove(targX,targY,targZ,targA,currentFeed)
    elseif (moveFunc == ArcMove) then
        local ang = (arcInc * stepCount)
        local targZ = currentZ + (zInc * stepCount)
        DoArc(arcCX,arcCY,targZ,ang)
    elseif (moveFunc == PauseMove) then
        stepCount = stepCount * (prevOverride/feedOverride)
    end
    froText:SetLabel(_("FRO") .. " ".. sc.ToInt(feedOverride * 1000)/10 .."%")
end

-- ---------------------------------------------------------------------------
-- Handle the notify event
function OnNotify(index,value)
   if(index == luaSHOW) then
        info = auiMgr:GetPane(panel)
        info:Show(true):CloseButton(false)
        auiMgr:Update()

    elseif(index == luaHIDE) then
        info = auiMgr:GetPane(panel)
        info:Show(false)
        auiMgr:Update()
        OnStop()
        if(tempFile:IsOpened()) then
            tempFile:Close();
        end
    elseif(index == luaERROR) then
        post.Error(_("Cut paths cross parts of the work that cannot be cut"))
    end
end

-- ---------------------------------------------------------------------------
-- Hide/show buttons
function OnQuit()
    OnStop()
    timer:delete()
    if(not cfg) then return end
    cfg:SetPath("/plugins/RotaryPlasma")
    cfg:Write("Speed",sldSpeed:GetValue())
    cfg:Write("Machine",machineType)
    cfg:Write("RapidFeed",rapidFeed)
    cfg:Write("FrameRate",frameRate)
    cfg:Write("ToolDia",toolScale)
    cfg:Write("MinDia",minDia)
end


-- ---------------------------------------------------------------------------
-- Hide/show buttons
function EnableButtons(state)
    btnStart:Enable(not state)
    btnPause:Enable(state)
    btnStop:Enable(state)
end



-- ---------------------------------------------------------------------------
-- The main program as a function (makes it easy to exit on error)
function main()
    cfg = wx.wxConfigBase.Get(false)
    cfg:SetPath("/plugins/RotaryPlasma")

    -- xml style resources (if present)
    xmlResource = wx.wxXmlResource()
    xmlResource:InitAllHandlers()
    local xrcFilename = sc.GetMyPath().."sim.xrc"
    xmlResource:Load(xrcFilename)

    auiMgr = sc.scApp():GetAuiManager()
    mainWindow = auiMgr:GetManagedWindow();

    panel = xmlResource:LoadPanel(mainWindow, "sim")
    if not panel then
        wx.wxMessageBox("Error loading xrc resources!",
                        "Options",
                        wx.wxOK + wx.wxICON_EXCLAMATION,
                        wx.NULL)
        return -- quit program
    end


    local id = xmlResource.GetXRCID("ID_BTNSTART");
    btnStart = panel:FindWindow(id):DynamicCast("wxButton")
    panel:Connect(id,wx.wxEVT_COMMAND_BUTTON_CLICKED, OnStart)

    id = xmlResource.GetXRCID("ID_BTNSTEP");
    btnStep = panel:FindWindow(id):DynamicCast("wxToggleButton")

    id = xmlResource.GetXRCID("ID_BTNPAUSE");
    btnPause = panel:FindWindow(id):DynamicCast("wxButton")
    panel:Connect(id,wx.wxEVT_COMMAND_BUTTON_CLICKED, OnPause)

    id = xmlResource.GetXRCID("ID_BTNSTOP");
    btnStop = panel:FindWindow(id):DynamicCast("wxButton")
    panel:Connect(id,wx.wxEVT_COMMAND_BUTTON_CLICKED, OnStop)

    id = xmlResource.GetXRCID("ID_SLDSPEED");
    sldSpeed = panel:FindWindow(id):DynamicCast("wxSlider")
    panel:Connect(id,wx.wxEVT_SCROLL_THUMBTRACK, OnSpeedScroll)


    id = xmlResource.GetXRCID("ID_BTNSETUP");
    panel:Connect(id,wx.wxEVT_COMMAND_BUTTON_CLICKED, OnSetupButton)

    posX = panel:FindWindow(xmlResource.GetXRCID("ID_POSX")):DynamicCast("UnitCtrl")
    posY = panel:FindWindow(xmlResource.GetXRCID("ID_POSY")):DynamicCast("UnitCtrl")
    posZ = panel:FindWindow(xmlResource.GetXRCID("ID_POSZ")):DynamicCast("UnitCtrl")
    posA = panel:FindWindow(xmlResource.GetXRCID("ID_POSA")):DynamicCast("UnitCtrl")
    froText = panel:FindWindow(xmlResource.GetXRCID("ID_FROTEXT")):DynamicCast("wxStaticText")

    timeBox = panel:FindWindow(xmlResource.GetXRCID("ID_TIME")):DynamicCast("UnitCtrl")
    timeBox:SetUnits(sc.unitTIME)


    -- a bit of fudgery to get the status wxStaticBoxSizer
    statusPanel = panel:FindWindow(xmlResource.GetXRCID("ID_STATUSPANEL")):DynamicCast("wxPanel")
    statusSizer = statusPanel:GetContainingSizer();
    statusPanel:Destroy()

    a,b = cfg:Read("Speed",19)
    sldSpeed:SetValue(b)
    UpdateFRO(b)

    a,machineType = cfg:Read("Machine","Jet")

    a,b = cfg:Read("MaxFRO",500)
    sldSpeed:SetRange(1,b)


    a,rapidFeed = cfg:Read("RapidFeed",2000)
    a,frameRate = cfg:Read("FrameRate",30)
    a,toolScale = cfg:Read("ToolDia",1)
    a,minDia = cfg:Read("MinDia",0)
   sc.NotifyDll(dllTOOLSCALE, toolScale)

    info = wxaui.wxAuiPaneInfo():Hide():CloseButton(false):Dock():Caption(_("Simulation")):Name("RotaryPlasma"):Right()
    auiMgr:AddPane(panel,info)
    auiMgr:Update()

    timer = wx.wxTimer(panel,wx.wxID_ANY)
    panel:Connect(wx.wxID_ANY,wx.wxEVT_TIMER,OnTimer)


    for ct=1,maxControls do
        local check = wx.wxCheckBox(panel,wx.wxID_ANY,"")
        check:Connect(wx.wxID_ANY,wx.wxEVT_LEFT_DOWN, LedDummy)
        statusSizer:Add(check,0,wx.wxTOP + wx.wxBOTTOM,2)
        check:Show(false)
        table.insert(ledArray,check)
    end

    for ct=1,maxControls do
        local siz = wx.wxStaticBoxSizer(wx.wxVERTICAL,panel,"")
        local txt = wx.wxTextCtrl(panel,wx.wxID_ANY, "", wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxTE_READONLY)
        siz:Add(txt,1,wx.wxTOP + wx.wxBOTTOM + wx.wxEXPAND,2)
        statusSizer:Add(siz, 1, wx.wxEXPAND)
        siz:GetStaticBox():Show(false)
        txt:Show(false)
        table.insert(textArray,txt)
    end

    for ct=1,maxControls do
        local siz = wx.wxStaticBoxSizer(wx.wxVERTICAL,panel,"")
        local txt = sc.UnitCtrl(panel,wx.wxID_ANY,"",wx.wxDefaultPosition,wx.wxDefaultSize,wx.wxTE_READONLY)
        siz:Add(txt,0,wx.wxTOP + wx.wxBOTTOM ,2)
        statusSizer:Add(siz, 1, wx.wxEXPAND)
        siz:GetStaticBox():Show(false)
        txt:Show(false)
        table.insert(numberArray,txt)
    end
end


main()

