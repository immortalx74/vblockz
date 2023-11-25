    layout(set = 2, binding = 0) buffer CubeTransforms { mat4 cube_transforms[]; };
	layout(set = 2, binding = 1) buffer CubeColors { vec4 cube_colors[]; };

	out vec4 instance_color;
	
	vec4 lovrmain()
    {
		instance_color = cube_colors[InstanceIndex];
        return Projection * View * cube_transforms[InstanceIndex] * VertexPosition;
    }