-- Define a function to create a report
function generateReport(name, age, job)
    local report = "Name: " .. name .. "\n"
    report = report .. "Age: " .. age .. "\n"
    report = report .. "Job: " .. job .. "\n"
    
    -- Save the report to a file
    local file = io.open("report.txt", "w")
    file:write(report)
    file:close()
    
    print("Report generated successfully.")
end

-- Call the function with sample data
generateReport("John Doe", 30, "Software Engineer")
