--    _("HPGL") --A bit of fudgery here to force the plugin name to appear in the translation


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
    event:GetTextCtrl():AppendText(_("HPGL/1 import filter\n\nDoes not handle text entities"))
end


-- ---------------------------------------------------------------------------
-- Notification from dll to show dialog
function OnNotify(index,value)
    dlg = sc.DrawingOptionsDlg()
    
    dlg:ShowScale(sc.DrawingOptionsDlg.scaleCUSTOM)

    dlg:ShowModal()

end

