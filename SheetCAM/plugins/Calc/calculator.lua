--    _("calculator") --A bit of fudgery here to force the plugin name to appear in the translation


-------------------------------------------------------------------------=---
-- Name:        Calculator.wx.lua
-- Purpose:     Calculator wxLua sample
-- Author:      J Winwood
--              Based on the wxWidgets sample by Marco Ghislanzoni
-- Created:     March 2002
-- Updated      January 2003 to use XML resources
-- Copyright:   (c) 2002-2003 Lomtick Software. All rights reserved.
-- Licence:     wxWidgets licence
-------------------------------------------------------------------------=---

-- ---------------------------------------------------------------------------
-- Global variables
dialog        = nil -- the wxDialog main toplevel window
xmlResource   = nil -- the XML resource handle
txtDisplay    = nil -- statictext window for the display
clearDisplay  = nil
lastNumber    = 0     -- the last number pressed, 0 - 9
lastOperationId = nil -- the window id of last operation button pressed
ID_START = nil  -- ID of the menu entry
decimal = "."   --this locale's decimal character

local xpmdata =
{
    "16 15 5 1",
    "  c None",
    "a c Black",
    "b c #FFFFFF",
    "c c #808080",
    "d c #9DBDCD",
    "  aaaaaaaaaaaa  ",
    "  addddddddddac ",
    "  adaaaaaaaadac ",
    "  adabbbbbbadac ",
    "  adabbbbbbadac ",
    "  adaaaaaaaadac ",
    "  addddddddddac ",
    "  adaadaadaadac ",
    "  adaadaadaadac ",
    "  addddddddddac ",
    "  adaadaadaadac ",
    "  adaadaadaadac ",
    "  addddddddddac ",
    "  aaaaaaaaaaaac ",
    "  ccccccccccccc "
}


-- ---------------------------------------------------------------------------
-- Handle the clear button event
function OnClear(event)
    txtDisplay:SetLabel("0")
    lastNumber      = 0
    lastOperationId = ID_PLUS
end

-- ---------------------------------------------------------------------------
-- Handle all number button events
function OnNumber(event)
    local numberId      = event:GetId()
    local displayString = txtDisplay:GetLabel()

    if (displayString == "0") or (tonumber(displayString) == nil) or clearDisplay then
        displayString = ""
    end
    clearDisplay = nil
    -- Limit string length to 12 chars
    if string.len(displayString) < 12 then
        if numberId == ID_DECIMAL then
            if not string.find(displayString, decimal, 1, 1) then
                -- If the first pressed char is "." then we want "0."
                if string.len(displayString) == 0 then
                    displayString = displayString.."0" .. decimal
                else
                    displayString = displayString..decimal
                end
            end
        else
            -- map button window ids to numeric values
            local idTable = { [ID_0] = 0, [ID_1] = 1, [ID_2] = 2, [ID_3] = 3,
                              [ID_4] = 4, [ID_5] = 5, [ID_6] = 6, [ID_7] = 7,
                              [ID_8] = 8, [ID_9] = 9 }

            local num = idTable[numberId]

            -- If first character entered is 0 we reject it
            if (num == 0) and (string.len(displayString) == 0) then
                displayString = "0"
            elseif displayString == "" then
                displayString = num
            else
                displayString = displayString..num
            end
        end

        txtDisplay:SetLabel(tostring(displayString))
    end
end

-- ---------------------------------------------------------------------------
-- Calculate the operation
function DoOperation(a, b, operationId)
    local result = a
    if operationId == ID_PLUS then
        result =  b + a
    elseif operationId == ID_MINUS then
        result =  b - a
    elseif operationId == ID_MULTIPLY then
        result = b * a
    elseif operationId == ID_DIVIDE then
        if a == 0 then
            result = _("Divide by zero error")
        else
            result = b / a
        end
    end
    return result
end

-- ---------------------------------------------------------------------------
-- Handle start event - show the dialog
function OnStart(event)
    dialog:Show(true)
end

