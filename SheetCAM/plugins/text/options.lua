--globals
updateCount = 0 --flag that data has changed
alignment   = 0  --default to left alignment

--notification enums
notifySHOW      = 0
notifyHIDE      = 1
notifyDRAW      = 2
notifyADD       = 3
notifyNEW       = 4
notifyDEL       = 5
notifySELECT    = 6
notifyX         = 7
notifyY         = 8
notifyMODE      = 9


modeBLANK   = 0
modeNEW     = 1
modeEDIT    = 2

curMode = modeBLANK

ID_ALIGNLEFT =  10000
ID_ALIGNMID =   10001
ID_ALIGNRIGHT = 10002

circularCall = false

-- ---------------------------------------------------------------------------
-- built-in event that fires on exit
function OnQuit()
   timer:delete()
end

-- ---------------------------------------------------------------------------
-- Handle the options event
-- note: this is a special event as you don't connect() it!
-- If a function with this name exists it is automatically called

function OnShowOptions(event)
    event:GetTextCtrl():AppendText(_("Text Creation plugin\n\nInserts text into your drawing.\nUses Autocad SHX fonts"))
end

-- ---------------------------------------------------------------------------
-- when the text needs to be updated
function OnTextChange(event)
   if circularCall then return end
   updateCount = 2 --flag a delayed update
end

function OnXChange(event)
   if circularCall then return end
   sc.NotifyDll(notifyX, txtPosX:GetValue())
end

function OnYChange(event)
   if circularCall then return end
   sc.NotifyDll(notifyY, txtPosY:GetValue())
end


-- ---------------------------------------------------------------------------
-- Add text to the current part
function OnAdd(event)
--    updateCount = 1
--    OnTimer(event) --force an update
    sc.NotifyDll(notifyADD)
end

function OnNew(event)
    sc.NotifyDll(notifyNEW)
end

function OnDelete(event)
    sc.NotifyDll(notifyDEL)
end


-- ---------------------------------------------------------------------------
-- File open dialog
function OnFile(event)
   dlg = wx.wxFileDialog(panel)
   dlg:SetWildcard("SHX fonts (*.shx)|*.shx")
   if(dlg:ShowModal() ~= wx.wxID_OK) then return end
   local dest = sc.Globals.Get().settingsDir .. "/shx/"
   wx.wxFileName.Mkdir(dest, 4095, wx.wxPATH_MKDIR_FULL)   
   dest = dest .. dlg:GetFilename()
   if(wx.wxFileName(dest):FileExists()) then
      if(wx.wxMessageBox(_("This file exists.\nDo you want to overwrite it?"),"",wx.wxYES_NO + wx.wxICON_QUESTION) == wx.wxNO) then
         return
      end
   end
   local src = dlg:GetPath()
   if not wx.wxCopyFile(src,dest,true) then
      wx.wxMessageBox("Copy failed","",wxICON_EXCLAMATION)
   end  
   FillFont(dlg:GetFilename())
   updateCount = 1
end


-- ---------------------------------------------------------------------------
-- when a tool has been selected
function OnToolChange(event)
    id = event:GetId() - ID_ALIGNLEFT
    if id >=0 and id <3 then
        alignment = id
        cfg:SetPath("/Plugins/Text")
        cfg:Write("Alignment",id)
        sc.NotifyDll(notifyDRAW,0)
    end
end


-- ---------------------------------------------------------------------------
-- Handle the timer event
function OnTimer(event)
    if updateCount ==0 then return end
    updateCount = updateCount -1
    if(updateCount == 0) then
        --Pass the values through the config
        --this is no hardship as we want to remember them anyway
        cfg:SetPath("/Plugins/Text")
        cfg:Write("Layer",txtLayer:GetValue())
        cfg:Write("Font",cbFont:GetStringSelection())
        cfg:Write("Height",txtHeight:GetValue())
        cfg:Write("Compress",txtCompress:GetValue())
        cfg:Write("HSpace",txtHoriz:GetValue())
        cfg:Write("VSpace",txtVert:GetValue())
        cfg:Write("Slope",txtSlope:GetValue())
        cfg:Write("Rotation",txtRotation:GetValue())
        cfg:Write("Text",txtText:GetValue())
        sc.NotifyDll(notifyDRAW,0)
    end
