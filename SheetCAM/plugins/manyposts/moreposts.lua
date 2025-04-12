hdlr = wx.wxEvtHandler()
 
NUMPOSTS = 3
 
posts={}

edPath = wx.wxStandardPaths:Get():GetUserDataDir()


function FillPostNames()
   postNames = {}
   
	local path = sc.Globals.Get().postDir
   local dir = wx.wxDir(path);
   local found
   local name
   
   found, name = dir:GetFirst("*.scpost")
   while(found) do
      local entry={}
      entry.name = wx.wxFileName(name):GetName() .. " (Edited)"
      entry.path = path .. name
      table.insert(postNames, entry)
      found, name = dir:GetNext("*.scpost")
   end
   local sep = string.char(wx.wxFileName.GetPathSeparator())
	path = sc.Globals.Get().thisDir .. sep .. "posts" .. sep
   dir = wx.wxDir(path)
   found, name = dir:GetFirst("*.scpost")
   while(found) do
      local entry={}
      entry.name = wx.wxFileName(name):GetName()
      entry.path = path .. name
      table.insert(postNames, entry)
      found, name = dir:GetNext("*.scpost")
   end
   
   table.sort(postNames, function(a,b) return a.name < b.name end)
   table.insert(postNames,1,{name=_("Unused"), path=""})

end

-- ---------------------------------------------------------------------------
-- Handle the options event
-- note: this is a special event as you don't connect() it!
-- If a function with this name exists it is automatically called

function OnShowOptions(event)
   FillPostNames()
   xmlResource = wx.wxXmlResource(wx.wxXRC_USE_LOCALE)
   xmlResource:InitAllHandlers()
   local xrcFilename = sc.GetMyPath().."PostList.xrc"
   xmlResource:Load(xrcFilename)
   optionPanel = xmlResource:LoadPanel(event:GetPanel(), "PostList")
   if not optionPanel then
      wx.wxMessageBox("Error loading xrc resources!",
         "Moreposts Options",
         wx.wxOK + wx.wxICON_EXCLAMATION,
         wx.NULL)
      return
   end
   event:AddWindow(optionPanel)
   local cfg = wx.wxConfigBase.Get()
   cfg:SetPath("/plugins/moreposts")
   ctrls = {}
   for ct=1,NUMPOSTS do
      local id = xmlResource.GetXRCID("ID_CHOICE" .. ct)
      local ctrl = optionPanel:FindWindow(id):DynamicCast("wxChoice")
      ctrl:Freeze()
      ctrls[ct] = ctrl
      local sel = 0
      local found, path
      found,path = cfg:Read("post" .. ct)
      for idx,val in ipairs(postNames) do
         ctrl:Append(val.name)
         if val.path == path then
            sel = idx - 1
         end
      end
      ctrl:SetSelection(sel)
      ctrl:Thaw()
   end
end

function OnHideOptions()
   local cfg = wx.wxConfigBase.Get()
   local changed = false
   cfg:SetPath("/plugins/moreposts")
   for ct=1,NUMPOSTS do
      local ctrl = ctrls[ct]
      local idx = ctrl:GetSelection() + 1
      local val = ""
      if idx > 0 then
         val = postNames[idx].path
      end
      local a,was
      a,prev = cfg:Read("post" .. ct)
      if prev ~= val then
         cfg:Write("post" .. ct, val)
         changed = true
      end
   end
   if changed then
      local app = sc.scApp();
      app:SetMenuPath("/&File")
      local mgr = sc.wxActionManager.Get()
      for id,v in pairs(posts) do
         act = mgr:ActionFromID(id)
         if(act) then
            mgr:DeleteAction(act)
         end
      end
      posts={}
      for ct=1,NUMPOSTS do
         local ctrl = ctrls[ct]
         local idx = ctrl:GetSelection() + 1
         if idx > 0 and postNames[idx].path ~= "" then
            MakeMenu(ct, postNames[idx].path)
         end
      end
      app:UpdateBars() --regenerate toolbars
   end
end


function OnPost(evt)
   local id = evt:GetId()
   local post = posts[id];
   if post == NIL then return end
   
   
   local pths = wx.wxStandardPaths:Get()
   
   local cfg = wx.wxConfigBase.Get()
   local out
   local job
   local ext
   a,out = cfg:Read("/Post/LastFile")
   out = wx.wxFileName(out):GetPath() .. "/"
   
   a,job = cfg:Read("/MRU/Job/file1")
   job = wx.wxFileName(job):GetName()
   
   a,ext = cfg:Read("/Post/FileExtension")
   
   out = out .. job .. "(" .. post .. ")." .. ext   
   sc.RunPost(wx.wxString(), post);
end


function main()
   local app = sc.scApp();

   local cfg = wx.wxConfigBase.Get()
   cfg:SetPath("/plugins/moreposts")
   local path
   local found
   posts = {}
   app:SetMenuPath("/&File")
   for ct=1,NUMPOSTS do
      found,path = cfg:Read("post" .. ct)
      if found and path ~= "" then
         MakeMenu(ct,path)
      end
   end
   
   app:UpdateBars() --regenerate toolbars
end

function GetPostName(path)
   local name = wx.wxFileName(path):GetName()
   local len = string.len(edPath)
   
   if(string.sub(path,1,len) == edPath) then
      name = name .. _(" (Edited)")
   end
   return name
end

function MakeMenu(index, path)
   local bitmapPath = sc.GetMyPath()
   local name = GetPostName(path)
   local app = sc.scApp();
   local id = app:AddMenu(hdlr,"Post","Run " .. name .. " Post","Run " .. name .. " Post",bitmapPath.."P" .. index + 1 .. ".ico",sc.ITEM_NORMAL)
   posts[id] = path
   hdlr:Connect(id, sc.wxEVT_ACTION, OnPost)
end


main()
