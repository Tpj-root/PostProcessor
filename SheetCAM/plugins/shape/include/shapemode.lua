mouseDown = false;
downPos = sc.Coord2D(0,0)
lastId = nil


function CreateMode()
   local modeId = wx.wxNewId()
   mode = sc.EditorMode(modeId, sc.scDISPLAY_ONE, "Shape", _("Shape cutting library"), sc.GetMyPath() .. "shape") --create the base class
   mode.isActive = false

   function mode.DoActivate(prevMode) --called when mode is activated
      local mgr = sc.wxActionManager:Get()
      info = auiMgr:GetPane(panel)
      info:Show(true):CloseButton(false)
      if(info:IsDocked()) then
         local siz = panel:GetSize()
         info:MinSize(siz)
         auiMgr:Update()
         info:MinSize(wx.wxSize(-1,-1))
      else
         auiMgr:Update()
      end
      mode.isActive = true
      tempObj:Clear()      
   end

   function mode.DoDeActivate()  --called when mode is deactivated
      local mgr = sc.wxActionManager:Get()
      lastId = tempObj:GetId();
      info = auiMgr:GetPane(panel)
      info:Show(false)
      auiMgr:Update()
      mode.isActive = false
      Clear()
      tempObj:Clear()
      tempObj:Draw()
      mouseDown = false
   end

   function mode.OnMotion(evt) --called when mouse moves
      if(evt:ShiftDown()) then
         mode._OnMotion(evt)
         return
      end
      local mousePos = mode.m_panel:ScreenToCoord(evt:GetX(), evt:GetY())
      if(not mouseDown) then return end
      if(mousePos:op_eq(downPos)) then
         return
      end
      diff = mousePos:op_sub(downPos)
      downPos = mousePos
      local pos = tempObj:GetPosition2D():op_add(diff)
      tempObj:SetPosition2D(pos)
      mode.ShowPos(pos)
      if(not mode:ScrollIfNeeded(evt)) then
         mode:GlRedraw()
      end
   end

   function mode.OnKeyDown(evt)
      if mouseDown and evt:GetKeyCode() == wx.WXK_ESCAPE then
         mouseDown = false
         tempObj:SetPosition2D(startPos)
         mode.ShowPos(startPos)
      end
      evt:Skip()
   end

   function mode.OnLeftDown(evt)
      downPos = mode.m_panel:ScreenToCoord(evt:GetX(), evt:GetY())
      startPos = tempObj:GetPosition2D()
      local sel = tempObj:InitFromPoint(downPos)
      if sel == sc.EditableObject.foundNOT then
         EnableButtons(false, false)
         return
      end
      if sel == sc.EditableObject.foundNEW then
         ObjectSelected()
      else
         EnableButtons(tempObj:IsNew(), true)
      end
      mouseDown = true
   end

   function mode.OnLeftUp(evt)
      mouseDown = false
      tempObj:Update()
   end
   
   function mode.ShowPos(pos)
      if posX == nil then return end
      posX.value:op_set(pos.x)
      posX.editor:GetValidator():TransferToWindow();
      posY.value:op_set(pos.y)
      posY.editor:GetValidator():TransferToWindow();
   end
end
