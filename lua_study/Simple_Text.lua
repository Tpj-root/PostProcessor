-- Format a string with placeholders
local template = "Hello, my name is %s and I am %d years old."
local name = "shadow"
local age = 99
local output = string.format(template, name, age)

-- Print the formatted text
print(output)
