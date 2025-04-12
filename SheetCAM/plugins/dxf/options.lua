--    _("DXF") --A bit of fudgery here to force the plugin name to appear in the translation

function FromBool(val)
   if val then
      return 1
   else
       return 0
   end
end

-- ---------------------------------------------------------------------------
-- Handle the options event
-- note: this is a special event as you don't connect() it!
-- If a function with this name exists it is automatically called

function OnShowOptions(event)
    event:GetTextCtrl():AppendText(_("DXF import filter\n\nNote: does not handle text entities or blocks"))
end

-- ---------------------------------------------------------------------------
-- Notification from dll to show dialog
function OnNotify(index,value)
    dlg = sc.DrawingOptionsDlg()

    usePoints = wx.wxCheckBox(dlg,wx.wxID_ANY,_("Use points for drilling"))
    dlg:GetSizer(false):Add(usePoints,0,wx.wxALIGN_CENTER)
    useColours = wx.wxCheckBox(dlg,wx.wxID_ANY,_("Use colours as layer names"))
    dlg:GetSizer(false):Add(useColours,0,wx.wxALIGN_CENTER + wx.wxALL, dlg:ConvertDialogToPixels(wx.wxSize(6,0)):GetWidth())


    cfg = wx.wxConfigBase.Get(false)
    cfg:SetPath("/Import")

    a,res = cfg:Read("UsePoints",1)
    usePoints:SetValue(res == 1)

    a,res = cfg:Read("UseColours",0)
    useColours:SetValue(res == 1)

    dlg:ShowModal()

    cfg:Write("UsePoints",FromBool(usePoints:GetValue()))
    cfg:Write("UseColours",FromBool(useColours:GetValue()))

end

