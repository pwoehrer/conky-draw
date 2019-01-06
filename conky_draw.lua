--[[
    conky-draw.lua

   Peter Wöhrer
   2018-12-27
]]

require 'cairo'
require 'conky_draw_config'


local function division_by_zero(variable_table)
  -- handle division by zero from some user configuration
  for k, v in pairs(variable_table) do
    if v == 0 then
      error("The value of '" .. k .. "' must be non-zero as it is used as divisor.", 2)
    end
  end
end


local function sign(value)
  -- return the sign of value
  if type(value) ~= 'number' then
    error("Error: '" .. "' is not a number!", 2)
  end

  if value == 0 then
    return 1
  else
    return (value / math.abs(value))
  end
end


local function hexa_to_rgb(color, alpha)
  return
    ((color / 0x10000) % 0x100) / 255,
    ((color / 0x100) % 0x100) / 255,
    (color % 0x100) / 255,
    alpha
end


local function get_conky_value(conky_value, requires_number)
  -- evaluate a conky template to get its current value
  -- example: "cpu cpu0" --> 20

  local value = conky_parse(string.format('${%s}', conky_value))

  if requires_number then
    if not type(value) == 'number' then
      error(
        "A value of type 'number' is required, but a value of type '" ..
          type(value) .. "' has been provided.")
    else
      value = tonumber(value)
    end
  end

  return value or 0
end


local function get_critical_or_not_suffix (value, threshold, change_color_on_critical,
  change_alpha_on_critical, change_thickness_on_critical)
  local result = {
    color = '',
    alpha = '',
    thickness = ''
  }
  local suffix = "_critical"

  if value >= threshold then
    if change_color_on_critical then
      result.color = suffix
    end

    if change_alpha_on_critical then
      result.alpha = suffix
    end

    if change_thickness_on_critical then
      result.thickness = suffix
    end
  end
  return result
end


local function draw_text(display, element)
  -- draw a string

  -- define the function to get the extents of the string
  local extents = cairo_text_extents_t:create()
  tolua.takeownership(extents)

  -- save cairo canvas
  cairo_save(display)

  -- set font appearance
  local font_slant
  local font_face

  if element.italic then
    font_slant = CAIRO_FONT_SLANT_ITALIC
  else
    font_slant = CAIRO_FONT_SLANT_NORMAL
  end

  if element.bold then
    font_face = CAIRO_FONT_WEIGHT_BOLD
  else
    font_face = CAIRO_FONT_WEIGHT_NORMAL
  end

  cairo_select_font_face(display, element.font, font_slant, font_face)
  cairo_set_font_size(display, element.font_size)
  cairo_set_source_rgba(display, hexa_to_rgb(element.color, element.alpha))

  -- prepare content of element
  local str
  if element.conky_value then
    str = get_conky_value(element.conky_value, false)
  elseif element.text then
    str = element.text
  else
    error("Either 'conky_value' or 'text' must be present in the configuration of a 'draw_text' element!")
    str = "NIL"
  end

  str = element.prefix .. str .. element.suffix

  -- prepare element positioning
  cairo_text_extents(display, str, extents)

  local offset_x, offset_y
  if element.alignment.vertical == 'bottom' then
    offset_y = 0
  elseif element.alignment.vertical == 'middle' then
    offset_y = extents.height / 2
  else
    -- if the setting is neither top, middle, or bottom default to top and print a warning
    offset_y = extents.height
    -- print("Warning: The vertical alignment value was '" .. (element.alignment.vertical or 'nil') ..
    --    "'. It has to be one of 'top', 'middle', or 'bottom'. The default of 'top' is used.")
  end

  if element.alignment.horizontal == 'right' then
    offset_x = -extents.width
  elseif element.alignment.horizontal == 'center' then
    offset_x = -extents.width / 2
  else
    -- if the setting is neither left, center, or right default to left and print a warning
    offset_x = 0
    -- print("Warning: The horizontal alignment value was '" .. (element.alignment.horizontal or 'nil') ..
    --    "'. It has to be one of 'left', 'center', or 'right'. The default of 'left' is used.")
  end

  if element.rotation_angle then
    -- rotation
    local angle = element.rotation_angle * (math.pi / 180)
    cairo_rotate(display, angle)
    cairo_move_to(
      display,
      element.from.x * math.cos(-angle) - element.from.y * math.sin(-angle) + offset_x,
      element.from.y * math.cos(-angle) + element.from.x * math.sin(-angle) + offset_y
    )
  else
    -- simple translation
    cairo_move_to(
      display,
      element.from.x + offset_x,
      element.from.y + offset_y
    )
  end

  -- display element
  cairo_show_text(display, str)
  cairo_stroke(display)

  -- restore cairo canvas
  cairo_restore(display)
