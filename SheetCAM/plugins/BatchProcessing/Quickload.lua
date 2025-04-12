--    _("Quickload") --A bit of fudgery here to force the plugin name to appear in the translation

-- ---------------------------------------------------------------------------
-- Handle the options event
-- note: this is a special event as you don't connect() it!
-- If a function with this name exists it is automatically called

sortType = 0
pathSep = string.format("%c",wx.wxFileName.GetPathSeparator())

function OnQuit()
   cfg = wx.wxConfigBase.Get(false)
   cfg:SetPath("/Plugins/BatchProcessing")
   cfg:Write("srcDir",srcDir:GetPath())
   cfg:Write("template",templateFile:GetPath())
   cfg:Write("sortType",sortType)
   cfg:Write("showOptions",showOptions:GetValue())
   cfg:Write("subDirs",subDirs:GetValue())
   cfg:Write("fileType",fileTypes:GetSelection())
   cfg:Write("useTemplate",useTemplate:GetValue())
   cfg:Write("disableOps",disableOps:GetValue())   
   cfg:Write("keepParts",keepParts:GetValue())   
   cfg:Write("Width", panel:GetSize():GetWidth())
end

function OnShowOptions(event)
    event:GetTextCtrl():AppendText(_("Quick load") .. ".\n" .. _("Quickly browse and load files."))
end

evtHdlr = wx.wxEvtHandler()

function OnStart(event)
   info = auiMgr:GetPane(panel)
   if(event:GetInt() ==1) then
      info:Show(true)
   else
      info:Show(false)
   end
   auiMgr:Update()
end

function OnEnterIdle(evt)
   panel:Disconnect(wx.wxEVT_IDLE) --we only need this to be called once
   local wildcards
   wildcards,filters,descriptions = sc.scApp():GetImportFilters()
   table.insert(descriptions,_("Job files"))
   table.insert(filters,"*.job")

   for ct=1, #descriptions do
      fileTypes:Append(descriptions[ct])
   end
   cfg:SetPath("/Plugins/BatchProcessing")
   a,b = cfg:Read("fileType",0)
   if(b < 0) then b = 0 end
   fileTypes:SetSelection(b)
   GetDir()
   FillList()
end

function IsJobFile()
   return (fileTypes:GetSelection() == fileTypes:GetCount() -1)
end

function OnDirChanged()
   drawingPanel:Enable(not IsJobFile())
   GetDir()
   FillList()
end


function GetDir()
   fileArray = {}
   GetSubDir(srcDir:GetPath() .. pathSep, "")
   SortFiles();
end
   
   
function GetSubDir(root, directory)
   local path = root .. directory
   local files
   local dir = wx.wxDir(path)

   if not dir:IsOpened() then
      return
   end
   local idx = 0
   local cont
   local fName

   local filter = filters[fileTypes:GetSelection() + 1]
   if not filter then
      return
   end
   
   local filtIdx = string.find(filter,";",1)
   while string.len(filter) > 0 do
      if filtIdx then
         cont,fName = dir:GetFirst( string.sub(filter, 1, filtIdx - 1), wx.wxDIR_FILES)
         filter = string.sub(filter, filtIdx + 1)
      else
         cont,fName = dir:GetFirst(filter, wx.wxDIR_FILES)
         filter = ""
      end
      while cont do
         local found = false
         local fName2 = directory .. fName
         for i,v in ipairs(fileArray) do
            if v[0] == fName2 then
               found = true
               break
            end
         end
         if not found then
            local tmp = {}
            tmp[0] = fName2
            local time = wx.wxFileName(path .. fName):GetModificationTime()
            tmp[1] = time:Format("%x  %H:%M")
            tmp[2] = time
            table.insert(fileArray,tmp)
         end
         cont,fName = dir:GetNext()
      end
      filtIdx = string.find(filter,";",1)
   end

   if(not subDirs:GetValue()) then return end
   cont,dirName = dir:GetFirst( "*.*", wx.wxDIR_DIRS)
   while cont do
      GetSubDir(root .. directory, dirName .. pathSep)
      cont,dirName = dir:GetNext()
   end

