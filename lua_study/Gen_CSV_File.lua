function generateCSV(data)
    local file = io.open("data.csv", "w")
    
    -- Write the header
    file:write("Name, Age, Job\n")
    
    -- Write the data rows
    for _, row in ipairs(data) do
        file:write(row.name .. ", " .. row.age .. ", " .. row.job .. "\n")
    end
    
    file:close()
    print("CSV file generated.")
end

-- Sample data to be written to the CSV
local people = {
    {name = "Alice", age = 25, job = "Engineer"},
    {name = "Bob", age = 28, job = "Designer"},
    {name = "Charlie", age = 35, job = "Manager"}
}

generateCSV(people)
