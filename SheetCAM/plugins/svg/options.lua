--    _("SVG") --A bit of fudgery here to force the plugin name to appear in the translation


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
    event:GetTextCtrl():AppendText(_("SVG import filter\n\nNote: Does not currently handle text entities"))
end


-- ---------------------------------------------------------------------------
-- Notification from dll to show dialog
function OnNotify(index,value)

    dlg = sc.DrawingOptionsDlg()

    dlg:ShowScale(sc.DrawingOptionsDlg.scaleCUSTOM)
    cfg = wx.wxConfigBase.Get(false)
    cfg:SetPath("/Import")
    
    local choices = wx.wxArrayString();
    choices:Add(_("90DPI"))
    choices:Add(_("96DPI"))
    a,res = cfg:Read("96DPI",1)
    dpi96 = wx.wxRadioBox(dlg,wx.wxID_ANY,_("Pixel size"), wx.wxDefaultPosition, wx.wxDefaultSize, choices, 0 , wx.wxRA_SPECIFY_ROWS)
    dlg:GetSizer(false):Add(dpi96,0,wx.wxALIGN_CENTER)
    if res ~= 1 then res = 0 end
    dpi96:SetSelection(res)

    a,res = cfg:Read("UseColour",1)
    useColour = wx.wxCheckBox(dlg,wx.wxID_ANY,_("Use colours as layer names"))
    dlg:GetSizer(false):Add(useColour,0,wx.wxALIGN_CENTER)
    useColour:SetValue(res == 1)

    dlg:ShowModal()

    cfg:Write("UseColour",FromBool(useColour:GetValue()))
    cfg:Write("96DPI",dpi96:GetSelection())

end