--   SortFiles()
end


function SortFiles()
   if sortType == 0 then
      table.sort(fileArray, function(a,b)
         return string.lower(a[0]) < string.lower(b[0])
      end)
   elseif sortType == 1 then
      table.sort(fileArray, function(a,b)
         return string.lower(a[0]) > string.lower(b[0])
      end)
   elseif sortType == 2 then
      table.sort(fileArray, function(a,b)
         return a[2]:GetTicks() < b[2]:GetTicks()
      end)
   else
      table.sort(fileArray, function(a,b)
         return a[2]:GetTicks() > b[2]:GetTicks()
      end)
   end
end

function FillList()
   local txt = searchBox:GetValue()
   local names=nil
   if txt == "" then
      names = fileArray
   else
      txt = string.lower(txt)
      names={}
      for i,v in ipairs(fileArray) do
         if string.find(string.lower(v[0]), txt) then
            table.insert(names, v)
         end
      end
   end
   fileList:Freeze()
   fileList:ClearAll()
   fileList:InsertColumn(0,_("File name"))
   fileList:InsertColumn(1,_("Date"))
   local idx = 0
   if fileArray ~= nil then
      for i,v in ipairs(names) do
         fileList:InsertItem(idx, v[0])
         fileList:SetItem(idx, 1, v[1])
         idx = idx + 1
      end
   end
   fileList:SetColumnWidth(0, wx.wxLIST_AUTOSIZE)
   fileList:SetColumnWidth(1, wx.wxLIST_AUTOSIZE)
   fileList:Thaw()
end

function OnColClick(evt)
   if evt:GetColumn() == 0 then
      if sortType == 0 then
         sortType = 1
      else
         sortType = 0
      end
   else
      if sortType == 2 then
         sortType = 3
      else
         sortType = 2
      end
   end
   SortFiles()
   FillList()
end

function OnLoadBtn(evt)
   local files={}
   for idx=0, fileList:GetItemCount() -1 do
      if fileList:GetItemState(idx,wx.wxLIST_STATE_SELECTED) ~= 0 then
         table.insert(files, fileList:GetItemText(idx))
      end
   end
   LoadFiles(files)
end

function OnDClick(evt)
   idx = fileList:HitTest(evt:GetPosition())
   if idx == wx.wxNOT_FOUND then return end
   local files={}
   table.insert(files, fileList:GetItemText(idx))
   LoadFiles(files)