end

-- ---------------------------------------------------------------------------
-- Handle the notify event
function OnNotify(index,value)
   if(index == notifyX) then
      circularCall = true
      txtPosX:SetValue(value)
      circularCall = false
   elseif(index == notifyY) then
      circularCall = true
      txtPosY:SetValue(value)
      circularCall = false
   elseif(index == notifySELECT) then
      DoSelect()
   elseif(index == notifyMODE) then
      curMode = value
      ShowButtons()
   elseif(index == notifySHOW) then
      info = auiMgr:GetPane(panel)
      info:Show(true):CloseButton(false)
      auiMgr:Update()
      timer:Start(100)
   elseif(index == notifyHIDE) then
      info = auiMgr:GetPane(panel)
      info:Show(false)
      auiMgr:Update()
      timer:Stop()        
   end
end

function DoSelect()
   circularCall = true
   local a
   local b
   cfg = wx.wxConfigBase.Get()
   cfg:SetPath("/Plugins/Text")
   a,b = cfg:Read("Layer","Text")
   txtLayer:SetValue(b);
   a,b = cfg:Read("Font","default.shx")
   FillFont(b)
   a,b = cfg:Read("Height",5)
   txtHeight:SetValue(b);
   a,b = cfg:Read("Compress",1)
   txtCompress:SetValue(b);
   a,b = cfg:Read("HSpace",0)
   txtHoriz:SetValue(b);
   a,b = cfg:Read("VSpace",1)
   txtVert:SetValue(b);
   a,b = cfg:Read("Slope",0)
   txtSlope:SetValue(b);
   a,b = cfg:Read("Rotation",0)
   txtRotation:SetValue(b);
   a,b = cfg:Read("Text",_("Text"))
   txtText:SetValue(b);
   a,b = cfg:Read("Alignment",0)
   tbar:ToggleTool(b + ID_ALIGNLEFT,1)
   circularCall = false
end

function FillFont2(path, names)
   dir = wx.wxDir(path);
   if(not dir:IsOpened()) then return end
   a,fileName = dir:GetFirst("*.shx", wx.wxDIR_FILES)
   while fileName ~= "" do
      local idx = names:Index(fileName)
      if(idx == wx.wxNOT_FOUND) then
         cbFont:Append(fileName)
         names:Add(fileName)
      end
      a,fileName = dir:GetNext()
   end
end

function FillFont(fontName)
   local names = wx.wxArrayString()
   cbFont:Clear()
   FillFont2(sc.GetMyPath() .. "shx/", names)
   FillFont2(sc.Globals.Get().settingsDir .. "/shx/", names)
   cbFont:SetStringSelection(fontName);
   if(cbFont:GetSelection() < 0) then
      cbFont:SetStringSelection("default.shx");
   end
   if(cbFont:GetSelection() < 0) then
      cbFont:SetSelection(0);
   end
end

function ShowButtons()
   if(curMode == modeBLANK) then
      btnNew:Enable(true)
      btnAdd:Enable(false)
      btnDel:Enable(false)
      pnlOptions:Enable(false)
   elseif(curMode == modeNEW) then
      btnNew:Enable(false)
      btnAdd:Enable(true)
      btnDel:Enable(true)
      pnlOptions:Enable(true)
   else
      btnNew:Enable(true)
      btnAdd:Enable(false)
      btnDel:Enable(true)
      pnlOptions:Enable(true)
   end   
end