-- ---------------------------------------------------------------------------
-- Handle all operation button events
function OnOperator(event)
    -- Get display content
    local displayString = txtDisplay:GetLabel()
    local currentNumber = tonumber(displayString)

    -- if error message was shown, zero output and ignore operator
    if ((currentNumber == nil) or (lastNumber == nil)) then
        lastNumber = 0
        return
    end

    -- Get the required lastOperationId
    local operationId = event:GetId()

    displayString = DoOperation(currentNumber, lastNumber, lastOperationId)
    lastNumber    = tonumber(displayString)

    if (lastOperationId ~= ID_EQUALS) or (operationId == ID_EQUALS) then
        txtDisplay:SetLabel(tostring(displayString))
    end
    clearDisplay  = 1
    lastOperationId = operationId
end

-- ---------------------------------------------------------------------------
-- Handle the options event
-- note: this is a special event as you don't connect() it!
-- If a function with this name exists it is automatically called

function OnShowOptions(event)
    event:GetTextCtrl():AppendText(_("wxLua calculator sample based on the calc sample written by Marco Ghislanzoni.\n\n")..
                        wxlua.wxLUA_VERSION_STRING.._(" built with ")..wx.wxVERSION_STRING)
end


-- ---------------------------------------------------------------------------
-- Handle the quit button event
function OnQuit(event)
    event:Skip()
    dialog:Show(false)
end

-- ---------------------------------------------------------------------------
-- The main program as a function (makes it easy to exit on error)
function main()

    --get the decimal point character fro this locale
    decimal = wx.wxLocale.GetInfo(wx.wxLOCALE_DECIMAL_POINT,wx.wxLOCALE_CAT_NUMBER)

    -- xml style resources (if present)
    xmlResource = wx.wxXmlResource(wx.wxXRC_USE_LOCALE)
    xmlResource:InitAllHandlers()
    local xrcFilename = sc.GetMyPath().."calculator.xrc"

    -- try to load the resource and ask for path to it if not found
    if not xmlResource:Load(xrcFilename) then
        wx.wxMessageBox("Cannot load '" .. xrcFilename .. "'.",
                        "Calculator",
                        wx.wxOK + wx.wxICON_EXCLAMATION,
                        wx.NULL)
        return -- quit program
    end

    dialog = wx.wxDialog()
    if not xmlResource:LoadDialog(dialog, wx.NULL, "Calculator") then
        wx.wxMessageBox("Error loading xrc resources!",
                        "Calculator",
                        wx.wxOK + wx.wxICON_EXCLAMATION,
                        wx.NULL)
        return -- quit program
    end

    -- -----------------------------------------------------------------------
    -- This is a little awkward, but it's how it's done in C++ too
    bitmap = wx.wxBitmap(xpmdata)
    icon = wx.wxIcon()
    icon:CopyFromBitmap(bitmap)
    dialog:SetIcon(icon)
    bitmap:delete()
    icon:delete()

