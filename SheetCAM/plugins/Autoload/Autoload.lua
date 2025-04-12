--    _("Autoload") --A bit of fudgery here to force the plugin name to appear in the translation

lastTime = 0
lastFile = ""
delayTimeout = 0
checkAtStart = false
enableDir = false
subDirs = false
dirName = ""
pathSep = string.format("%c",wx.wxFileName.GetPathSeparator())




-- ---------------------------------------------------------------------------
-- built-in event that fires on exit
function OnQuit()
   timer:delete()
   if(not cfg) then return end
   cfg:SetPath("/plugins/autoload")
   cfg:Write("lastTime",lastTime)
   cfg:Write("scanType",enableScan)
   cfg:Write("delayLoad",delayLoad)
   cfg:Write("prevFile",prevFile)
   cfg:Write("checkAtStart",checkAtStart)
   cfg:Write("enableDir",enableDir)
   cfg:Write("subDirs",subDirs)
   cfg:Write("dirName",dirName)
   cfg:Write("lastFile", lastFile)
end

function OnReset(event)
    lastTime = 0
    timeCtrl:SetLabel(wx.wxDateTime(lastTime):Format("%x %X"))
end

function OnFolder(event)
    local dlg = wx.wxDirDialog(panel)
    dlg:SetPath(pathCtrl:GetValue())
    dlg:ShowModal()
    pathCtrl:SetValue(dlg:GetPath())
end

-- ---------------------------------------------------------------------------
-- Show panel when options menu is selected
function OnShowOptions(event)
    -- xml style resources (if present)
    xmlResource = wx.wxXmlResource()
    xmlResource:InitAllHandlers()
    local xrcFilename = sc.GetMyPath().."OptionPanel.xrc"

    xmlResource:Load(xrcFilename)

    panel = wx.wxPanel()
    if not xmlResource:LoadPanel(panel, event:GetPanel(), "OptionPanel") then
        wx.wxMessageBox("Error loading xrc resources!",
                        "Autoload Options",
                        wx.wxOK + wx.wxICON_EXCLAMATION,
                        wx.NULL)
        return
    end

    local id = xmlResource.GetXRCID("ID_ENABLESCAN")
    enabledCtrl = panel:FindWindow(id):DynamicCast("wxCheckBox")
    checkStartCtrl = panel:FindWindow(xmlResource.GetXRCID("ID_CHECKSTART")):DynamicCast("wxCheckBox")

    delayLoadCtrl = panel:FindWindow(xmlResource.GetXRCID("ID_TCDELAY")):DynamicCast("UnitCtrl")
    delayLoadCtrl:SetMin(1)
    delayLoadCtrl:SetMax(1000)
    delayLoadCtrl:SetUnits(sc.unitTIME)

    id = xmlResource.GetXRCID("ID_BTRESET")
    resetButton = panel:FindWindow(id):DynamicCast("wxButton")
    panel:Connect(id,wx.wxEVT_COMMAND_BUTTON_CLICKED, OnReset)

    timeCtrl = panel:FindWindow(xmlResource.GetXRCID("ID_STTIME")):DynamicCast("wxStaticText")  
    timeCtrl:SetLabel(wx.wxDateTime(lastTime):Format("%x %X"))

    id = xmlResource.GetXRCID("ID_CHECKDIR")
    enableDirCtrl = panel:FindWindow(id):DynamicCast("wxCheckBox")

    id = xmlResource.GetXRCID("ID_CHECKSUB")
    subDirCtrl = panel:FindWindow(id):DynamicCast("wxCheckBox")

    id = xmlResource.GetXRCID("ID_TCDIR")
    dirNameCtrl = panel:FindWindow(id):DynamicCast("wxTextCtrl")

    id = xmlResource.GetXRCID("ID_DIRBUTTON")
    resetButton = panel:FindWindow(id):DynamicCast("wxButton")
    panel:Connect(id, wx.wxEVT_COMMAND_BUTTON_CLICKED, OnDirButton)


    enableDirCtrl:SetValue(enableDir)
    subDirCtrl:SetValue(subDirs)
    dirNameCtrl:SetValue(dirName)
    enabledCtrl:SetValue(enableScan)
    delayLoadCtrl:SetValue(delayLoad)
    checkStartCtrl:SetValue(checkAtStart)
    event:AddWindow(panel)
end


-- ---------------------------------------------------------------------------
-- Show panel when options menu is selected
-- NOTE: After this event is called, the panel and all contained controls are
-- automatically deleted so they can't be used elsewhere

function OnHideOptions()
   enableScan = enabledCtrl:GetValue()
   delayLoad = delayLoadCtrl:GetValue()
   checkAtStart = checkStartCtrl:GetValue()
   dirName = dirNameCtrl:GetValue(dirName)
   enableDir = enableDirCtrl:GetValue()
   subDirs = subDirCtrl:GetValue()
   CheckType()
end


