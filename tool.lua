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

function Tool.Volume( state, cell )
	volume.state = state
	if state == e_volume_state.started then
		volume.start_cell:set( cell )
	end

	if state == e_volume_state.dragging then
		local max_x = math.max( volume.start_cell.x, cursor.cell.x )
		local min_x = math.min( volume.start_cell.x, cursor.cell.x )
		local max_y = math.max( volume.start_cell.y, cursor.cell.y )
		local min_y = math.min( volume.start_cell.y, cursor.cell.y )
		local max_z = math.max( volume.start_cell.z, cursor.cell.z )
		local min_z = math.min( volume.start_cell.z, cursor.cell.z )

		local span_x = max_x - min_x
		local span_y = max_y - min_y
		local span_z = max_z - min_z

		volume.x = (((min_x + max_x) * unit) / 2) + (unit / 2)
		volume.y = (((min_y + max_y) * unit) / 2) + (unit / 2)
		volume.z = (((min_z + max_z) * unit) / 2) + (unit / 2)
		volume.w = (span_x + 1) * unit
		volume.h = (span_y + 1) * unit
		volume.d = (span_z + 1) * unit
	end

	if state == e_volume_state.finished then
		local start_cell_x = (volume.x - (volume.w / 2)) / unit
		local start_cell_y = (volume.y - (volume.h / 2)) / unit
		local start_cell_z = (volume.z - (volume.d / 2)) / unit
		local end_cell_x = start_cell_x + (volume.w / unit) - 1
		local end_cell_y = start_cell_y + (volume.h / unit) - 1
		local end_cell_z = start_cell_z + (volume.d / unit) - 1

		print( start_cell_x, end_cell_x, volume.x, volume.w )

		local temp = {}
		for xx = start_cell_x, end_cell_x, 1 do
			for yy = start_cell_y, end_cell_y, 1 do
				for zz = start_cell_z, end_cell_z, 1 do
					local t = {
						x = (xx * unit) + (unit / 2),
						y = (yy * unit) + (unit / 2),
						z = (zz * unit) + (unit / 2),
						cell_x = xx,
						cell_y = yy,
						cell_z = zz,
						r = cur_color[ 1 ],
						g = cur_color[ 2 ],
						b = cur_color[ 3 ]
					}
					table.insert( temp, t )
				end
			end
		end

		for i, v in ipairs( temp ) do
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
	end
end

function Tool.Append( insert )
	if insert then
		for i, v in ipairs( append ) do
			table.insert( collection, append[ i ] )
		end
		lovr.graphics.wait()
	else
		if interaction_enabled then
			append = {}
		else
			append = {}
			for i, v in ipairs( append_preview ) do
				local t = {
					x = (v.x + cursor.center.x) - unit / 2,
					y = (v.y + cursor.center.y) - unit / 2,
					z = (v.z + cursor.center.z) - unit / 2,
					cell_x = v.cell_x + cursor.cell.x,
					cell_y = v.cell_y + cursor.cell.y,
					cell_z = v.cell_z + cursor.cell.z,
					r = v.r,
					g = v.g,
					b = v.b
				}
				table.insert( append, t )
			end
		end
	end
end

return Tool
