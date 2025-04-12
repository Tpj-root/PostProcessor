local pth = sc.GetMyPath() .. "include/"
dofile (pth .. "class.lua")
dofile (pth .. "shapemode.lua")
dofile (pth .. "ShapeDialog.lua")

values = {}
lists = {}

isActive = false
tempObj = sc.EditableObject("shape")
cur = sc.Coord2D(1e17,1e17)
curItem = ""
slash = string.char(wx.wxFileName.GetPathSeparator())

function TR(n)
   return n
end

function OnQuit()
   local cfg = wx.wxConfigBase.Get(false)
   cfg:SetPath("/plugins/Shape")
   cfg:Write("Width", panel:GetSize():GetWidth())
end

function OnCheck(evt)
   if not bmpBtn then return end
   bmpBtn:Show(evt:GetInt())
   panel:Layout()
   local cfg = wx.wxConfigBase.Get(false)
   cfg:SetPath("/plugins/Shape")
   cfg:Write("ShowButton", evt:GetInt())
end

-- ---------------------------------------------------------------------------
-- Handle the options event
-- note: this is a special event as you don't connect() it!
-- If a function with this name exists it is automatically called

function OnShowOptions(event)
   event:GetTextCtrl():AppendText(_("Shape cutting plugin\n"))
   local chk = wx.wxCheckBox(event:GetPanel(), wx.wxID_ANY, "Show bitmap button")
   local cfg = wx.wxConfigBase.Get(false)
   cfg:SetPath("/plugins/Shape")
   local a
   local val
   a,val = cfg:Read("ShowButton", 0);
   chk:SetValue(val ~= 0)
   chk:Connect(wx.wxEVT_CHECKBOX, OnCheck)
   event:AddWindow(chk)
end


function OnDrawDisplay()
   if not mode or not mode.isActive then return end
   tempObj:Draw()
end

function Circle(x ,y, d)
   local path = sc.Path()
   path.type = sc.PATH_ARC
   path.ctr:Set(x,y)
   path.start:Set(x + (d/2), y)
   path["end"] = path.start --We cannot use .end because end is a Lua keyword!
   path.angle = math.pi * 2
   path.startAngle = 0
   tempObj:AddPath(path);
   cur:Set(1e17, 1e17)
end

function Line(sx, sy, ex, ey)
   local path = sc.Path()
   path.type = sc.PATH_LINE
   path.start:Set(sx,sy)
   path["end"]:Set(ex,ey)
   tempObj:AddPath(path);
   cur:Set(ex,ey)
end

function Point(x, y)
   Circle(x, y, 0)
end

function MoveTo(ex, ey)
   cur:Set(ex,ey)
end

function LineTo(ex, ey)
   if(cur.x == 1e17) then
      wx.wxMessageBox("LineTo must be preceded by a line or arc")
      return
   end
   local path = sc.Path()
   path.type = sc.PATH_LINE
   path.start = cur
   path["end"]:Set(ex,ey)
   tempObj:AddPath(path);
   cur:Set(ex,ey)
end


function ArcA(sx, sy, cx, cy, angle)
   local path = sc.Path()
   path.type = sc.PATH_ARC
   path.start:Set(sx, sy)
   path.ctr:Set(cx, cy)
   path.angle = angle
   path.startAngle = math.atan2(sx - cx, sy - cy)
   local radius = path.start:DistanceTo(path.ctr)
   if(radius < 0.001) then return end
   local angle = path.startAngle + path.angle
   path["end"] = path.ctr:ArcPoint(angle, radius)
   tempObj:AddPath(path);
   cur = path["end"]
end




function GeneratePart()
   if not shape then return end
   for name, value in pairs(values) do
      shape[value.varName] = value.value:op_get()
   end
   local data = tempObj:GetGroupData()
   data:Write("name", curItem)
   SaveConfig(data)
   shape.lists = lists
   tempObj:SetLayer(_("Shape"))
   cur:Set(1e17, 1e17)
   tempObj:StartPaths()
   shape.Calculate()
   tempObj:EndPaths()
   tempObj:Update()
end