-- ---------------------------------------------------------------------------
-- The main program as a function (makes it easy to exit on error)
function main()
   path = sc.GetMyPath()
   if string.find(wx.wxGetOsDescription(),"Linux") ~= wx.wxNOT_FOUND then 
      os.remove(path .. "libText.so")
   end


   cfg = wx.wxConfigBase.Get(false)
   cfg:SetPath("/Plugins/Text")

   -- xml style resources (if present)
   xmlResource = wx.wxXmlResource()
   xmlResource:InitAllHandlers()
   local xrcFilename = sc.GetMyPath().."OptionsPanel.xrc"

   xmlResource:Load(xrcFilename)

   auiMgr = sc.scApp():GetAuiManager()
   mainWindow = auiMgr:GetManagedWindow();

   panel = xmlResource:LoadPanel(mainWindow, "OptionsPanel")
   if not panel then
      wx.wxMessageBox("Error loading xrc resources!",
                     "Options",
                     wx.wxOK + wx.wxICON_EXCLAMATION,
                     wx.NULL)
      return -- quit program
   end


   txtLayer = panel:FindWindow(xmlResource.GetXRCID("ID_TXTLAYER")):DynamicCast("wxTextCtrl")
   cbFont = panel:FindWindow(xmlResource.GetXRCID("ID_CHFONT")):DynamicCast("wxChoice")
   txtHeight = panel:FindWindow(xmlResource.GetXRCID("ID_TXHEIGHT")):DynamicCast("UnitCtrl")
   txtCompress = panel:FindWindow(xmlResource.GetXRCID("ID_TXCOMPRESSION")):DynamicCast("UnitCtrl")
   txtHoriz = panel:FindWindow(xmlResource.GetXRCID("ID_TXHSPACING")):DynamicCast("UnitCtrl")
   txtVert = panel:FindWindow(xmlResource.GetXRCID("ID_TXVSPACING")):DynamicCast("UnitCtrl")
   txtSlope = panel:FindWindow(xmlResource.GetXRCID("ID_TXSLOPE")):DynamicCast("UnitCtrl")
   txtRotation = panel:FindWindow(xmlResource.GetXRCID("ID_TXROTATION")):DynamicCast("UnitCtrl")
   txtPosX = panel:FindWindow(xmlResource.GetXRCID("ID_TXTPOSX")):DynamicCast("UnitCtrl")
   txtPosY = panel:FindWindow(xmlResource.GetXRCID("ID_TXTPOSY")):DynamicCast("UnitCtrl")
   txtText = panel:FindWindow(xmlResource.GetXRCID("ID_TXTEXT")):DynamicCast("wxTextCtrl")
   btnNew = panel:FindWindow(xmlResource.GetXRCID("ID_BTNNEW")):DynamicCast("wxButton")
   btnDel = panel:FindWindow(xmlResource.GetXRCID("ID_BTNDELETE")):DynamicCast("wxButton")
   btnAdd = panel:FindWindow(xmlResource.GetXRCID("ID_BTNCREATE")):DynamicCast("wxButton")
   pnlOptions = panel:FindWindow(xmlResource.GetXRCID("ID_PNLOPTIONS")):DynamicCast("wxPanel")

   local id = xmlResource.GetXRCID("ID_BTFILE")
   btnFile = panel:FindWindow(id):DynamicCast("wxButton")
   panel:Connect(id,wx.wxEVT_COMMAND_BUTTON_CLICKED, OnFile)

   panel:Connect(txtPosX:GetId(),sc.wxEVT_UEDIT_CHANGE, OnXChange)
   panel:Connect(txtPosY:GetId(),sc.wxEVT_UEDIT_CHANGE, OnYChange)

   pnl = panel:FindWindow(xmlResource.GetXRCID("ID_PNLALIGN")):DynamicCast("wxPanel")
   tbar = wx.wxToolBar(pnl,wx.wxID_ANY,wx.wxPoint(0,0),wx.wxDefaultSize,wx.wxTB_NODIVIDER + wx.wxTB_HORIZONTAL + wx.wxNO_BORDER)
   bmp = wx.wxBitmap()
   bmp:LoadFile(path .. "alignLeft.ico",wx.wxBITMAP_TYPE_ICO)
   tbar:AddTool(ID_ALIGNLEFT,"",bmp,"",wx.wxITEM_RADIO)
   bmp:LoadFile(path .. "alignMid.ico",wx.wxBITMAP_TYPE_ICO)
   tbar:AddTool(ID_ALIGNMID,"",bmp,"",wx.wxITEM_RADIO)
   bmp:LoadFile(path .. "alignRight.ico",wx.wxBITMAP_TYPE_ICO)
   tbar:AddTool(ID_ALIGNRIGHT,"",bmp,"",wx.wxITEM_RADIO)
   tbar:Realize()
   pnl:GetSizer():Add(tbar)

   txtHeight:SetMin(0.01);
   txtCompress:SetMin(0.01);
   txtCompress:SetUnits(sc.unitPERCENT);
   txtHoriz:SetUnits(sc.unitLINEAR);
   txtHoriz:SetMin(-100);
   txtHoriz:SetMax(100);
   txtVert:SetUnits(sc.unitPERCENT);
   txtVert:SetMin(0.5);
   txtSlope:SetMin(0);
   txtSlope:SetUnits(sc.unitANGULAR);
   txtRotation:SetMin(-math.pi);
   txtRotation:SetMax(math.pi);
   txtRotation:SetUnits(sc.unitANGULAR);


   panel:Connect(xmlResource.GetXRCID("ID_BTNNEW"), wx.wxEVT_COMMAND_BUTTON_CLICKED, OnNew)
   panel:Connect(xmlResource.GetXRCID("ID_BTNCREATE"), wx.wxEVT_COMMAND_BUTTON_CLICKED, OnAdd)
   panel:Connect(xmlResource.GetXRCID("ID_BTNDELETE"), wx.wxEVT_COMMAND_BUTTON_CLICKED, OnDelete)

   panel:Connect(cbFont:GetId(), wx.wxEVT_COMMAND_CHOICE_SELECTED, OnTextChange)
   panel:Connect(txtHeight:GetId(), sc.wxEVT_UEDIT_KILLFOCUS, OnTextChange)
   panel:Connect(txtCompress:GetId(), sc.wxEVT_UEDIT_KILLFOCUS, OnTextChange)
   panel:Connect(txtHoriz:GetId(), sc.wxEVT_UEDIT_KILLFOCUS, OnTextChange)
   panel:Connect(txtVert:GetId(), sc.wxEVT_UEDIT_KILLFOCUS, OnTextChange)
   panel:Connect(txtSlope:GetId(), sc.wxEVT_UEDIT_KILLFOCUS, OnTextChange)
   panel:Connect(txtRotation:GetId(), sc.wxEVT_UEDIT_KILLFOCUS, OnTextChange)
   panel:Connect(txtText:GetId(), wx.wxEVT_COMMAND_TEXT_UPDATED, OnTextChange)
   panel:Connect(txtLayer:GetId(), wx.wxEVT_COMMAND_TEXT_UPDATED, OnTextChange)
   panel:Connect(wx.wxID_ANY, wx.wxEVT_COMMAND_TOOL_CLICKED, OnToolChange)

   info = wxaui.wxAuiPaneInfo():Hide():CloseButton(false):Dock():Caption(wx.wxGetTranslation("Text")):Name("Text"):Right()
   auiMgr:AddPane(panel,info)
   auiMgr:Update()
   --    _("Text") --A bit of fudgery here to force the plugin name to appear in the translation

   timer = wx.wxTimer(panel,wx.wxID_ANY)
   panel:Connect(wx.wxID_ANY,wx.wxEVT_TIMER,OnTimer)
   ShowButtons()
end

main()

