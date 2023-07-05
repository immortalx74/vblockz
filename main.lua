require "globals"
UI = require "ui/ui"
OBJ = require "obj"
Render = require "render"
Tool = require "tool"

function lovr.load()
	UI.Init()
	lovr.graphics.setBackgroundColor( 0.2, 0.2, 0.4 )
end

function lovr.keypressed( key, scancode, repeating )
	if key == "i" then
		if interaction_enabled then
			interaction_enabled = false
			UI.SetInteractionEnabled( interaction_enabled )
		else
			interaction_enabled = true
			UI.SetInteractionEnabled( interaction_enabled )
		end
	end
end

function lovr.update( dt )
	UI.InputInfo()
	SetCursor()
	UpdateToolLabel()

	if UI.GetInteractionEnabled() then
		interaction_enabled = true
	else
		interaction_enabled = false
	end

	if lovr.headset.wasPressed( "hand/right", "a" ) then
		if cur_tool == e_tool.draw then
			cur_tool = e_tool.erase
		else
			cur_tool = e_tool.draw
		end
	end

	if lovr.headset.wasPressed( "hand/right", "b" ) then
		if cur_tool == e_tool.paint then
			cur_tool = e_tool.eydropper
		else
			cur_tool = e_tool.paint
		end
	end

	if lovr.headset.wasPressed( "hand/left", "x" ) then
		show_ref_model = not show_ref_model
	end

	if lovr.headset.wasPressed( "hand/left", "y" ) then
		wireframe = not wireframe
	end

	if lovr.headset.wasPressed( "hand/left", "grip" ) then
		scene.offset:set( mat4( lovr.headset.getPose( "hand/left" ) ):invert() * scene.transform )
		scene.last_transform:set( scene.transform )
	end

	if lovr.headset.isDown( "hand/left", "grip" ) then
		scene.transform:set( mat4( lovr.headset.getPose( "hand/left" ) ) * (scene.offset) )
	end

	if lovr.headset.wasPressed( "hand/right", "grip" ) then
		local v1 = vec3( lovr.headset.getPosition( "hand/left" ) )
		local v2 = vec3( lovr.headset.getPosition( "hand/right" ) )
		scene.old_distance = v1:distance( v2 )
	end

	if lovr.headset.isDown( "hand/left", "grip" ) and lovr.headset.isDown( "hand/right", "grip" ) then
		local v1 = vec3( lovr.headset.getPosition( "hand/left" ) )
		local v2 = vec3( lovr.headset.getPosition( "hand/right" ) )
		local new_distance = v1:distance( v2 )
		local diff = scene.old_distance - new_distance

		scene.scale = MapRange( new_distance, 0, 0.01, 1, diff )
		scene.transform:scale( scene.scale )
	end

	if lovr.headset.wasPressed( hand, "trigger" ) and not interaction_enabled then
		if cur_tool == e_tool.volume then
			volume.start_cell:set( cursor.cell )
		end
	end

	if lovr.headset.wasReleased( hand, "trigger" ) and not interaction_enabled then
		if cur_tool == e_tool.volume then
			Tool.Volume( true )
		end
	end

	if lovr.headset.isDown( hand, "trigger" ) and not interaction_enabled then
		if cur_tool == e_tool.draw then
			Tool.Draw()
		end
		if cur_tool == e_tool.erase then
			Tool.Erase()
		end
		if cur_tool == e_tool.paint then
			Tool.Paint()
		end
		if cur_tool == e_tool.eydropper then
			Tool.EyeDropper()
		end
		if cur_tool == e_tool.volume then
			Tool.Volume( false )
		end
	end
end

function lovr.draw( pass )
	local ui_passes = Render.UI( pass )

	pass:transform( scene.transform )
	ShaderSend( pass )

	Render.Axis( pass )
	Render.Geometry( pass )
	Render.Cursor( pass )
	Render.ReferenceModel( pass )
	Render.Grid( pass )

	table.insert( ui_passes, pass )
	return lovr.graphics.submit( ui_passes )
end