function OnCreateBitmap(evt)
   local grps = tempObj:GetGroups()
   local imgSize = 100
   local bmpSize = 128
   if(grps:GetCount() == 0) then return end
   local screen = sc.Parts:Get().glDisplay
   local bl = sc.Coord2D(1e17,1e17)
   local tr = sc.Coord2D(-1e17,-1e17)
   grps:GetExtents(bl,tr)
   local ctr = bl:op_add(tr)
   ctr.x = ctr.x / 2
   ctr.y = ctr.y / 2
   tr = tr:op_sub(bl) --tr now holds size
   if tr.y > tr.x then
      tr.x = tr.y
   else
      tr.y = tr.x
   end
   screen:ZoomPos(tr, tempObj:GetPosition2D())
   local scale = screen:GetPixelSize() * (imgSize - 1);
   screen:Zoom(scale / tr.x)
   local dlg = wx.wxFileDialog(wx.wxGetApp():GetTopWindow(), "Save image",  curPath, "main.png", "*.png", wx.wxFD_SAVE + wx.wxFD_OVERWRITE_PROMPT)
   if(dlg:ShowModal() ~= wx.wxID_OK) then return end
   local bmp = screen:GetBitmap()
   local cx = bmp:GetWidth() / 2
   local cy = bmp:GetHeight() / 2
   siz = wx.wxRect(cx - (bmpSize/2), cy - (bmpSize/2), bmpSize, bmpSize)
   bmp = bmp:GetSubBitmap(siz)
   bmp = wx.wxImage(bmp)
   bmp:Replace(0,0,0,100,100,100)
   bmp:Replace(255,255,255,0,0,0)
   bmp:SetMaskColour(100,100,100)
   bmp:SetMask(true)
   bmp:SaveFile(dlg:GetPath(), wx.wxBITMAP_TYPE_PNG);
end

function OnCreate(evt)
   if curItem == nil then return end
   local tok = wx.wxStringTokenizer(curItem, "\\/")
   local name
   while tok:HasMoreTokens() do
      name = tok:GetNextToken()
   end
   tempObj:CreatePart(name)
end

function OnAddTo(evt)
   tempObj:InsertIntoPart()
end

function EnableButtons(add, del)
   addBtn:Enable(add)
   addPartBtn:Enable(add)
   delBtn:Enable(del)
end

function OnDelete(evt)
   tempObj:DeleteFromPart();
   tempObj:Clear()
   Clear()
   tempObj:Draw()
   EnableButtons(false, false)
end


function LoadConfig(cfg)
   cfg:SetPath("values")
   for name, value in pairs(values) do
      local a
      local val
      a,val = cfg:Read(value.varName, value.value:op_get())
      value.value:op_set(val)
   end
   cfg:SetPath("../tables")
   for name, list in pairs(lists) do
      cfg:SetPath(name)
      for name,col in pairs(list.cols) do
         cfg:SetPath(name)
         col.values = {}
         list.rows = 0
         local ct = 1
         while true do
            local a
            local val
            a,val = cfg:Read("" .. ct)
            if not a then break end
            local v = CloneValue(col.default)
            v:op_set(tonumber(val))
            table.insert(col.values, v)
            ct = ct + 1
         end
         ct = ct - 1
         if(ct > list.rows) then
            list.rows = ct
         end
         cfg:SetPath("..")
      end
      cfg:SetPath("..")
   end
   cfg:SetPath("..")
end

function SaveConfig(cfg)
   cfg:SetPath("values")
   for name, value in pairs(values) do
      cfg:Write(value.varName, value.value:op_get())
   end
   cfg:SetPath("../tables")
   for name, list in pairs(lists) do
      cfg:SetPath(name)
      for name,col in pairs(list.cols) do
         cfg:SetPath(name)
         for name, row in pairs(col.values) do
            local a
            local val
            a,val = cfg:Write("" .. name, row:op_get())
         end
         cfg:SetPath("..")
      end
      cfg:SetPath("..")
   end
   cfg:SetPath("..")
end


function FillGrid(list)
   local grid = list.grid
   local cols = list.cols
   local rows = list.rows
   if(rows == 0 ) then return end
   local coln = 0
   if (rows >= grid:GetNumberRows()) then
      grid:AppendRows(rows - grid:GetNumberRows())
   end

   local idx = 0
   while true do
      local col
      for name,c in pairs(list.cols) do
         if c.index == idx then
            col = c
            break
         end
      end
      if col == nil then break end
      local row = 0
      for name, val in pairs(col.values) do
         local ed=sc.GridCellValueEditor(val)
         grid:SetCellEditor(row, idx, ed)
         grid:SetCellValue(row, idx, val:GetValueString())
         row = row + 1
      end
      idx = idx + 1
   end
end

