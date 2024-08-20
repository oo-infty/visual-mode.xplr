---@diagnostic disable
local xplr = xplr
---@diagnostic enable

-- Global state of visual mode
local state = nil
local start_index = nil
local bounded_index = nil

-- Helper functions
local function get_previous_index(app)
  if app.directory_buffer.total == 0 then
    return nil
  end

  local index = app.directory_buffer.focus

  if index == 0 then
    if bounded_index then
      return nil
    else
      return app.directory_buffer.total - 1
    end
  else
    return index - 1
  end
end

local function get_next_index(app)
  if app.directory_buffer.total == 0 then
    return nil
  end

  local index = app.directory_buffer.focus

  if index == app.directory_buffer.total - 1 then
    if bounded_index then
      return nil
    else
      return 0
    end
  else
    return index + 1
  end
end

-- Exported functions
xplr.fn.custom.visual_mode_init = function(app)
  state = "init"
  start_index = app.directory_buffer.focus
  bounded_index = xplr.config.general.enforce_bounded_index_navigation

  return {
    "ToggleSelection",
    { SwitchModeCustom = "visual" },
  }
end

xplr.fn.custom.visual_mode_exit = function(_)
  state = nil
  start_index = nil
  bounded_index = nil

  return {
    "PopMode",
  }
end

xplr.fn.custom.visual_mode_up = function(app)
  -- Do nothing when there is no node in directory.
  if app.directory_buffer.total == 0 then
    return {}
  end

  local new_index = get_previous_index(app)

  -- Do nothing when can't move focus up.
  if new_index == nil then
    return {}
  end

  if state == "init" then
    if app.directory_buffer.total == 1 then
      -- Don't move focus when there is only one entry.
      return {}
    else
      state = "up_extending"
      return {
        "FocusPrevious",
        "ToggleSelection",
      }
    end
  elseif state == "up_extending" then
    if new_index == start_index then
      -- Will reach the start position and cover the whole buffer.
      -- (xplr.config.general.enforce_bounded_index_navigation = false)
      state = "up_collapsing"
      start_index = app.directory_buffer.focus

      return {
        "FocusPrevious"
      }
    else
      return {
        "FocusPrevious",
        "ToggleSelection",
      }
    end
  elseif state == "up_collapsing" then
    -- Will reach the start position
    if new_index == start_index then
      state = "init"
    end

    return {
      "ToggleSelection",
      "FocusPrevious",
    }
  elseif state == "down_extending" then
    -- Will reach the start position
    if new_index == start_index then
      state = "init"
    else
      state = "up_collapsing"
    end

    return {
      "ToggleSelection",
      "FocusPrevious",
    }
  elseif state == "down_collapsing" then
    state = "up_extending"
    return {
      "FocusPrevious",
      "ToggleSelection",
    }
  else
    return {
      { LogError = "Unknown state: " .. state },
    }
  end
end

xplr.fn.custom.visual_mode_down = function(app)
  -- Do nothing when there is no node in directory.
  if app.directory_buffer.total == 0 then
    return {}
  end

  local new_index = get_next_index(app)

  -- Do nothing when can't move focus up.
  if new_index == nil then
    return {}
  end

  if state == "init" then
    if app.directory_buffer.total == 1 then
      -- Don't move focus when there is only one entry
      return {}
    else
      state = "down_extending"
      return {
        "FocusNext",
        "ToggleSelection",
      }
    end
  elseif state == "down_extending" then
    if new_index == start_index then
      -- Will reach the start position and cover the whole buffer.
      -- (xplr.config.general.enforce_bounded_index_navigation = false)
      state = "down_collapsing"
      start_index = app.directory_buffer.focus

      return {
        "FocusNext"
      }
    else
      return {
        "FocusNext",
        "ToggleSelection",
      }
    end
  elseif state == "down_collapsing" then
    -- Will reach the start position
    if new_index == start_index then
      state = "init"
    end

    return {
      "ToggleSelection",
      "FocusNext",
    }
  elseif state == "up_extending" then
    -- Will reach the start position
    if new_index == start_index then
      state = "init"
    else
      state = "down_collapsing"
    end

    return {
      "ToggleSelection",
      "FocusNext",
    }
  elseif state == "up_collapsing" then
    state = "down_extending"
    return {
      "FocusNext",
      "ToggleSelection",
    }
  else
    return {
      { LogError = "Unknown state: " .. state },
    }
  end
end

local function setup(args)
  args = args or {}
  args.exit_visual_key = args.exit_visual_key or args.visual_key
  args.up_keys = args.up_keys or {}
  args.down_keys = args.down_keys or {}
  args.extra_keys = args.extra_keys or {}

  -- Set up keybind for entering visual mode
  if args.visual_key then
    xplr.config.modes.builtin.default.key_bindings.on_key[args.visual_key] = {
      help = "visual",
      messages = {
        { CallLuaSilently = "custom.visual_mode_init" },
      },
    }
  end

  -- Set up visual mode
  xplr.config.modes.custom.visual = {
    name = "visual",
    key_bindings = {
      on_key = {},
    }
  }

  local visual_mode = xplr.config.modes.custom.visual

  if args.exit_visual_key then 
    visual_mode.key_bindings.on_key[args.exit_visual_key] = {
      help = "exit visual mode",
      messages = {
        { CallLuaSilently = "custom.visual_mode_exit" },
      },
    }
  end

  for _, up_key in ipairs(args.up_keys) do
    visual_mode.key_bindings.on_key[up_key] = {
      help = "up",
      messages = {
        { CallLuaSilently = "custom.visual_mode_up" },
      },
    }
  end

  for _, down_key in ipairs(args.down_keys) do
    visual_mode.key_bindings.on_key[down_key] = {
      help = "down",
      messages = {
        { CallLuaSilently = "custom.visual_mode_down" },
      },
    }
  end

  for key, operation in pairs(args.extra_keys) do
    visual_mode.key_bindings.on_key[key] = operation
  end
end

return { setup = setup }
