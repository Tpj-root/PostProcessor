
ShapeDialog = class(function (self)
   local xmlResource = wx.wxXmlResource()
   xmlResource:InitAllHandlers()
   xmlResource:Load(sc.GetMyPath().."ShapeDialog.xrc")
   self.dlg = xmlResource:LoadDialog(auiMgr:GetManagedWindow(), "ShapeDialog")
   if not self.dlg then
      wx.wxMessageBox("Error loading xrc resources!",
                     "Options",
                     wx.wxOK + wx.wxICON_EXCLAMATION,
                     wx.NULL)
      return -- quit
   end
   self.tree = self.dlg:FindWindow(xmlResource.GetXRCID("ID_DIRTREE")):DynamicCast("wxTreeCtrl")
   self.tree:Connect(xmlResource.GetXRCID("ID_DIRTREE"), wx.wxEVT_LEFT_DCLICK , self.OnDoubleClick)   
   self.imgList = wx.wxImageList(32,32,true,0)
   self.tree:SetImageList(self.imgList)
   local path = sc.GetMyPath()
   path = path .. "shapes"
   self:RecurseDirs(path, self.tree:AddRoot(""))

   local cfg = wx.wxConfigBase.Get(false)
   cfg:SetPath("/plugins/Shape")
   local a
   local w
   local h
   a,w = cfg:Read("DialogWidth", -1);
   a,h = cfg:Read("DialogHeight", -1);
   if(w > 50 and h > 50) then
      self.dlg:SetSize(wx.wxSize(w,h))
   end

   self.dlg:Show(false)
   self.dlg:Centre()
end)

function ShapeDialog:SavePos()
   local cfg = wx.wxConfigBase.Get(false)
   cfg:SetPath("/plugins/Shape")
   local s = self.dlg:GetSize()
   cfg:Write("DialogWidth", s:GetWidth())
   cfg:Write("DialogHeight", s:GetHeight())
end

function ShapeDialog:GetName(name)
   local tok = wx.wxStringTokenizer(name, "\\/")
   local id = self.tree:GetRootItem()
   while tok:HasMoreTokens() do
      local tag = tok:GetNextToken()
      local cookie
      local item = id
      id, cookie = self.tree:GetFirstChild(item)
      local found = false
      while id:IsOk() do
         local dat = self.tree:GetItemData(id)
         if dat then dat = dat:GetData() end
         if(dat == tag) then
            found = true
            break
         end
         id, cookie = self.tree:GetNextChild(item, cookie)
      end
      if not found then return end --path not found
   end
   self.tree:SelectItem(id)
   local ret = self.dlg:ShowModal()
   self:SavePos()
   if(ret ~= wx.wxID_OK) then return end

   local path = nil
   id = self.tree:GetSelection()
   while id:IsOk() do
      local tName = self.tree:GetItemData(id)
      if tName then tName = tName:GetData() end
      if not tName then break end
      if path then
         path = tName .. slash .. path
      else
         path = tName
      end
      id = self.tree:GetItemParent(id)
   end
   return path
end

function ShapeDialog:RecurseDirs(path, parentItem)
   local dir = wx.wxDir(path);
   local fileName
   local a
   a,fileName = dir:GetFirst("*",wx.wxDIR_DIRS)
   while fileName ~= "" do
      local img = -1;
      local dirPath = path .. slash .. fileName
      local png = wx.wxBitmap(dirPath .. slash .. "icon.png")
      
      if(png:Ok()) then
         if(png:GetWidth() ~= 32 or png:GetHeight() ~= 32) then
            local image = png:ConvertToImage()
            image:Rescale(32,32)
            png = wx.wxBitmap(image)
         end

         img = self.tree:GetImageList():Add(png)
      end
      local id = self.tree:AppendItem(parentItem, wx.wxGetTranslation(fileName), img, -1,
         wx.wxLuaTreeItemData(fileName))

      self:RecurseDirs(dirPath, id)
      a,fileName = dir:GetNext()
   end
end

function ShapeDialog:OnDoubleClick(dlg)
   local tree = self:GetEventObject():DynamicCast("wxTreeCtrl")
   local dlg = tree:GetParent():DynamicCast("wxDialog")
   dlg:EndModal(wx.wxID_OK) --This is fugly. There must be a better way
end
