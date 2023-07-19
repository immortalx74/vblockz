require "globals"
local Json = require "json"

local Render = {}

function Render.Geometry( pass )
	local mdl = mdl_cube
	if wireframe then
		mdl = mdl_cube_wire
	end

	local count1 = #collection
	local count2 = #append
	local total = #collection + #append

	if total > 0 then
		pass:draw( mdl, mat4(), nil, true, total )
	end

	if volume.state == e_volume_state.dragging then
		pass:setShader()
		pass:setColor( 1, 0, 0 )
		pass:box( volume.x, volume.y, volume.z, volume.w, volume.h, volume.d )
	end
end

function Render.Grid( pass )
	if show_grid then
		pass:setShader( grid_shader )
		pass:plane( 0, 0, 0, 100, 100, -math.pi / 2, 1, 0, 0 )
	end
end

function Render.Cursor( pass )
	if not interaction_enabled and cur_tool ~= e_tool.volume then
		-- Cursor
		pass:setShader()

		if cur_tool ~= e_tool.erase then
			pass:setColor( cur_color[ 1 ], cur_color[ 2 ], cur_color[ 3 ] )
			pass:box( cursor.center.x, cursor.center.y, cursor.center.z, unit, unit, unit )
			pass:setColor( 1, 1, 1 )
			pass:box( cursor.center.x, cursor.center.y, cursor.center.z, unit, unit, unit, 0, 0, 0, 0, "line" )
		else
			pass:setColor( 1, 1, 1 )
			pass:box( cursor.center.x, cursor.center.y, cursor.center.z, unit, unit, unit )
		end

		if show_tool_label then
			pass:setColor( 1, 1, 1 )
			pass:setShader()
			local q = quat( scene.transform )
			local m = mat4( vec3( cursor.unsnapped.x, cursor.unsnapped.y, cursor.unsnapped.z ) ):rotate( q:conjugate() ):translate( 4, 0, 0 )

			pass:setColor( 0.05, 0.05, 0.05 )
			local label = mat4( m ):translate( 0, 0, -0.001 )
			local w = font:getWidth( cur_tool_label )
			pass:plane( vec3( label ), vec2( w + 0.3, 1 ), quat( label ) )
			pass:setColor( 0.6, 0.6, 0.6 )

			pass:text( cur_tool_label, m )
			pass:setColor( 0, 0, 0 )
			pass:line( cursor.center.x, cursor.center.y, cursor.center.z, vec3( m ):unpack() )
		end
	end
end

function Render.Axis( pass )
	pass:setShader()
	pass:setColor( 1, 0, 0 )
	pass:line( 0, 0, 0, 0, 5, 0 )

	pass:setColor( 0, 1, 0 )
	pass:line( 0, 0, 0, 0, 0, -5 )

	pass:setColor( 0, 0, 1 )
	pass:line( 0, 0, 0, 5, 0, 0 )
end

function Render.ReferenceModel( pass )
	if ref_model and show_ref_model then
		pass:setShader( phong_shader )
		pass:setColor( 1, 1, 1, ref_model_alpha )
		pass:draw( ref_model, 0, 0, 0, ref_model_scale )
		pass:setColor( 1, 1, 1, 1 )
	end
end

