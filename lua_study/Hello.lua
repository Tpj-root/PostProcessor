-- Simulated SheetCAM post object
post = {
    SetCommentChars = function(startChar, endChar)
        print("Comment chars set to: " .. startChar .. " " .. endChar)
    end,
    Text = function(txt)
        io.write(txt)
    end,
    Number = function(label, value)
        io.write(label .. string.format("%.3f", value) .. " ")
    end
}

-- Initialize line number
lineNumber = 10

-- Sample coordinates
endX = 100.123
endY = 50.456

-- Functions
function OnInit()
    post.SetCommentChars("(", ")")
end

function OnNewLine()
    post.Text("\nN")
    post.Number("", lineNumber)
    lineNumber = lineNumber + 10
end

function OnRapid()
    post.Text("G0 ")
    post.Number("X", endX)
    post.Number("Y", endY)
end

-- Simulate execution
OnInit()
OnNewLine()
OnRapid()

