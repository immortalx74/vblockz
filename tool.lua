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

function Tool.Volume( finished )
	if finished then
		-- store here
		for i, v in ipairs( volume.temp_storage ) do
			local free = true

			for j, k in ipairs( collection ) do
				if v.cell_x == k.cell_x and v.cell_y == k.cell_y and v.cell_z == k.cell_z then
					free = false
					break
				end
			end

			if free then
				table.insert( collection, v )
			end
		end
		volume.temp_storage = {}
		volume.start_cell:set( 0, 0, 0 )
	else
		local max_x = math.max( volume.start_cell.x, cursor.cell.x )
		local min_x = math.min( volume.start_cell.x, cursor.cell.x )
		local max_y = math.max( volume.start_cell.y, cursor.cell.y )
		local min_y = math.min( volume.start_cell.y, cursor.cell.y )
		local max_z = math.max( volume.start_cell.z, cursor.cell.z )
		local min_z = math.min( volume.start_cell.z, cursor.cell.z )

		local span_x = max_x - min_x
		local span_y = max_y - min_y
		local span_z = max_z - min_z

		volume.temp_storage = {}

		for xx = min_x, min_x + span_x, 1 do
			for yy = min_y, min_y + span_y, 1 do
				for zz = min_z, min_z + span_z, 1 do
					local t = {
						x = xx + 0.5,
						y = yy + 0.5,
						z = zz + 0.5,
						cell_x = xx,
						cell_y = yy,
						cell_z = zz,
						r = cur_color[ 1 ],
						g = cur_color[ 2 ],
						b = cur_color[ 3 ]
					}
					table.insert( volume.temp_storage, t )
				end
			end
		end
	end
end

return Tool