function OnGridKey(evt)
   if evt:GetKeyCode() ~= wx.WXK_DELETE then
      evt:Skip()
      return
   end
   local found
   local obj = evt:GetEventObject()
   if obj:GetClassInfo():GetClassName() == "wxGridWindow" then
      obj = obj:DynamicCast("wxWindow"):GetParent():DynamicCast("wxGrid")
   end
   for name, list in pairs(lists) do
      if(obj == list.grid) then
         found = list
      end
   end
   if not found then return end
   local row = found.grid:GetGridCursorRow()
   found.grid:DeleteRows(row, 1, true)
   row = row + 1
   if row <=0 then return end
   for name,col in pairs(found.cols) do
      table.remove(col.values, row)
      local t = name
   end
   found.rows = found.rows - 1
   FillGrid(found)
   GeneratePart()
end

function CreateControls()
   scrollWindow:Freeze()
   local sizer = statusPanel:GetSizer()
   local gridSizer = wx.wxFlexGridSizer(0,2,4,4)
   sizer:Add(gridSizer, 0, wx.wxEXPAND)

   local first = true
   for name, value in pairs(values) do
      value.label = value.value:CreateLabel(gridSizer, statusPanel)
      local editor = value.value:CreateEditor(gridSizer, statusPanel)
      editor:Connect(sc.wxEVT_VALUE_DYNAMIC_CHANGE, OnValue)
      value.editor = editor
      if first then
        first = false
        editor:SetFocus()
      end
   end
   for name, list in pairs(lists) do
      local grid = wx.wxGrid(statusPanel, wx.wxID_ANY)
      grid:Connect(wx.wxEVT_GRID_CELL_CHANGE, OnValue)
      grid:Connect(wx.wxEVT_KEY_DOWN, OnGridKey)
      list.grid = grid
      grid:CreateGrid(0, 0)

      local idx = 0
      while true do
         local col
         for name,c in pairs(list.cols) do
            if c.index == idx then
               col = c
               break
            end
         end
         if col == nil then break end
         grid:AppendCols()
         grid:SetColLabelValue(idx, col.caption)
         idx = idx + 1
      end

      grid:SetColLabelSize(wx.wxGRID_AUTOSIZE)
      grid:SetMinSize(wx.wxSize(-1,100))
      grid:SetRowLabelSize(0)
      grid:SetName(name)
      sizer:Add(grid, 0, wx.wxEXPAND)
      local btn = wx.wxButton(statusPanel, wx.wxID_ANY, _(" line"))
      btn:SetName(name)
      sizer:Add(btn, 0, wx.wxEXPAND)
      btn:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED, OnLine)
   end

   sizer:Layout()
   scrollWindow:FitInside()
   scrollWindow:SetScrollRate(1,1)
   statusPanel:TransferDataToWindow()
   scrollWindow:Thaw()
end

function CloneValue(val)
   local ret
   if val:GetClassInfo():GetClassName() == "FloatValue" then
      ret = sc.FloatValue()
   else
      ret = sc.ChoiceValue()
   end
   ret:op_set(val)
   return ret
end

function OnLine(evt)
   local obj = evt:GetEventObject():DynamicCast("wxButton")
   if obj == nil then return end
   local list = lists[obj:GetName()]
   if list == nil then return end
   for name,col in pairs(list.cols) do
      table.insert(col.values, CloneValue(col.default))
   end
   list.rows = list.rows + 1
   FillGrid(list)
end

function OnValue(evt)
   evt:Skip()
   GeneratePart()
end

function OnNew(evt)
   local dlg = ShapeDialog()
   local name = dlg:GetName(curItem)
   if name == nil then return end
   tempObj:Clear()
   local dat = tempObj:GetGroupData()
   local cfg = wx.wxConfigBase.Get()
   cfg:SetPath("/plugins/shape/" .. name)
   dat:CopyFrom(cfg)
   dat:Write("name", name)
   ObjectSelected()
   tempObj:PositionNew()
   mode.ShowPos(tempObj:GetPosition2D())
end

function Clear()
   statusPanel:GetSizer():Clear(true)
   values = {}
   lists = {}
   shape = nil
   curItem = ""
   curPath = ""
   posX = nil
   posY = nil
   nameLabel:SetLabel("")
   hintBitmap:SetBitmap(wx.wxNullBitmap)
end

