local record TeX
	print: function(...: any): ()
	sprint: function(...: any): ()
end

global tex: TeX

-- Point in a 2D space.
local record Point
	x: number
	y: number
end

-- 2D vector.
local record Vector
	x: number
	y: number
end

function Vector.new(from: Point, to: Point): Vector
	local self = setmetatable({} as Vector, { __index = Vector })
	self.x = (to.x - from.x) or 0
	self.y = (to.y - from.y) or 0
	return self
end

function Vector.from_angle_length(angle: number, length: number): Vector
	local x = math.cos(angle) * length
    local y = math.sin(angle) * length
	local self = setmetatable({} as Vector, { __index = Vector })
	self.x = x or 0
	self.y = y or 0
	return self
end

function Vector:length(): number
	return math.sqrt(self.x*self.x+self.y*self.y)
end

function Vector:angle(): number
	local length = self:length()
	local angle = math.acos(self.x / length)
    if self.y < 0 then angle = 2 * math.pi - angle end
	return angle
end

function Vector:apply(point: Point): Point
	return {
		x = point.x + self.x,
		y = point.y + self.y,
	}
end

local record Axis
	p1: Point
	p2: Point
end

-- Generate a  `\draw (x1,y1) -- (x2,y2) ... ;` tex statements, via `tex.sprint`.
-- Optionaly takes '[]' arguments for the `\draw` call.
function tikz_draw_points(points: {Point}, draw_args: string|nil)
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

-- Draw an axis in red.
-- Also writes 'Axe de symétrie' if `anchor` is specified.
function draw_axis(axis: Axis, anchor: string|nil)
    tex.print("\\draw[color=red] ")
	tex.print("(", axis.p1.x, ",", axis.p1.y, ")")
    tex.print(" -- ")
	if anchor ~= nil then
		tex.print("node[anchor=")
		tex.print(anchor)
		tex.print("]{Axe de symétrie} ")
	end
	tex.print("(", axis.p2.x, ",", axis.p2.y, ")")
	tex.print(";")
end

-- Draw a center of symmetry.
function draw_center(center: Point, anchor: string)
	tex.print("\\filldraw[red] (")
	tex.print(center.x)
	tex.print(",")
	tex.print(center.y)
	tex.print(") circle (2pt) node[anchor=")
	tex.print(anchor)
	tex.print("]{Centre de symétrie}")
	tex.print(";")
end

-- - `points`: list of points to symetrize.
-- # Returns
-- The symetrized list of `points` along `axis`.
function symetrie_axiale(axis: Axis, points: {Point}): {Point}
    local axis_vector: Vector = Vector.new(axis.p1, axis.p2)
    local angle: number = axis_vector:angle()
    local symetrized_points: {Point} = {}
	for index, point in ipairs(points) do
		local axisp1_to_point: Vector = Vector.new(axis.p1, point)
        local symetrized_angle: number = 2 * angle - axisp1_to_point:angle()
		local axisp1_to_symetric: Vector = Vector.from_angle_length(symetrized_angle, axisp1_to_point:length())
		local symetrized_point = axisp1_to_symetric:apply(axis.p1)
        symetrized_points[index] = symetrized_point
	end
    return symetrized_points
end

-- - `points`: list of points to symetrize.
-- # Returns
-- The symetrized list of `points` across `center`.
function symetrie_centrale(center: Point, points: {Point}): {Point}
    local symetrized_points: {Point} = {}
	for index, point in ipairs(points) do
		local point_to_center = Vector.new(point, center)
		local symetric_point = point_to_center:apply(center)
		symetrized_points[index] = symetric_point
	end
    return symetrized_points
end
