#!/usr/bin/texlua
-- Checks the well-formedness of YAML documents.
-- Usage: ./check-yaml.lua YAML_DOCUMENT...
local kpse = require("kpse")
kpse.set_program_name("luatex")
local tinyyaml = require("markdown-tinyyaml")
local file, input, output, ran_ok, err
local some_failed = false
for _, filename in ipairs(arg) do
  file = assert(io.open(arg[1], "r"))
  input = assert(file:read("*a"))
  ran_ok, err = pcall(function()
    output = tinyyaml.parse(input)
  end)
  if not ran_ok then
    print("File " .. filename .. " is not well-formed: " .. err)
    some_failed = true
  elseif not output then
    print("File " .. filename .. " contained no data.")
    some_failed = true
  else
    print("File " .. filename .. " is well-formed.")
  end
  assert(file:close())
end
if some_failed then
  os.exit(1)
end
