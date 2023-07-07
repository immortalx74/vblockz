e_tool = {
	draw = 1,
	erase = 2,
	paint = 3,
	eydropper = 4,
	volume = 5
}

e_volume_state = {
	started = 1,
	dragging = 2,
	finished = 3
}

scene = { transform = lovr.math.newMat4( vec3( 0, 0.5, -0.3 ) ), offset = lovr.math.newMat4(), last_transform = lovr.math.newMat4(), scale = 0.03, old_distance = 0 }
scene.transform:scale( scene.scale )
cur_tool = e_tool.draw
volume = { start_cell = lovr.math.newVec3(), state = e_volume_state.finished }
unit = 1
collection = {}
cursor = { center = lovr.math.newVec3(), cell = lovr.math.newVec3(), unsnapped = lovr.math.newVec3() }
cur_color = { 1, 1, 0 }
unique_colors = {}
export_filename = "mymodel"
help_window_open = false
ref_model_load_window_open = false
file_exported_window_open = false

win_transform = lovr.math.newMat4( 0, 1.4, -1 )
hand = "hand/right"
interaction_enabled = true
wireframe = false
show_grid = true
show_tool_label = true
ref_model = nil
show_ref_model = true
ref_model_alpha = 1
ref_model_scale = 1
active_tool_color = { 0.3, 0.3, 1 }
mdl_cube = lovr.graphics.newModel( "cube.glb" )
mdl_cube_wire = lovr.graphics.newModel( "cube_wire.glb" )

local vs = lovr.filesystem.read( "phong_shader.vs" )
local fs = lovr.filesystem.read( "phong_shader.fs" )
phong_shader = lovr.graphics.newShader( vs, fs )
local vs = lovr.filesystem.read( "phong_shader_instanced.vs" )
local fs = lovr.filesystem.read( "phong_shader_instanced.fs" )
phong_shader_instanced = lovr.graphics.newShader( vs, fs )
local vs = lovr.filesystem.read( "grid_shader.vs" )
local fs = lovr.filesystem.read( "grid_shader.fs" )
grid_shader = lovr.graphics.newShader( vs, fs, { flags = { highp = true } } )

cube_transforms = {}
cube_colors = {}
gpu_transforms_buf = lovr.graphics.newBuffer( 6000, "mat4" )
gpu_colors_buf = lovr.graphics.newBuffer( 6000, "vec4" )

function SetCursor()
	local pt = mat4( scene.transform )
	local hs = mat4( lovr.headset.getPose( hand ) ):rotate( -math.pi / 2, 1, 0, 0 ):translate( 0, 0, -0.1 )
	local x, y, z = vec3( pt:invert() * hs ):unpack()
	local grid_cell_x = math.floor( x / unit )
	local grid_cell_y = math.floor( y / unit )
	local grid_cell_z = math.floor( z / unit )
	local gx = grid_cell_x * unit
	local gy = grid_cell_y * unit
	local gz = grid_cell_z * unit
	cursor.center:set( gx + (unit / 2), gy + (unit / 2), gz + (unit / 2) )
	cursor.cell:set( grid_cell_x, grid_cell_y, grid_cell_z )
	cursor.unsnapped:set( x, y, z )
end

function UpdateToolLabel()
	if cur_tool == e_tool.draw then cur_tool_label = "Draw" end
	if cur_tool == e_tool.erase then cur_tool_label = "Erase" end
	if cur_tool == e_tool.paint then cur_tool_label = "Paint" end
	if cur_tool == e_tool.eydropper then cur_tool_label = "EyeDropper" end
	if cur_tool == e_tool.volume then cur_tool_label = "Volume" end
end

function MapRange( from_min, from_max, to_min, to_max, v )
	return (v - from_min) * (to_max - to_min) / (from_max - from_min) + to_min
end

function ShaderSend( pass )
	pass:setCullMode( "back" )
	pass:setShader( phong_shader_instanced )
	pass:send( 'lightColor', { 0.5, 0.5, 0.5, 1.0 } )
	pass:send( 'lightPos', { 8, 4, 8 } )
	pass:send( 'ambience', { 0.1, 0.1, 0.1, 1.0 } )
	pass:send( 'specularStrength', 4 )
	pass:send( 'metallic', 16 )
	pass:send( 'CubeTransforms', gpu_transforms_buf )
	pass:send( 'CubeColors', gpu_colors_buf )
end

function FillBuffers()
	cube_transforms = {}
	cube_colors = {}
	for i, v in ipairs( collection ) do
		local st = mat4( scene.transform )
		local m = mat4( st * mat4( vec3( v.x, v.y, v.z ), vec3( unit, unit, unit ), quat() ) )
		table.insert( cube_transforms, m )
		table.insert( cube_colors, { v.r, v.g, v.b, 1 } )
	end

	if #cube_transforms > 0 then
		gpu_transforms_buf:setData( cube_transforms, 1, 1, #cube_transforms )
		gpu_colors_buf:setData( cube_colors, 1, 1, #cube_colors )
	end
end
