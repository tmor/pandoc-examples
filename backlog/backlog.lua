-- This is a sample custom writer for pandoc.  It produces output
-- backlog
-- Invoke with: pandoc -t backlog.lua
-- This custom writer is made refering "sample.lua"(https://github.com/jgm/pandoc/blob/master/data/sample.lua)
-- The writer cannot translate markdown in backlog perfectly. But I'm satisfy with this one.

-- Character escaping
local function escape(s, in_attribute)
  return s:gsub("[<>&\"']",
    function(x)
      if x == '<' then
        return '&lt;'
      elseif x == '>' then
        return '&gt;'
      elseif x == '&' then
        return '&amp;'
      elseif x == '"' then
        return '&quot;'
      elseif x == "'" then
        return '&#39;'
      else
        return x
      end
    end)
end

-- Helper function to convert an attributes table into
-- a string that can be put into HTML tags.
local function attributes(attr)
  local attr_table = {}
  for x,y in pairs(attr) do
    if y and y ~= "" then
      table.insert(attr_table, ' ' .. x .. '="' .. escape(y,true) .. '"')
    end
  end
  return table.concat(attr_table)
end

-- Run cmd on a temporary file containing inp and return result.
local function pipe(cmd, inp)
  local tmp = os.tmpname()
  local tmph = io.open(tmp, "w")
  tmph:write(inp)
  tmph:close()
  local outh = io.popen(cmd .. " " .. tmp,"r")
  local result = outh:read("*all")
  outh:close()
  os.remove(tmp)
  return result
end

-- Table to store footnotes, so they can be included at the end.
local notes = {}

-- Blocksep is used to separate block elements.
function Blocksep()
  return "\n\n"
end

-- This function is called once for the whole document. Parameters:
-- body is a string, metadata is a table, variables is a table.
-- This gives you a fragment.  You could use the metadata table to
-- fill variables in a custom lua template.  Or, pass `--template=...`
-- to pandoc, and pandoc will add do the template processing as
-- usual.
function Doc(body, metadata, variables)
  local buffer = {}
  local function add(s)
    table.insert(buffer, s)
  end
  add(body)
  return table.concat(buffer,'\n')
end

-- The functions that follow render corresponding pandoc elements.
-- s is always a string, attr is always a table of attributes, and
-- items is always an array of strings (the items in a list).
-- Comments indicate the types of other variables.

function Str(s)
  return escape(s)
end

function Space()
  return " "
end

function SoftBreak()
  return "\n"
end

function LineBreak()
  return "\n"
end

function Emph(s)
  return "'''" .. s .. "'''"
end

-- edit
function Strong(s)
  return "''" .. s .. "''"
end

-- remove subscript

-- remove superscript

-- remove smallcaps

-- edit
function Strikeout(s)
  return '%%' .. s .. '%%'
end

-- edit
function Link(s, src, tit, attr)
  return "[[" .. escape(s,true) .. ":" .. escape(src,true) .. "]]"
end

-- edit
function Image(s, src, tit, attr)
  return "#ref('" .. escape(s,true) .. "'," .. escape(tit,true) .. ");"
end

-- edit
function Code(s, attr)
  return "" .. attributes(attr) .. "" .. escape(s) .. "\n"
end

-- remove InlineMath

-- remove DisplayMath

-- edit
function Note(s)
  return "((" .. s .. "))"
end

-- edit
function Span(s, attr)
  return "" .. attributes(attr) .. "" .. s .. ""
end

-- remove RawInline

-- remove Cite

function Plain(s)
  return s
end

function Para(s)
  return "" .. s .. ""
end

-- lev is an integer, the header level.
function Header(lev, s, attr)
  local buffer = {}
  for i = 1,lev do
    table.insert(buffer, "*")
  end
  local attrs = table.concat(attr, "")
  return table.concat(buffer, "") .. attrs .. " " .. s
end

function BlockQuote(s)
  return "{code}\n" .. s .. "\n{/code}"
end

function HorizontalRule()
  return "----"
end

-- remove LineBlock

-- edit
function CodeBlock(s, attr)
  return "{code}\n" .. s .. "\n{/code}"
end

-- edit
function BulletList(items)
  local buffer = {}
  for _, item in pairs(items) do
    table.insert(buffer, "-" .. item)
  end
  return table.concat(buffer, "\n")
end

-- edit
function OrderedList(items)
  local buffer = {}
  for _, item in pairs(items) do
    table.insert(buffer, "+" .. item)
  end
  return table.concat(buffer, "\n")
end

-- Revisit association list STackValue instance.
-- edit
function DefinitionList(items)
  local buffer = {}
  for _,item in pairs(items) do
    for k, v in pairs(item) do
      table.insert(buffer,
                   ":" .. k .. "|" ..
                   table.concat(v, "")
                    .. "\n")
    end
  end
  return table.concat(buffer, "\n")
end

-- remove Align

-- edit CaptionedImage
function CaptionedImage(src, tit, caption)
   return '#ref(' .. escape(src,true) .. ');'
end

-- edit
-- Caption is a string, aligns is an array of strings,
-- widths is an array of floats, headers is an array of
-- strings, rows is an array of arrays of strings.
function Table(caption, aligns, widths, headers, rows)
  local buffer = {}
  local function add(s)
    table.insert(buffer, s)
  end
  if caption ~= "" then
    add(caption)
  end
  local header_row = {}
  local empty_header = true
  for i, h in pairs(headers) do
    table.insert(header_row, h)
    empty_header = empty_header and h == ""
  end
  if empty_header then
    head = ""
  else
    head = "|" .. table.concat(header_row, "|") .. "|h"
  end
  add(head)
  for _, row in pairs(rows) do
    local rows = {}
    for i,c in pairs(row) do
      table.insert(rows, c)
    end
    add("|" .. table.concat(rows, "|") .. "|")
  end
  return table.concat(buffer,'\n')
end

-- remove RawBlock

function Div(s, attr)
  return s
end

-- The following code will produce runtime warnings when you haven't defined
-- all of the functions you need for the custom writer, so it's useful
-- to include when you're working on a writer.
local meta = {}
meta.__index =
  function(_, key)
    io.stderr:write(string.format("WARNING: Undefined function '%s'\n",key))
    return function() return "" end
  end
setmetatable(_G, meta)