function Render.UI( pass )
	UI.NewFrame( pass )
	UI.Begin( "FirstWindow", win_transform )
	local button_bg_color = UI.GetColor( "button_bg" )

	if UI.Button( "New" ) then
		collection = {}
	end
	UI.SameLine()
	if UI.Button( "Load" ) then
		load_window_open = true
	end
	UI.SameLine()
	if UI.Button( "Save" ) then
		local voxels_out = {}
		for i, v in ipairs( collection ) do
			local t = {
				x = v.x,
				y = v.y,
				z = v.z,
				cell_x = v.cell_x,
				cell_y = v.cell_y,
				cell_z = v.cell_z,
				r = v.r,
				g = v.g,
				b = v.b
			}
			table.insert( voxels_out, t )
		end
		local out = Json.encode( voxels_out )
		if lovr.filesystem.isFused() then
			lovr.filesystem.write( export_filename .. ".vblockz", out )
		else
			local file = io.open( "models/" .. export_filename .. ".vblockz", "wb" )
			file:write( out )
			file:close()
		end
	end

	UI.SameLine()

	if UI.Button( "Append" ) then
		append_window_open = true
	end

	UI.SameLine()

	if UI.Button( "?" ) then
		help_window_open = true
	end

	UI.Label( "Instance count: " .. tostring( #collection ) )

	if cur_tool == e_tool.draw then UI.OverrideColor( "button_bg", active_tool_color ) end
	if UI.Button( "Draw" ) then
		cur_tool = e_tool.draw
	end
	UI.OverrideColor( "button_bg", button_bg_color )

	UI.SameLine()
	if cur_tool == e_tool.erase then UI.OverrideColor( "button_bg", active_tool_color ) end
	if UI.Button( "Erase" ) then
		cur_tool = e_tool.erase
	end
	UI.OverrideColor( "button_bg", button_bg_color )

	UI.SameLine()
	if cur_tool == e_tool.paint then UI.OverrideColor( "button_bg", active_tool_color ) end
	if UI.Button( "Paint" ) then
		cur_tool = e_tool.paint
	end
	UI.OverrideColor( "button_bg", button_bg_color )

	UI.SameLine()
	if cur_tool == e_tool.eydropper then UI.OverrideColor( "button_bg", active_tool_color ) end
	if UI.Button( "EyeDropper" ) then
		cur_tool = e_tool.eydropper
	end
	UI.OverrideColor( "button_bg", button_bg_color )

	UI.SameLine()
	if cur_tool == e_tool.volume then UI.OverrideColor( "button_bg", active_tool_color ) end
	if UI.Button( "Volume" ) then
		cur_tool = e_tool.volume
	end
	UI.OverrideColor( "button_bg", button_bg_color )

	local ps, clicked, down, released, hovered, lx, ly = UI.WhiteBoard( "WhiteBoard1", 220, 220 )
	ps:setColor( cur_color[ 1 ], cur_color[ 2 ], cur_color[ 3 ] )
	ps:fill()
	UI.SameLine()


	local _
	_, cur_color[ 1 ] = UI.SliderFloat( "R", cur_color[ 1 ], 0, 1, 600, 3 )
	UI.SameColumn()
	_, cur_color[ 2 ] = UI.SliderFloat( "G", cur_color[ 2 ], 0, 1, 600, 3 )
	UI.SameColumn()
	_, cur_color[ 3 ] = UI.SliderFloat( "B", cur_color[ 3 ], 0, 1, 600, 3 )

	local ps, clicked, down, released, hovered, lx, ly = UI.WhiteBoard( "color_samplee", 852, 551 )
	ps:setColor( 1, 1, 1 )
	ps:setMaterial( tex_color_spectrum )
	ps:fill()
	if down then
		local r, g, b, a = img_color_spectrum:getPixel( lx, ly )
		cur_color = { r, g, b }
	end


	if UI.CheckBox( "wireframe", wireframe ) then
		wireframe = not wireframe
	end
	if UI.CheckBox( "Show reference model", show_ref_model ) then
		show_ref_model = not show_ref_model
	end
	if UI.CheckBox( "Show tool label", show_tool_label ) then
		show_tool_label = not show_tool_label
	end
	if UI.CheckBox( "Show grid", show_grid ) then
		show_grid = not show_grid
	end

	if UI.Button( "Load reference model..." ) then
		ref_model_load_window_open = true
	end

	local _
	_, ref_model_alpha = UI.SliderFloat( "Reference model alpha", ref_model_alpha, 0, 1, 840, 3 )
	_, ref_model_scale = UI.SliderFloat( "Reference model scale", ref_model_scale, 0, 100, 840, 3 )

	local _, _, _, buf = UI.TextBox( "filename", 21, export_filename )
	export_filename = buf
	UI.SameLine()
	if UI.Button( "Export obj" ) then
		if #collection > 0 then
			OBJ.Save( export_filename )
		end

		file_exported_window_open = true
	end

	UI.End( pass )

	-- Help modal window
	if help_window_open then
		local m = mat4( win_transform ):translate( 0, 0, 0.01 )
		UI.Begin( "help", m, true )
		UI.Label( "A:          Toggle Draw/Erase tool", true )
		UI.Label( "B:          Toggle Paint/EyeDropper tool", true )
		UI.Label( "X:          Toggle ref model", true )
		UI.Label( "Y:          Toggle wireframe", true )
		UI.Label( "L Thumb:    Toggle UI interaction", true )
		UI.Label( "R Trigger:  Use tool", true )
		UI.Label( "L Grip:     Orbit", true )
		UI.Label( "L + R Grip: Zoom (release L Grip first)", true )

		if UI.Button( "Close" ) then
			help_window_open = fasle
			UI.EndModalWindow()
		end
		UI.End( pass )
	end

	-- Load ref model modal window
	if ref_model_load_window_open then
		local m = mat4( win_transform ):translate( 0, 0, 0.01 )
		local path = ""
		if lovr.filesystem.isFused() then
			path = lovr.filesystem.getExecutablePath()
			path = path:sub( 1, -12 ) --"vblockz.exe"
			lovr.filesystem.mount( path .. "ref", "ref" )
		end
		UI.Begin( "load_ref_model", m, true )
		UI.Label( "path: " .. path )
		local files = lovr.filesystem.getDirectoryItems( "ref" )
		local _, idx = UI.ListBox( "files", 10, 21, files, 1 )

		if UI.Button( "Cancel" ) then
			ref_model_load_window_open = fasle
			UI.EndModalWindow()
		end

		if UI.Button( "OK" ) then
			ref_model = nil
			collectgarbage( "collect" )
			ref_model = lovr.graphics.newModel( "ref/" .. files[ idx ] )
			lovr.timer.sleep( 2 )
			ref_model_load_window_open = fasle
			UI.EndModalWindow()
		end

		UI.End( pass )
	end

	-- File exported modal window
	if file_exported_window_open then
		local m = mat4( win_transform ):translate( 0, 0, 0.01 )
		UI.Begin( "file_exported", m, true )
		local dir = lovr.filesystem.getSaveDirectory()
		UI.Label( "File exported to:" )
		UI.Label( dir )

		if UI.Button( "OK" ) then
			file_exported_window_open = fasle
			UI.EndModalWindow()
		end

		UI.End( pass )
	end

	-- Append modal window
	if append_window_open then
		local m = mat4( win_transform ):translate( 0, 0, 0.01 )
		local path = ""
		if lovr.filesystem.isFused() then
			path = lovr.filesystem.getExecutablePath()
			path = path:sub( 1, -12 ) --"vblockz.exe"
			lovr.filesystem.mount( path .. "ref", "ref" )
		end
		UI.Begin( "append_model", m, true )
		UI.Label( "path: " .. path )
		local files = lovr.filesystem.getDirectoryItems( "models" )
		local _, idx = UI.ListBox( "files", 10, 21, files, 1 )

		if UI.Button( "Cancel" ) then
			append_window_open = fasle
			UI.EndModalWindow()
		end

		if UI.Button( "OK" ) then
			append_model = "models/" .. files[ idx ]

			append = {}
			append_preview = {}
			local file = io.open( append_model, "rb" )
			local str = file:read( "*all" )
			append_preview = Json.decode( str )
			file:close()

			cur_tool = e_tool.append
			append_window_open = fasle
			UI.EndModalWindow()
		end

		UI.End( pass )
	end

	-- Load modal window
	if load_window_open then
		local m = mat4( win_transform ):translate( 0, 0, 0.01 )
		local path = ""
		if lovr.filesystem.isFused() then
			path = lovr.filesystem.getExecutablePath()
			path = path:sub( 1, -12 ) --"vblockz.exe"
			lovr.filesystem.mount( path .. "ref", "ref" )
		end
		UI.Begin( "load_model", m, true )
		UI.Label( "path: " .. path )
		local files = lovr.filesystem.getDirectoryItems( "models" )
		local _, idx = UI.ListBox( "files", 10, 21, files, 1 )

		if UI.Button( "Cancel" ) then
			load_window_open = fasle
			UI.EndModalWindow()
		end

		if UI.Button( "OK" ) then
			collection = {}
			local file = io.open( "models/" .. files[ idx ] )
			local str = file:read( "*all" )
			collection = Json.decode( str )
			file:close()
			load_window_open = fasle
			UI.EndModalWindow()
		end

		UI.End( pass )
	end

	return UI.RenderFrame( pass )
end

return Render