end


local function draw_line(display, element)
  -- draw a line

  -- deltas for x and y (cairo expects a point and deltas for both axis)
  local x_side = element.to.x - element.from.x  -- not abs! because they are deltas
  local y_side = element.to.y - element.from.y  -- and the same here
  local from_x = element.from.x
  local from_y = element.from.y
  local length = math.sqrt(x_side * x_side + y_side * y_side)

  -- draw line
  division_by_zero({
    number_graduation = element.number_graduation
  })

  cairo_set_source_rgba(display, hexa_to_rgb(element.color, element.alpha))
  cairo_set_line_width(display, element.thickness)

  -- calculate x and y component of space_between_graduations
  local space_between_grad_x = element.space_between_graduation * (x_side / length)
  local space_between_grad_y = element.space_between_graduation * (y_side / length)

  -- calculate x and y component of graduation, compensating for one less space than number graduations
  local graduation_x = (space_between_grad_x + x_side) / element.number_graduation - space_between_grad_x
  local graduation_y = (space_between_grad_y + y_side) / element.number_graduation - space_between_grad_y

   -- move to start of line
  cairo_move_to(display, from_x, from_y)

  for _ = 1, math.floor(element.number_graduation + 0.5) do
    -- draw first graduation
    cairo_rel_line_to(display, graduation_x, graduation_y)

    -- move to start of next graduation
    from_x = from_x + graduation_x + space_between_grad_x
    from_y = from_y + graduation_y + space_between_grad_y
    cairo_move_to(display, from_x, from_y)
  end

  cairo_stroke(display)
end


local function draw_bar_graph(display, element)
  -- draw a bar graph

  division_by_zero({max_value = element.max_value})

  -- get current value
  local value = get_conky_value(element.conky_value, true)

  if value > element.max_value then
    value = element.max_value
  end

  -- dimensions of the full graph
  local x_side = element.to.x - element.from.x
  local y_side = element.to.y - element.from.y
  local bar_x_side = math.floor(x_side * value / element.max_value)
  local bar_y_side = math.floor(y_side * value / element.max_value)

  -- is it in critical value?
  local critical_or_not_suffix = get_critical_or_not_suffix (
    value,
    element.critical_threshold,
    element.change_color_on_critical,
    element.change_alpha_on_critical,
    element.change_thickness_on_critical
  )

  -- derive sensible defaults for background from elements settings
  local color = element['background_color' .. critical_or_not_suffix.color] or
      element['color' .. critical_or_not_suffix.color]
  local alpha = element['background_alpha' .. critical_or_not_suffix.alpha] or
      element['alpha' .. critical_or_not_suffix.alpha] / 5
  local thickness = element['background_thickness' .. critical_or_not_suffix.thickness] or
      element['thickness' .. critical_or_not_suffix.thickness]

  -- background line (full graph)
  local background_line = {
    from = element.from,
    to = element.to,

    color = color,
    alpha = alpha,
    thickness = thickness,

    number_graduation = element.number_graduation,
    space_between_graduation = element.space_between_graduation,
  }

  -- draw background lines
  draw_line(display, background_line)

  -- draw bar line
  -- reuse common settings from background_line
  local bar_line = background_line
  bar_line.from = element.from
  bar_line.to = {x = element.from.x + bar_x_side, y = element.from.y + bar_y_side}
  bar_line.number_graduation = math.max(element.number_graduation * (value / element.max_value), 1)

  bar_line.color = element['color' .. critical_or_not_suffix.color]
  bar_line.alpha = element['alpha' .. critical_or_not_suffix.alpha]
  bar_line.thickness = element['thickness' .. critical_or_not_suffix.thickness]

  draw_line(display, bar_line)
