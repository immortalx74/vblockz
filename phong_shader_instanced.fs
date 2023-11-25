Constants
{
	vec4 ambience;
	vec4 lightColor;
	vec3 lightPos;
	float specularStrength;
	int metallic;
};

in vec4 instance_color;

vec4 lovrmain()
{
	vec3 norm = normalize(Normal);
	vec3 lightDir = normalize(lightPos);
	float diff = max(dot(norm, lightDir), 0.0);
	vec4 diffuse = diff * lightColor;

	vec3 viewDir = normalize(CameraPositionWorld);
	vec3 reflectDir = reflect(-lightDir, norm);
	float spec = pow(max(dot(viewDir, reflectDir), 0.0), metallic);
	vec4 specular = specularStrength * spec * lightColor;
	vec4 baseColor = instance_color;
	return baseColor * (ambience + diffuse + specular);
}