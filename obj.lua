require "globals"

local OBJ = {}

local output = "o voxel\nmtllib "

function OBJ.GenerateUniqueColors()
	for i, voxel in ipairs( collection ) do
		local found = false

		for j, color in ipairs( unique_colors ) do
			if voxel.r == color.r and voxel.g == color.g and voxel.b == color.b then
				found = true
				break
			end
		end

		if not found then
			table.insert( unique_colors, { r = voxel.r, g = voxel.g, b = voxel.b } )
		end
	end
end

function OBJ.StoreUVs()
	for i, voxel in ipairs( collection ) do
		for j, color in ipairs( unique_colors ) do
			if voxel.r == color.r and voxel.g == color.g and voxel.b == color.b then
				voxel.uvy = 0.5
				voxel.uvx = ((1 / #unique_colors) / 2) + ((j - 1) * (1 / #unique_colors))
			end
		end
	end
end

function OBJ.WriteUVInfo( filename )
	output = output .. "\n"

	for i, v in ipairs( collection ) do
		for j = 1, 8, 1 do
			output = output .. "vt " .. tostring( v.uvx ) .. " " .. tostring( v.uvy ) .. "\n"
		end
	end
end

function OBJ.WriteVertexInfo( filename )
	output = output .. filename .. ".mtl\n"
	local hu = unit / 2

	for i, v in ipairs( collection ) do
		local bl1 = { v.x - hu, v.y - hu, v.z + hu }
		output = output .. "v " .. " " .. bl1[ 1 ] .. " " .. bl1[ 2 ] .. " " .. bl1[ 3 ] .. "\n"
		local br1 = { v.x + hu, v.y - hu, v.z + hu }
		output = output .. "v " .. " " .. br1[ 1 ] .. " " .. br1[ 2 ] .. " " .. br1[ 3 ] .. "\n"
		local tr1 = { v.x + hu, v.y + hu, v.z + hu }
		output = output .. "v " .. " " .. tr1[ 1 ] .. " " .. tr1[ 2 ] .. " " .. tr1[ 3 ] .. "\n"
		local tl1 = { v.x - hu, v.y + hu, v.z + hu }
		output = output .. "v " .. " " .. tl1[ 1 ] .. " " .. tl1[ 2 ] .. " " .. tl1[ 3 ] .. "\n"

		local bl2 = { v.x - hu, v.y - hu, v.z - hu }
		output = output .. "v " .. " " .. bl2[ 1 ] .. " " .. bl2[ 2 ] .. " " .. bl2[ 3 ] .. "\n"
		local br2 = { v.x + hu, v.y - hu, v.z - hu }
		output = output .. "v " .. " " .. br2[ 1 ] .. " " .. br2[ 2 ] .. " " .. br2[ 3 ] .. "\n"
		local tr2 = { v.x + hu, v.y + hu, v.z - hu }
		output = output .. "v " .. " " .. tr2[ 1 ] .. " " .. tr2[ 2 ] .. " " .. tr2[ 3 ] .. "\n"
		local tl2 = { v.x - hu, v.y + hu, v.z - hu }
		output = output .. "v " .. " " .. tl2[ 1 ] .. " " .. tl2[ 2 ] .. " " .. tl2[ 3 ] .. "\n"
	end

	lovr.filesystem.write( filename .. ".obj", output )
	output = ""
end

function OBJ.WriteFaceInfo( filename )
	output = output .. "s 0\nusemtl Material\n"
	local interv = 1

	for i, v in ipairs( collection ) do
		local f1 = tostring( (interv) )
		local f2 = tostring( (interv) + 1 )
		local f3 = tostring( (interv) + 2 )
		local f4 = tostring( (interv) + 3 )
		local f5 = tostring( (interv) + 4 )
		local f6 = tostring( (interv) + 5 )
		local f7 = tostring( (interv) + 6 )
		local f8 = tostring( (interv) + 7 )

		output = output .. "f " .. f1 .. "/" .. f1 .. " " .. f2 .. "/" .. f2 .. " " .. f3 .. "/" .. f3 .. " " .. f4 .. "/" .. f4 .. "\n"
		output = output .. "f " .. f8 .. "/" .. f8 .. " " .. f7 .. "/" .. f7 .. " " .. f6 .. "/" .. f6 .. " " .. f5 .. "/" .. f5 .. "\n"
		output = output .. "f " .. f2 .. "/" .. f2 .. " " .. f6 .. "/" .. f6 .. " " .. f7 .. "/" .. f7 .. " " .. f3 .. "/" .. f3 .. "\n"
		output = output .. "f " .. f4 .. "/" .. f4 .. " " .. f8 .. "/" .. f8 .. " " .. f5 .. "/" .. f5 .. " " .. f1 .. "/" .. f1 .. "\n"
		output = output .. "f " .. f4 .. "/" .. f4 .. " " .. f3 .. "/" .. f3 .. " " .. f7 .. "/" .. f7 .. " " .. f8 .. "/" .. f8 .. "\n"
		output = output .. "f " .. f5 .. "/" .. f5 .. " " .. f6 .. "/" .. f6 .. " " .. f2 .. "/" .. f2 .. " " .. f1 .. "/" .. f1 .. "\n"

		interv = interv + 8
	end

	lovr.filesystem.append( filename .. ".obj", output )
end

function OBJ.WriteTextureFile( filename )
	local blob = lovr.data.newBlob( #unique_colors * 4, "myblob" )
	local img = lovr.data.newImage( #unique_colors, 1, "rgba8", blob )
	for i, v in ipairs( unique_colors ) do
		img:setPixel( i - 1, 0, v.r, v.g, v.b )
	end

	local export_blob = img:encode()
	lovr.filesystem.write( filename .. ".png", export_blob )
end

function OBJ.WriteMaterialFile( filename )
	local str = "newmtl Material\nmap_Kd " .. filename .. ".png"
	lovr.filesystem.write( filename .. ".mtl", str )
end

function OBJ.Save( filename )
	OBJ.WriteVertexInfo( filename )
	OBJ.GenerateUniqueColors()
	OBJ.StoreUVs()
	OBJ.WriteUVInfo( filename )
	OBJ.WriteFaceInfo( filename )

	OBJ.WriteTextureFile( filename )
	OBJ.WriteMaterialFile( filename )
end

return OBJ
