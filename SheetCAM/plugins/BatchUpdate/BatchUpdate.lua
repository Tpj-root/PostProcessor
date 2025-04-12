--    _("Batch update") --A bit of fudgery here to force the plugin name to appear in the translation

-- ---------------------------------------------------------------------------
-- Handle the options event
-- note: this is a special event as you don't connect() it!
-- If a function with this name exists it is automatically called

function OnShowOptions(event)
    event:GetTextCtrl():AppendText("Job batch image updater\nScans a directory and updates the thumbnail images\n")
end

evtHdlr = wx.wxEvtHandler()

function OnStart(event)
   local app = sc.scApp();
   cfg:SetPath("/Preferences")
   cfg:Write("saveImageWithJob", 1)
   dir = wx.wxDirSelector("Select the directory to scan")
   if(string.len(dir) == 0) then return end
   dirList = wx.wxDir(dir)
   cont,name = dirList:GetFirst("*.job", wx.wxDIR_FILES)
   while cont do
      local path = dir .. "\\" .. name
      wx.wxLogMessage("Updating " .. path)
      app:LoadJob(path);
      wx.wxYield();
      app:ExecuteMenu(4) --save job
      wx.wxYield();
      wx.wxMilliSleep(200)
      wx.wxYield();
      cont,name = dirList:GetNext()
   end   
end


function main()
   --add a menu to the main application
   local app = sc.scApp();

   app:SetMenuPath("/&Plugins")
   ID_START = app:AddMenu(evtHdlr,"Plugins","Batch update",_("Generate thumbnail images for a batch of jobs"),"",sc.ITEM_NORMAL)
   app:UpdateBars() --regenerate toolbars
   evtHdlr:Connect(ID_START, sc.wxEVT_ACTION, OnStart)
   cfg = wx.wxConfigBase.Get(false)
end



main()
