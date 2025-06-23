local utils = require('pandoc.utils')

-- Simple function to escape JSON strings
local function json_escape(str)
  str = str:gsub('\\', '\\\\')
  str = str:gsub('"', '\\"')
  str = str:gsub('\n', '\\n')
  str = str:gsub('\r', '\\r')
  return str
end

function Pandoc(doc)
  local meta = doc.meta

  local function get_string(field)
    if meta[field] then
      return utils.stringify(meta[field])
    else
      return ""
    end
  end

  local title = get_string('title')
  local description = get_string('description')
  local alt = get_string('alt')

  local image = ""
  if meta.image then
    local img = meta.image
    if img.t == 'Str' or img.t == 'Plain' or img.t == 'Para' then
      image = utils.stringify(img)
    elseif img.t == 'Image' then
      image = img.src or ""
    else
      image = utils.stringify(img)
    end
  end

  -- Output JSON manually:
  print('{')
  print('  "title": "' .. json_escape(title) .. '",')
  print('  "description": "' .. json_escape(description) .. '",')
  print('  "alt": "' .. json_escape(alt) .. '",')
  print('  "image": "' .. json_escape(image) .. '"')
  print('}')
  os.exit()
end
