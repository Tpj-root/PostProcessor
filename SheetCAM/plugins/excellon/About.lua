function OnShowOptions(event)
    local text = _("Excellon import filter\n\nCan automatically create tools and operations based on the tool definitions in the file")
    event:GetTextCtrl():AppendText(text)
end