--    bestSize = dialog:GetBestSize()
--    dialog:SetSize(bestSize:GetWidth()/2, bestSize:GetHeight())
--    dialog:SetSizeHints(bestSize:GetWidth()/2, bestSize:GetHeight())

    -- initialize the txtDisplay and verify that it's ok
    txtDisplay = dialog:FindWindow(xmlResource.GetXRCID("ID_TEXT"))
    if not txtDisplay then
        wx.wxError([[Unable to find window "ID_TEXT" in the dialog]])
    end
    if not txtDisplay:DynamicCast("wxStaticText") then
        wx.wxError([[window "ID_TEXT" is not a "wxStaticText" or is not derived from it"]])
    end
    txtDisplay:SetLabel("0")

    -- init global wxWindow ID values
    ID_0        = xmlResource.GetXRCID("ID_0")
    ID_1        = xmlResource.GetXRCID("ID_1")
    ID_2        = xmlResource.GetXRCID("ID_2")
    ID_3        = xmlResource.GetXRCID("ID_3")
    ID_4        = xmlResource.GetXRCID("ID_4")
    ID_5        = xmlResource.GetXRCID("ID_5")
    ID_6        = xmlResource.GetXRCID("ID_6")
    ID_7        = xmlResource.GetXRCID("ID_7")
    ID_8        = xmlResource.GetXRCID("ID_8")
    ID_9        = xmlResource.GetXRCID("ID_9")
    ID_DECIMAL  = xmlResource.GetXRCID("ID_DECIMAL")
    ID_EQUALS   = xmlResource.GetXRCID("ID_EQUALS")
    ID_PLUS     = xmlResource.GetXRCID("ID_PLUS")
    ID_MINUS    = xmlResource.GetXRCID("ID_MINUS")
    ID_MULTIPLY = xmlResource.GetXRCID("ID_MULTIPLY")
    ID_DIVIDE   = xmlResource.GetXRCID("ID_DIVIDE")
    ID_OFF      = xmlResource.GetXRCID("ID_OFF")
    ID_CLEAR    = xmlResource.GetXRCID("ID_CLEAR")

    lastOperationId = ID_PLUS

    dialog:Connect(ID_0,        wx.wxEVT_COMMAND_BUTTON_CLICKED, OnNumber)
    dialog:Connect(ID_1,        wx.wxEVT_COMMAND_BUTTON_CLICKED, OnNumber)
    dialog:Connect(ID_2,        wx.wxEVT_COMMAND_BUTTON_CLICKED, OnNumber)
    dialog:Connect(ID_3,        wx.wxEVT_COMMAND_BUTTON_CLICKED, OnNumber)
    dialog:Connect(ID_4,        wx.wxEVT_COMMAND_BUTTON_CLICKED, OnNumber)
    dialog:Connect(ID_5,        wx.wxEVT_COMMAND_BUTTON_CLICKED, OnNumber)
    dialog:Connect(ID_6,        wx.wxEVT_COMMAND_BUTTON_CLICKED, OnNumber)
    dialog:Connect(ID_7,        wx.wxEVT_COMMAND_BUTTON_CLICKED, OnNumber)
    dialog:Connect(ID_8,        wx.wxEVT_COMMAND_BUTTON_CLICKED, OnNumber)
    dialog:Connect(ID_9,        wx.wxEVT_COMMAND_BUTTON_CLICKED, OnNumber)
    dialog:Connect(ID_DECIMAL,  wx.wxEVT_COMMAND_BUTTON_CLICKED, OnNumber)
    dialog:Connect(ID_EQUALS,   wx.wxEVT_COMMAND_BUTTON_CLICKED, OnOperator)
    dialog:Connect(ID_PLUS,     wx.wxEVT_COMMAND_BUTTON_CLICKED, OnOperator)
    dialog:Connect(ID_MINUS,    wx.wxEVT_COMMAND_BUTTON_CLICKED, OnOperator)
    dialog:Connect(ID_MULTIPLY, wx.wxEVT_COMMAND_BUTTON_CLICKED, OnOperator)
    dialog:Connect(ID_DIVIDE,   wx.wxEVT_COMMAND_BUTTON_CLICKED, OnOperator)
    dialog:Connect(ID_OFF,      wx.wxEVT_COMMAND_BUTTON_CLICKED, OnQuit)
    dialog:Connect(ID_CLEAR,    wx.wxEVT_COMMAND_BUTTON_CLICKED, OnClear)

    dialog:Connect(wx.wxEVT_CLOSE_WINDOW, OnQuit)

    accelTable = wx.wxAcceleratorTable({
        { wx.wxACCEL_NORMAL, string.byte('0'),       ID_0        },
        { wx.wxACCEL_NORMAL, string.byte('1'),       ID_1        },
        { wx.wxACCEL_NORMAL, string.byte('2'),       ID_2        },
        { wx.wxACCEL_NORMAL, string.byte('3'),       ID_3        },
        { wx.wxACCEL_NORMAL, string.byte('4'),       ID_4        },
        { wx.wxACCEL_NORMAL, string.byte('5'),       ID_5        },
        { wx.wxACCEL_NORMAL, string.byte('6'),       ID_6        },
        { wx.wxACCEL_NORMAL, string.byte('7'),       ID_7        },
        { wx.wxACCEL_NORMAL, string.byte('8'),       ID_8        },
        { wx.wxACCEL_NORMAL, string.byte('9'),       ID_9        },
        { wx.wxACCEL_NORMAL, wx.VXK_NUMPAD0,         ID_0        },
        { wx.wxACCEL_NORMAL, wx.VXK_NUMPAD1,         ID_1        },
        { wx.wxACCEL_NORMAL, wx.VXK_NUMPAD2,         ID_2        },
        { wx.wxACCEL_NORMAL, wx.VXK_NUMPAD3,         ID_3        },
        { wx.wxACCEL_NORMAL, wx.VXK_NUMPAD4,         ID_4        },
        { wx.wxACCEL_NORMAL, wx.VXK_NUMPAD5,         ID_5        },
        { wx.wxACCEL_NORMAL, wx.VXK_NUMPAD6,         ID_6        },
        { wx.wxACCEL_NORMAL, wx.VXK_NUMPAD7,         ID_7        },
        { wx.wxACCEL_NORMAL, wx.VXK_NUMPAD8,         ID_8        },
        { wx.wxACCEL_NORMAL, wx.VXK_NUMPAD9,         ID_9        },
        { wx.wxACCEL_NORMAL, string.byte(decimal),   ID_DECIMAL  },
        { wx.wxACCEL_NORMAL, wx.VXK_NUMPAD_DECIMAL,  ID_DECIMAL  },
        { wx.wxACCEL_NORMAL, string.byte('='),       ID_EQUALS   },
        { wx.wxACCEL_NORMAL, wx.VXK_NUMPAD_ENTER,    ID_EQUALS   },
        { wx.wxACCEL_NORMAL, 13,                     ID_EQUALS   },
        { wx.wxACCEL_NORMAL, string.byte('+'),       ID_PLUS     },
        { wx.wxACCEL_NORMAL, wx.VXK_NUMPAD_ADD,      ID_PLUS     },
        { wx.wxACCEL_NORMAL, string.byte('-'),       ID_MINUS    },
        { wx.wxACCEL_NORMAL, wx.VXK_NUMPAD_SUBTRACT, ID_MINUS    },
        { wx.wxACCEL_NORMAL, string.byte('*'),       ID_MULTIPLY },
        { wx.wxACCEL_NORMAL, wx.VXK_NUMPAD_MULTIPLY, ID_MULTIPLY },
        { wx.wxACCEL_NORMAL, string.byte('/'),       ID_DIVIDE   },
        { wx.wxACCEL_NORMAL, wx.VXK_NUMPAD_DIVIDE,   ID_DIVIDE   },
        { wx.wxACCEL_NORMAL, string.byte('C'),       ID_CLEAR    },
        { wx.wxACCEL_NORMAL, string.byte('c'),       ID_CLEAR    },
        { wx.wxACCEL_NORMAL, wx.WXK_ESCAPE,          ID_OFF      }
    })


    -- Show the correct decimal character
    local btnDecimal = dialog:FindWindow(ID_DECIMAL)
    if not btnDecimal then
        wx.wxError([[Unable to find window "ID_DECIMAL" in the dialog]])
    end
    if not btnDecimal:DynamicCast("wxButton") then
        wx.wxError([[window "ID_DECIMAL" is not a "wxButton" or is not derived from it"]])
    end
    btnDecimal:SetLabel(decimal)



    dialog:SetAcceleratorTable(accelTable)
    dialog:Centre()

    --add a menu to the main application
    local app = sc.scApp();

    local a = _("Calculator") --a bit of fudgery here, these are just here for gettext.
    a = _("&Plugins") --gettext will add these to the catalog. TNG then reads the catalog on calls to AddMenu and SetMenuPath

    app:SetMenuPath("/&Plugins")
    ID_START = app:AddMenu(dialog,"Plugins","Calculator",_("Run the calculator"),"Calculator",sc.ITEM_NORMAL)
    app:UpdateBars() --regenerate toolbars
    dialog:Connect(ID_START, sc.wxEVT_ACTION, OnStart)

end



main()
