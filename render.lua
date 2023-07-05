require "globals"

local Render = {}

function Render.Geometry( pass )
	pass:setShader( phong_shader )
	for i, v in ipairs( collection ) do
		if wireframe then
			pass:setColor( v.r, v.g, v.b )
			pass:box( v.x, v.y, v.z, 0.001, 0.001, 0.001 )
			pass:box( v.x, v.y, v.z, unit, unit, unit, 0, 0, 0, 0, "line" )
		else
			pass:setColor( v.r, v.g, v.b )
			pass:box( v.x, v.y, v.z, unit, unit, unit )
			pass:setColor( 0, 0, 0 )
			pass:box( v.x, v.y, v.z, unit, unit, unit, 0, 0, 0, 0, "line" )
		end
	end
end

function Render.Grid( pass )
	pass:setShader( grid_shader )
	pass:plane( 0, 0, 0, 100, 100, -math.pi / 2, 1, 0, 0 )
end

function Render.Cursor( pass )
	if not interaction_enabled then
		-- Cursor
		pass:setColor( 1, 0, 1 )

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
			pass:text( cur_tool_label, m )
		end
	end
end

function Render.Axis( pass )
	-- pass:setShader()
	-- pass:setColor( 1, 0, 0 )
	-- pass:line( 0, 0, 0, 0, 0.5 * (1 / scene.scale), 0 )

	-- pass:setColor( 0, 1, 0 )
	-- pass:line( 0, 0, 0, 0, 0, -0.5 * (1 / scene.scale) )

	-- pass:setColor( 0, 0, 1 )
	-- pass:line( 0, 0, 0, 0.5 * (1 / scene.scale), 0, 0 )

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
		pass:setShader()
		pass:setColor( 1, 1, 1, ref_model_alpha )
		pass:draw( ref_model )
		pass:setColor( 1, 1, 1, 1 )
	end
end

function Render.UI( pass )
	UI.NewFrame( pass )

	UI.Begin( "FirstWindow", win_transform )

	local button_bg_color = UI.GetColor( "button_bg" )

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

	UI.Separator()

	local ps, clicked, down, released, hovered, lx, ly = UI.WhiteBoard( "WhiteBoard1", 220, 220 )
	ps:setColor( cur_color[ 1 ], cur_color[ 2 ], cur_color[ 3 ] )
	ps:fill()
	UI.SameLine()


	r_released, cur_color[ 1 ] = UI.SliderFloat( "R", cur_color[ 1 ], 0, 1, 600, 3 )
	UI.SameColumn()
	g_released, cur_color[ 2 ] = UI.SliderFloat( "G", cur_color[ 2 ], 0, 1, 600, 3 )
	UI.SameColumn()
	b_released, cur_color[ 3 ] = UI.SliderFloat( "B", cur_color[ 3 ], 0, 1, 600, 3 )
	if r_released or g_released or b_released then
		-- UI.SetColor( col_list[ col_list_idx ], { cur_color[ 1 ], cur_color[ 2 ], cur_color[ 3 ] } )
	end
	UI.Separator()

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

	local _
	_, ref_model_alpha = UI.SliderFloat( "Reference model alpha", ref_model_alpha, 0, 1, 840, 3 )


	local _, _, _, buf = UI.TextBox( "filename", 21, export_filename )
	UI.SameLine()
	if UI.Button( "Export obj" ) then
		export_filename = buf
		if #collection > 0 then
			OBJ.Save( export_filename )
		end
	end

	UI.End( pass )
	return UI.RenderFrame( pass )
end

return Render