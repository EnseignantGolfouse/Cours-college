local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local math = _tl_compat and _tl_compat.math or math; local TeX = {}







local Point = {}





local Vector = {}




function Vector.new(from, to)
   local self = setmetatable({}, { __index = Vector })
   self.x = (to.x - from.x) or 0
   self.y = (to.y - from.y) or 0
   return self
end

function Vector.from_angle_length(angle, length)
   local x = math.cos(angle) * length
   local y = math.sin(angle) * length
   local self = setmetatable({}, { __index = Vector })
   self.x = x or 0
   self.y = y or 0
   return self
end

function Vector:length()
   return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector:angle()
   local length = self:length()
   local angle = math.acos(self.x / length)
   if self.y < 0 then angle = 2 * math.pi - angle end
   return angle
end

function Vector:apply(point)
   return {
      x = point.x + self.x,
      y = point.y + self.y,
   }
end

local Axis = {}






function tikz_draw_points(points, draw_args)
   if points[2] == nil then return end
   tex.print("\\draw")
   if draw_args then
      tex.print("[", draw_args, "]")
   end
   for i, point in ipairs(points) do
      if i ~= 1 then
         tex.print(" -- ")
      end
      tex.print("(", point.x, ",", point.y, ")")
   end
   tex.print(";")
end



function draw_axis(axis, anchor)
   tex.print("\\draw[color=red] ")
   tex.print("(", axis.p1.x, ",", axis.p1.y, ")")
   tex.print(" -- ")
   if type(anchor) == "string" then
      tex.print("node[anchor=")
      tex.print(anchor)
      tex.print("]{Axe de symétrie} ")
   end
   tex.print("(", axis.p2.x, ",", axis.p2.y, ")")
   tex.print(";")
end


function draw_center(center, anchor)
   tex.print("\\filldraw[red] (")
   tex.print(center.x)
   tex.print(",")
   tex.print(center.y)
   tex.print(") circle (2pt) node[anchor=")
   tex.print(anchor)
   tex.print("]{Centre de symétrie}")
   tex.print(";")
end




function symetrie_axiale(axis, points)
   local axis_vector = Vector.new(axis.p1, axis.p2)
   local angle = axis_vector:angle()
   local symetrized_points = {}
   for index, point in ipairs(points) do
      local axisp1_to_point = Vector.new(axis.p1, point)
      local symetrized_angle = 2 * angle - axisp1_to_point:angle()
      local axisp1_to_symetric = Vector.from_angle_length(symetrized_angle, axisp1_to_point:length())
      local symetrized_point = axisp1_to_symetric:apply(axis.p1)
      symetrized_points[index] = symetrized_point
   end
   return symetrized_points
end




function symetrie_centrale(center, points)
   local symetrized_points = {}
   for index, point in ipairs(points) do
      local point_to_center = Vector.new(point, center)
      local symetric_point = point_to_center:apply(center)
      symetrized_points[index] = symetric_point
   end
   return symetrized_points
end