end
   
   
function LoadFiles(files)
   local app = sc.scApp()
   local parts = sc.Parts:Get()
   local newParts = {}
   if IsJobFile() then
      app:LoadJob(srcDir:GetPath() .. "/" .. files[1])
   else
      if(useTemplate:GetValue()) then
         local template = templateFile:GetPath()
         if not wx.wxFileName.FileExists(template) then
            wx.wxMessageBox(_("You need to select a template"))
            return
         end
         if not app:LoadTemplate(template) then return end
      end
      local first = true
      local firstPart = parts:op_index(0)
      if keepParts:GetValue() and not useTemplate:GetValue() then
         first = parts:GetCount() == 1 and firstPart:IsEmpty()
         if first then
            table.insert(newParts, firstPart)
         end
      else
         if(#files > 1) then
            for pt=2, parts:GetCount() do
               parts:Delete(1)
            end
         end
         table.insert(newParts, firstPart)
      end
      for i,v in ipairs(files) do
         local path = srcDir:GetPath() .. "/" .. v
         if not first then
            local part = parts:AddNew()
            parts.selected:Set(part)
            for op=0, firstPart.operations:GetCount() -1 do
               local operation = firstPart.operations:op_index(op)
               part.operations:Add(operation,false)
            end
            table.insert(newParts, part)
         end
         first = false
         app:LoadDrawing(path, descriptions[fileTypes:GetSelection() + 1], true, not showOptions:GetValue())
      end
   end

   if(disableOps:GetValue()) then
      for pt=0, parts:GetCount() -1 do
         local part = parts:op_index(pt)
         for op=0, part.operations:GetCount() -1 do
            local operation = part.operations:op_index(op)
            if operation:IsKindOf(wx.wxClassInfo("OperationWithPaths")) then
               operation = operation:DynamicCast("OperationWithPaths")
               if(operation:GetLayer() <0) then --no layer
                  operation:SetEnabled(false)
               end
            end
         end
      end
   end
   if(parts:GetCount() > 1) then
      local x = parts.work.bl.x
      local y = parts.work.bl.y
      for i,v in ipairs(newParts) do
         local min = sc.Coord2D(1e17, 1e17)
         local max = sc.Coord2D(-1e17, -1e17)
         v:GetExtents(min, max, false)
         local wid = max.x - min.x
         local hei = max.y - min.y
         local pos = v:GetPosition()
         pos.x = x + wid/2
         pos.y = y - (hei/2)
         v:SetPosition(pos)
         x = x + wid + 1
      end
   end
   parts.selected:Clear()
   for i,part in ipairs(newParts) do
      parts.selected:Set(part)
   end
end

function OnTemplateClicked(evt)
   templateFile:Enable(evt:IsChecked())
   keepParts:Enable(not evt:IsChecked())
end

function OnConvertBtn(evt)
   cfg:SetPath("/Plugins/BatchProcessing")
   local a
   local path
   a,path = cfg:Read("batchDir","")
   path = wx.wxDirSelector( wx.wxDirSelectorPromptStr, path)
   if(not path or path == "") then return end
   cfg:Write("batchDir", path)
   local dir = wx.wxDir(path)
   if(not dir:IsOpened()) then return end
   local c = dir:GetFirst("*", wx.wxDIR_FILES)
   if(c) then
      wx.wxMessageBox("the destination directory must be empty")
      return
   end
   for idx=0, fileList:GetItemCount() -1 do
      if fileList:GetItemState(idx,wx.wxLIST_STATE_SELECTED) ~= 0 then
         sc.Parts:Get():Clear()
         local files={}
         local fName = fileList:GetItemText(idx)
         table.insert(files, fName)
         sc.Parts:Get():ClearDirty(sc.DIRTY_FILE)
         LoadFiles(files)
         fName = wx.wxFileName(fName):GetName()
         sc.scApp():SaveJob(path .. "/" .. fName.. ".job", false)
      end
   end
end

function OnSearch(evt)
   FillList()
end


function main()
   --add a menu to the main application
   local app = sc.scApp();

   app:SetMenuPath("/&Plugins")
   ID_START = app:AddMenu(evtHdlr,"Plugins","Quick load",_("Quickly browse and load files."),"",sc.ITEM_CHECK_PERSIST_DEFAULTOFF)
   app:UpdateBars() --regenerate toolbars
   evtHdlr:Connect(ID_START, sc.wxEVT_ACTION, OnStart)

    -- xml style resources (if present)
    xmlResource = wx.wxXmlResource()
    xmlResource:InitAllHandlers()
    local xrcFilename = sc.GetMyPath().."Panel.xrc"

    xmlResource:Load(xrcFilename)

    auiMgr = sc.scApp():GetAuiManager()
    mainWindow = auiMgr:GetManagedWindow();

   panel = xmlResource:LoadPanel(mainWindow, "Panel")
   if not panel then
        wx.wxMessageBox("Error loading xrc resources!",
                        "Options",
                        wx.wxOK + wx.wxICON_EXCLAMATION,
                        wx.NULL)
        return -- quit program
   end
   panel:SetId(ID_START); --Set the panel ID to the menu ID so the menu check box stays in sync when you close the panel


   srcDir = panel:FindWindow(xmlResource.GetXRCID("ID_SRCDIR")):DynamicCast("wxDirPickerCtrl")
   fileList = panel:FindWindow(xmlResource.GetXRCID("ID_FILELIST")):DynamicCast("wxListCtrl")


   templateFile = panel:FindWindow(xmlResource.GetXRCID("ID_TEMPLATE")):DynamicCast("wxFilePickerCtrl")
   fileTypes = panel:FindWindow(xmlResource.GetXRCID("ID_FILETYPE")):DynamicCast("wxChoice")
   subDirs = panel:FindWindow(xmlResource.GetXRCID("ID_SUBDIRS")):DynamicCast("wxCheckBox")
   showOptions = panel:FindWindow(xmlResource.GetXRCID("ID_SHOWOPTIONS")):DynamicCast("wxCheckBox")
   drawingPanel = panel:FindWindow(xmlResource.GetXRCID("ID_DRAWINGPANEL")):DynamicCast("wxPanel")
   refreshButton = panel:FindWindow(xmlResource.GetXRCID("ID_REFRESHBUTTON")):DynamicCast("wxBitmapButton")
   useTemplate = panel:FindWindow(xmlResource.GetXRCID("ID_USETEMPLATE")):DynamicCast("wxCheckBox")
   disableOps = panel:FindWindow(xmlResource.GetXRCID("ID_DISABLE_OPS")):DynamicCast("wxCheckBox")
   keepParts = panel:FindWindow(xmlResource.GetXRCID("ID_KEEP_EXISTING")):DynamicCast("wxCheckBox")
   loadButton = panel:FindWindow(xmlResource.GetXRCID("ID_LOADBTN")):DynamicCast("wxButton")
   convertButton = panel:FindWindow(xmlResource.GetXRCID("ID_BTNCONVERT")):DynamicCast("wxButton")
   searchBox = panel:FindWindow(xmlResource.GetXRCID("ID_SEARCHBOX")):DynamicCast("wxTextCtrl")
   searchButton = panel:FindWindow(xmlResource.GetXRCID("ID_SEARCHBUTTON")):DynamicCast("wxBitmapButton")

   cfg = wx.wxConfigBase.Get(false)
   cfg:SetPath("/Plugins/BatchProcessing")
   local wid = panel:ConvertDialogToPixels(wx.wxPoint(150,-1)).x
   a,wid = cfg:Read("Width", wid) 
   
   info = wxaui.wxAuiPaneInfo():Hide():CloseButton(true):Dock():Caption(wx.wxGetTranslation("Quick load")):Name("BatchProcessing"):Right():BestSize(wid,-1)
   auiMgr:AddPane(panel,info)
   auiMgr:Update()

   a,b = cfg:Read("srcDir","")
   srcDir:SetPath(b);
   a,b = cfg:Read("template","")
   templateFile:SetPath(b);
   a,sortType = cfg:Read("sortType", 0)
   a,b = cfg:Read("subDirs",0)
   subDirs:SetValue(b == 1)
   a,b = cfg:Read("showOptions",1)
   showOptions:SetValue(b == 1)
   a,b = cfg:Read("useTemplate",1)
   useTemplate:SetValue(b == 1)
   templateFile:Enable(useTemplate:GetValue())
   keepParts:Enable(not useTemplate:GetValue())


   
   a,b = cfg:Read("keepParts",1)
   keepParts:SetValue(b == 1)
   
   a,b = cfg:Read("disableOps",0)
   disableOps:SetValue(b == 1)
   
   

   cfg = wx.wxConfigBase.Get(false)
   panel:Connect(wx.wxID_ANY, wx.wxEVT_IDLE, OnEnterIdle)
   subDirs:Connect(wx.wxEVT_COMMAND_CHECKBOX_CLICKED, OnDirChanged)
   fileTypes:Connect(wx.wxEVT_COMMAND_CHOICE_SELECTED, OnDirChanged)
   srcDir:Connect(wx.wxEVT_COMMAND_DIRPICKER_CHANGED, OnDirChanged)
   fileList:Connect(wx.wxEVT_COMMAND_LIST_COL_CLICK, OnColClick)
   fileList:Connect(wx.wxEVT_LEFT_DCLICK, OnDClick)
   refreshButton:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED, OnDirChanged)
   useTemplate:Connect(wx.wxEVT_COMMAND_CHECKBOX_CLICKED, OnTemplateClicked)
   loadButton:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED, OnLoadBtn)
   convertButton:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED, OnConvertBtn)
   searchButton:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED, OnSearch)
   searchBox:Connect(wx.wxEVT_TEXT, OnSearch)
      
   convertButton:Show(false)

end

main()
