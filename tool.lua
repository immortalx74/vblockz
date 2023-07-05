require "globals"

local Tool = {}

function Tool.Draw()
	local t = {
		x = cursor.center.x,
		y = cursor.center.y,
		z = cursor.center.z,
		cell_x = cursor.cell.x,
		cell_y = cursor.cell.y,
		cell_z = cursor.cell.z,
		r = cur_color[ 1 ],
		g = cur_color[ 2 ],
		b = cur_color[ 3 ]
	}

	local free = true
	for i, v in ipairs( collection ) do
		if cursor.cell.x == v.cell_x and cursor.cell.y == v.cell_y and cursor.cell.z == v.cell_z then
			free = false
			break
		end
	end

	if free then
		table.insert( collection, t )
	end
end

function Tool.Erase()
	local count = #collection

	for i = count, 1, -1 do
		if cursor.cell.x == collection[ i ].cell_x and cursor.cell.y == collection[ i ].cell_y and cursor.cell.z == collection[ i ].cell_z then
			table.remove( collection, i )
			print( i )
		end
	end
end

function Tool.Paint()
	for i, v in ipairs( collection ) do
		if cursor.cell.x == v.cell_x and cursor.cell.y == v.cell_y and cursor.cell.z == v.cell_z then
			v.r = cur_color[ 1 ]
			v.g = cur_color[ 2 ]
			v.b = cur_color[ 3 ]
		end
	end
end

function Tool.EyeDropper()
	for i, v in ipairs( collection ) do
		if cursor.cell.x == v.cell_x and cursor.cell.y == v.cell_y and cursor.cell.z == v.cell_z then
			cur_color[ 1 ] = v.r
			cur_color[ 2 ] = v.g
			cur_color[ 3 ] = v.b
		end
	end
end

return Tool