end


local function draw_ring(display, element)
  -- draw a ring or ellipse

  -- handle different types of radii
  local radius
  if type(element.radius) == "table" then
    radius = {
      a = element.radius.a or element.radius[1], -- This handles the case when no keys are specified.
      b = element.radius.b or element.radius[2]
    }
  else
    radius = {
      a = element.radius,
      b = element.radius
    }
  end

  -- the user types degrees, but we need radians
  local start_angle, end_angle = math.rad(element.start_angle), math.rad(element.end_angle)

  -- direction of the ring changes the function we must call
  local length = end_angle - start_angle

  local arc_drawer = cairo_arc

  if length < 0 then
    arc_drawer = cairo_arc_negative
  end

  cairo_set_source_rgba(display, hexa_to_rgb(element.color, element.alpha))
  cairo_set_line_width(display, element.thickness)

  local ratio = radius.b / radius.a

  division_by_zero({number_graduation = element.number_graduation})

  -- I am considering ditching this for the ability to define negative space between graduations.
  -- Probably useful for effects playing with alpha.
  local rad_between_graduation = math.rad(element.space_between_graduation) * sign(length)
  local graduation_size = length / element.number_graduation - rad_between_graduation
  local current_start = start_angle

  -- round to the nearest graduation
  for _ = 1, math.floor(element.number_graduation + 0.5) do
    cairo_save(display)
    cairo_scale(display, 1, ratio)

    arc_drawer(
      display,
      element.center.x,
      element.center.y / ratio,
      radius.a,
      current_start,
      current_start + graduation_size
    )

    current_start = current_start + graduation_size + rad_between_graduation

    cairo_restore(display)
    cairo_stroke(display)
  end
end


local function draw_ring_graph(display, element)
  -- draw a ring graph

  division_by_zero({max_value = element.max_value})

  -- get current value
  local value = get_conky_value(element.conky_value, true)

  if value > element.max_value then
    value = element.max_value
  end

  -- dimensions of the full graph
  local degrees = element.end_angle - element.start_angle

  -- dimensions of the value bar
  local bar_degrees = value * (degrees / element.max_value)

  -- is it in critical value?
  local critical_or_not_suffix = get_critical_or_not_suffix (
    value,
    element.critical_threshold,
    element.change_color_on_critical,
    element.change_alpha_on_critical,
    element.change_thickness_on_critical
  )

  -- background ring
  -- derive sensible defaults for background from bar values
  local color = element['background_color' .. critical_or_not_suffix.color] or
      element['color' .. critical_or_not_suffix.color]
  local alpha = element['background_alpha' .. critical_or_not_suffix.alpha] or
      element['alpha' .. critical_or_not_suffix.alpha] / 5
  local thickness = element['background_thickness' .. critical_or_not_suffix.thickness] or
      element['thickness' .. critical_or_not_suffix.thickness]

  local background_ring = {
    center = element.center,
    radius = element.radius,

    start_angle = element.start_angle,
    end_angle = element.end_angle,

    number_graduation = element.number_graduation,
    space_between_graduation = element.space_between_graduation,

    color = color,
    alpha = alpha,
    thickness = thickness,
  }
  draw_ring(display, background_ring)

  -- bar ring (reusing settings of background_ring)
  local bar_ring = background_ring
  bar_ring.end_angle = element.start_angle + bar_degrees
  bar_ring.number_graduation = math.max(element.number_graduation * (bar_degrees / degrees), 1)

  bar_ring.color = element['color' .. critical_or_not_suffix.color]
  bar_ring.alpha = element['alpha' .. critical_or_not_suffix.alpha]
  bar_ring.thickness = element['thickness' .. critical_or_not_suffix.thickness]

  draw_ring(display, bar_ring)

  -- draw text in the center of the circle
  if element.text then
    local text = defaults.text
    text.font_size = 18
    text.from = {
      x = element.center.x,
      y = element.center.y
    }
    text.color = element['color' .. critical_or_not_suffix.color]
    text.alpha = element['alpha' .. critical_or_not_suffix.alpha]
    text.bold = element.text_bold or false
    text.text = value
    text.suffix = element.suffix or text.suffix
    text.prefix = element.prefix or text.prefix
    text.alignment = {
      vertical = 'middle',
      horizontal = 'center'
    }
    draw_text(display, text)
  end