-- ---------------------------------------------------------------------------
-- Only start timer if we need to
function CheckType()
   if(enableScan == true) then
      timer:Start(1000)
   else
      timer:Stop()
   end
end

-- ---------------------------------------------------------------------------
-- Check for files
function OnTimer(event)
   if(waitingForDialog) then return end
   if(delayTimeout > 0) then
      delayTimeout = delayTimeout -1
      if(delayTimeout ==0) then
        wx.wxGetApp():GetTopWindow():Raise()
        waitingForDialog = true;
        res = wx.wxMessageBox(_("Do you want to load this file:\n")..foundFile,_("Auto load"), wx.wxICON_QUESTION + wx.wxYES_NO)
        if(res == wx.wxYES) then
            app:LoadDrawing(foundFile,foundType)
        end
        foundFile = nil
        waitingForDialog = nil
        return
      end
   end
   CheckCurrent()
end

function OnDirButton(event)
   dlg = wx.wxDirDialog(wx.wxGetApp():GetTopWindow(), _("Choose a directory"), dirName, wx.wxDD_DEFAULT_STYLE + wx.wxDD_DIR_MUST_EXIST)
   if(dlg:ShowModal() ~= wx.wxID_OK) then return end
   dirName = dlg:GetPath()
   dirNameCtrl:SetValue(dirName)
end


function CheckDir(path, search , mode)
   local dir = wx.wxDir(path)
   if not dir:IsOpened() then return end
   local fname
   local cont
   cont,fname = dir:GetFirst( search, mode)
   while(cont) do
      fname = path .. fname
      if(mode == wx.wxDIR_DIRS) then
         fname = fname .. pathSep
      end
      local nam = wx.wxFileName(fname)
      local filTime = nam:GetModificationTime():GetTicks()
      if(filTime > lastTime) then
         return fname, filTime
      end
      cont,fname = dir:GetNext()
   end
end

function CheckCurrent()
-- Note we must not use wxConfig::SetPath() here because the timer event could happen
-- at any time. If another part of SheetCam is reading/writing the config at the same time
-- Bad Things(tm) could happen!
   local a
   local file
   a,file = cfg:Read("/MRU/Drawing/file1","") 
   if(file == "") then return end
   local time = 0
   local nam = wx.wxFileName(file)
   if(enableDir) then
      local fname
      local filTime
      file, time = CheckDir(dirName .. pathSep, "/*." .. nam:GetExt(), wx.wxDIR_FILES)
      if(file == nil) then
         if(subDirs) then
            file, time = CheckDir(dirName .. pathSep, "/*.*", wx.wxDIR_DIRS)
            if(file) then
               file, time = CheckDir(file, "/*." .. nam:GetExt(), wx.wxDIR_FILES)
            end
            if(file == nil) then return end
         else
            return
         end
      end
   else   
      if(not nam:FileExists()) then return end
      time = nam:GetModificationTime():GetTicks()
      if(prevFile ~= file) then
         lastTime = time
         prevFile = file
         return
      end
   end

   if(time > lastTime) then
      lastTime = time
      foundFile = file
      a,foundType = cfg:Read("/MRU/Drawing/type1","")
      delayTimeout = delayLoad
      if(delayTimeout < 1) then
         delayTimeout = 1
      end
   end
end


-- ---------------------------------------------------------------------------
-- The main program as a function (makes it easy to exit on error)
function main()
   cfg = wx.wxConfigBase.Get(false)
   cfg:SetPath("/plugins/autoload")
   
   a,enableDir = cfg:Read("enableDir",0)
   enableDir = (enableDir == 1)

   a,subDirs = cfg:Read("subDirs",0)
   subDirs = (subDirs == 1)

   a,dirName = cfg:Read("dirName","")

   a,enableScan = cfg:Read("scanType",0)
   a,delayLoad = cfg:Read("delayLoad",1)
   a,checkAtStart = cfg:Read("checkAtStart",0)
   lastTime = 0
   if(checkAtStart == 1) then
      a,lastTime = cfg:Read("lastTime",0);
      lastTime = sc.ToInt(lastTime)
   else
      lastTime = wx.wxGetLocalTime()
   end
   a,prevFile = cfg:Read("prevFile","")
   a,file = cfg:Read("/MRU/Drawing/file1","")
--   if(file ~= prevFile) then 
--      lastTime = 0
--   end
   
   if(lastTime == 0) then
      if(file ~= "") then
         prevFile = file
         nam = wx.wxFileName(file)
         if(nam:FileExists()) then
            lastTime = nam:GetModificationTime():GetTicks()
         end
      end
   end

    app = sc.scApp();
   if(enableScan == 1) then  -- a fudge because boolean true is saved in config as integer 1
      enableScan = true
   end

    handler = wx.wxEvtHandler()
    timer = wx.wxTimer(handler)
    handler:Connect(wx.wxID_ANY,wx.wxEVT_TIMER,OnTimer)
    CheckType()
end

main()

