#!/usr/bin/texlua
-- Checks the well-formedness of YAML documents.
-- Usage: ./check-yaml.lua YAML_DOCUMENT...
local kpse = require("kpse")
kpse.set_program_name("luatex")
local tinyyaml = require("markdown-tinyyaml")
local file, input, output, ran_ok, err
local some_failed = false
local this_failed
for _, filename in ipairs(arg) do
  this_failed = false
  file = assert(io.open(arg[1], "r"))
  input = assert(file:read("*a"))
  ran_ok, err = pcall(function()
    output = tinyyaml.parse(input)
  end)
  if not ran_ok then
    print("File " .. filename .. " is not well-formed: " .. err)
    this_failed = true
  elseif not output then
    print("File " .. filename .. " contained no data.")
    this_failed = true
  else
    if output.logo ~= nil and string.find(output.logo, "_") then
      print("\nFile " .. filename .. " contains `logo: " .. output.logo .. "`, which contains underscores (`_`).")
      print("Underscores cause issues, see <https://github.com/istqborg/istqb_product_base/issues/46>. Please, remove them.\n")
      this_failed = true
    end
    if output['provided-by'] ~= nil then
      for i, provided_by in ipairs(output['provided-by']) do
        if provided_by.logo ~= nil and string.find(provided_by.logo, "_") then
          print("\nFile " .. filename .. " contains `provided_by[" .. i .. "].logo: " .. provided_by.logo .. "`, which contains underscores (`_`).")
          print("Underscores cause issues, see <https://github.com/istqborg/istqb_product_base/issues/46>. Please, remove them.\n")
          this_failed = true
        end
      end
    end
    for question_no, question in pairs(output) do
      if type(question) == 'table' and type(question['answers']) ~= nil and question['correct'] ~= nil then
        local correct = question['correct']
        local correct_num = 0
        if type(correct) == 'string' then
          for _ in correct:gmatch('[^,]*') do
            correct_num = correct_num + 1
          end
        else
          correct_num = #questions['correct']
        end
        if not (#question['answers'] == 4 and correct_num == 1 or #question['answers'] == 5 and correct_num == 2) then
          print("\nFile " .. filename .. ", question " .. question_no .. " contains " .. #question['answers'] .. " answers, out of which " .. correct_num .. " " .. (correct_num > 1 and "are" or "is") .. " marked as correct. Expected either 4 answers with 1 correct one or 5 answers with 2 correct ones.")
          break
        end
      end
    end
  end
  if this_failed then
    some_failed = true
  else
    print("File " .. filename .. " is well-formed.")
  end
  assert(file:close())
end
if some_failed then
  os.exit(1)
end