end


-- properties that the user *must* define, because they don't have default
-- values
local requirements = {
  line = {'from', 'to'},
  bar_graph = {'from', 'to', 'conky_value', 'max_value'},
  ring = {'center', 'radius'},
  ring_graph = {'center', 'radius', 'conky_value'},
  text = {'from', },
  clock = {},
}


local function check_requirements(elements)
  -- check every element has the required properties
  for _, element in pairs(elements) do
    -- find the requirements for that element kind
    local kind_requirements = requirements[element.kind]
    -- if there are defined requirements for that element kind

    if  kind_requirements ~= nil then
      -- check all of them are defined by the user

      for _, property in pairs(kind_requirements) do
        if element[property] == nil then
          error('You defined a ' .. element.kind .. ' without specifying its "' .. property .. '" value')
        end
      end
    else
      -- we don't know which properties has to have, BUT, it always needs
      -- a draw_function
      if element.draw_function == nil then
        error('You defined a ' .. element.kind .. ', which is an unknown element kind to me. ' ..
            'Was it a typo? or are you trying to define a custom element kind but forgot to ' ..
            'define its draw_function?')
      end
    end
  end
end

-- Default values for properties that can have a default value
local function join_defaults(...)
  local new = {}

  for _, v in pairs({...}) do
    for kk, vv in pairs(v) do
      new[kk] = vv
    end
  end

  return new
end


local color_defaults = {
  color = 0x00FF6E,
  alpha = 1.0,
}

local base_defaults = {
  thickness = 5,
  number_graduation = 1,
  space_between_graduation = 0,
}

local bar_defaults = {
  max_value = 100,
  min_value = 0,
  critical_threshold = 90,
  change_color_on_critical = true,
  change_alpha_on_critical = false,
  change_thickness_on_critical = false,
  color_critical = 0xF00000,
  alpha_critical = 1.0,
  thickness_critical = 5,
}

defaults = {
  bar_graph = join_defaults(
    color_defaults,
    base_defaults,
    bar_defaults, {
      draw_function = draw_bar_graph,
    }
  ),
  ring_graph = join_defaults(
    color_defaults,
    base_defaults,
    bar_defaults, {
      text = false,
      text_suffix = '',
      text_bold = true,

      draw_function = draw_ring_graph,
    }
  ),
  line = join_defaults(
    color_defaults,
    base_defaults, {
      draw_function = draw_line,
    }
  ),
  ring = join_defaults(
    color_defaults,
    base_defaults, {
      start_angle = 0,
      end_angle = 360,

      draw_function = draw_ring,
    }
  ),
  text = join_defaults(
    color_defaults, {
      rotation_angle = 0,
      alignment = {
        vertical = 'top',
        horizontal = 'left'
      },

      font = 'Noto Sans',
      font_size = 12,
      bold = false,
      italic = false,

      prefix = '',
      suffix = '',

      draw_function = draw_text,
    }
  ),
}


local function set_defaults(element)
  -- works on global variable element, so tehre is no need to return element
  local kind_defaults = defaults[element.kind]

  if kind_defaults ~= nil then
    for key, value in pairs(kind_defaults) do
      element[key] = element[key] or value
    end
  end

  return element
end


function conky_main()
  if conky_window == nil then
    return
  end

  check_requirements(elements)

  local surface = cairo_xlib_surface_create(
    conky_window.display,
    conky_window.drawable,
    conky_window.visual,
    conky_window.width,
    conky_window.height
  )

  local display = cairo_create(surface)

  if tonumber(conky_parse('${updates}')) > 3 then

    for _, element in pairs(elements) do
      element = set_defaults(element)
      element.draw_function(display, element)
    end
  end

  cairo_surface_destroy(surface)
end