function ObjectSelected()
   Clear()
   local dat = tempObj:GetGroupData()
   local a
   local name
   a,name = dat:Read("name", "")
   if name == "" then return end
   nameLabel:SetLabel(wx.wxGetTranslation(wx.wxFileName(name):GetFullName()))
   local pth = sc.GetMyPath().. "shapes" .. slash .. name
   local file = pth .. slash .. "main.lua"
   if not wx.wxFileExists(file) then
      wx.wxLogMessage("Shape '" .. pth .. "' does not exist")
      return
   end

   curPath = pth
   curItem = name

   local err
   local shapeFunc
   shapeFunc = assert(loadfile(file))
   shapeFunc()
   if shape then
      LoadConfig(dat)
   else
      curPath = nil
      curItem = ""
   end
   
   AddNumControl("X", TR("X"), sc.unitLINEAR, 0, -1e17, 1e17, "")
   posX = values[#values]
   AddNumControl("Y", TR("Y"), sc.unitLINEAR, 0, -1e17, 1e17, "")
   posY = values[#values]
     
   CreateControls()
   for name, list in pairs(lists) do
      FillGrid(list)
   end
   GeneratePart()
   sc.Parts:Get().glDisplay:SetFocus() 
   EnableButtons(tempObj:IsNew(), true)
   mode.ShowPos(tempObj:GetPosition2D())
   posX.editor:Connect(sc.wxEVT_VALUE_DYNAMIC_CHANGE, OnPos)
   posY.editor:Connect(sc.wxEVT_VALUE_DYNAMIC_CHANGE, OnPos)
end

function OnPos(evt)
   if not posX then return end
   pos = sc.Coord2D(posX.value:op_get(), posY.value:op_get())
   tempObj:SetPosition2D(pos)
   tempObj:Update()
   sc.Parts:Get():SetDirty(sc.DIRTY_GRAPHICS)
end

function OnKey(evt)
   mode.OnKeyDown(evt)
end

function OnAdd()
   if curItem == "" then return end
   if(tempObj:IsNew()) then
      tempObj:InsertIntoPart()
   end
     
   local cfg = wx.wxConfigBase.Get()
   cfg:SetPath("/plugins/shape/" .. curItem)
   tempObj:GetGroupData():CopyTo(cfg)
   EnableButtons(false, true)
end



function OnPartAdd()
   if curItem == "" then return end
   local parts = sc.Parts:Get()
   local part = parts:AddNew()
   part.name = parts:CreateName(nameLabel:GetLabel(), "")
   parts.selected:Set(part)
   OnAdd()
end


-- ---------------------------------------------------------------------------
-- The main program as a function (makes it easy to exit on error)
function main()
   local parts = sc.Parts:Get()
   
   local cfg = wx.wxConfigBase.Get()
   cfg:SetPath("/plugins/shape")

   -- xml style resources (if present)
   local xmlResource = wx.wxXmlResource()
   xmlResource:InitAllHandlers()
   local xrcFilename = sc.GetMyPath().."shape.xrc"

   xmlResource:Load(xrcFilename)

   auiMgr = sc.scApp():GetAuiManager()
   mainWindow = auiMgr:GetManagedWindow();

   panel = xmlResource:LoadPanel(mainWindow, "shape")
   if not panel then
      wx.wxMessageBox("Error loading xrc resources!",
                     "Options",
                     wx.wxOK + wx.wxICON_EXCLAMATION,
                     wx.NULL)
      return -- quit program
   end

   statusPanel = panel:FindWindow(xmlResource.GetXRCID("ID_STATUSPANEL")):DynamicCast("wxPanel")
   hintBitmap = panel:FindWindow(xmlResource.GetXRCID("ID_VALUEHINT")):DynamicCast("wxStaticBitmap")
   scrollWindow = panel:FindWindow(xmlResource.GetXRCID("ID_SCROLLEDWINDOW")):DynamicCast("wxScrolledWindow")
   nameLabel = panel:FindWindow(xmlResource.GetXRCID("ID_SHAPELABEL")):DynamicCast("wxStaticText")
   local Btn = panel:FindWindow(xmlResource.GetXRCID("ID_BTNNEWSHAPE")):DynamicCast("wxButton")
   addBtn = panel:FindWindow(xmlResource.GetXRCID("ID_ADDBUTTON")):DynamicCast("wxButton")
   addBtn:Enable(false)
   addPartBtn = panel:FindWindow(xmlResource.GetXRCID("ID_ADDBUTTON2")):DynamicCast("wxButton")
   addPartBtn:Enable(false)
   delBtn = panel:FindWindow(xmlResource.GetXRCID("ID_BTNDELETE")):DynamicCast("wxButton")
   delBtn:Enable(false)

   bmpBtn = panel:FindWindow(xmlResource.GetXRCID("ID_CREATEBITMAP")):DynamicCast("wxButton")  
   local a
   local val
   a,val = cfg:Read("ShowButton", 0);
   bmpBtn:Show(val ~= 0)

   panel:Connect(xmlResource.GetXRCID("ID_ADDBUTTON"), wx.wxEVT_COMMAND_BUTTON_CLICKED, OnAdd)
   panel:Connect(xmlResource.GetXRCID("ID_ADDBUTTON2"), wx.wxEVT_COMMAND_BUTTON_CLICKED, OnPartAdd)
   panel:Connect(xmlResource.GetXRCID("ID_CREATEBITMAP"), wx.wxEVT_COMMAND_BUTTON_CLICKED, OnCreateBitmap)
   panel:Connect(xmlResource.GetXRCID("ID_BTNDELETE"), wx.wxEVT_COMMAND_BUTTON_CLICKED, OnDelete)

   panel:Connect(xmlResource.GetXRCID("ID_BTNNEWSHAPE"), wx.wxEVT_COMMAND_BUTTON_CLICKED, OnNew)

   Btn:Connect(wx.wxEVT_KEY_DOWN, OnKey)
   panel:Connect(wx.wxEVT_KEY_DOWN, OnKey)
   local wid = panel:ConvertDialogToPixels(wx.wxPoint(150,-1)).x
   a,wid = cfg:Read("Width", wid)
   info = wxaui.wxAuiPaneInfo():Hide():CloseButton(false):Dock():Caption(wx.wxGetTranslation("Shape")):Name("Shape"):Right():BestSize(wid,-1)
   auiMgr:AddPane(panel,info)
   auiMgr:Update()
--    _("Shape") --A bit of fudgery here to force the plugin name to appear in the translation

   CreateMode()
end


main()

function EnableControl(name, state)
   for nam, value in pairs(values) do
      if(value.varName == name and value.editor) then
         value.editor:Enable(state)
         value.label:Enable(state)
      end
   end
end


function AddNumControl(name, caption, units, default, min, max, icon)
   if string.len(icon) > 0 then
      icon = curPath .. slash .. icon
      icon = string.gsub(icon, "/", "\\")
   end
   val = sc.FloatValue()
   val:Init(wx.wxGetTranslation(caption), caption, 0, units, default, min, max, icon)
   values[#values + 1] = {value = val, varName = name}
end

function AddChoiceControl(name, caption, choices, icon)
   if string.len(icon) > 0 then
      icon = curPath .. slash .. icon
   end
   local val = sc.ChoiceValue()
   val:Init(caption, caption, 0, 0)
   val:SetIcon(icon)
   for name, strg in pairs(choices) do
      val:AddChoice(wx.wxGetTranslation(strg))
   end
   values[#values + 1] = {value = val, varName = name}
end


function AddListNumColumn(listName, name, caption, units, default, min, max, icon)
   if string.len(icon) > 0 then
      icon = curPath .. slash .. icon
   end
   local list = lists[listName]
   if list == nil then
      list = {}
      list.cols = {}
      list.rows = 0
      lists[listName] = list
   end

   local col = {}
   col.caption = caption
   col.default = sc.FloatValue()
   col.default:Init(name, name, 0, units, default, min, max, icon)
   col.values = {}

   local idx = 0
   for _ in pairs(list.cols) do idx = idx + 1 end
   col.index = idx
   list.cols[name] = col
end

function AddListChoiceColumn(listName, name, caption, choices, icon)
   if string.len(icon) > 0 then
      icon = curPath .. slash .. icon
   end
   local list = lists[listName]
   if list == nil then
      list = {}
      list.cols = {}
      list.rows = 0
      lists[listName] = list
   end
   local val = sc.ChoiceValue()
   val:Init(name, name, 0, 0)
   val:SetIcon(icon)
   val.choices = choices
   for name, strg in pairs(choices) do
      val:AddChoice(strg)
   end
   local col = {}
   col.caption = caption
   col.default = val
   col.values = {}
   local idx = 0
   for _ in pairs(list.cols) do idx = idx + 1 end
   col.index = idx
   list.cols[name] = col
end


