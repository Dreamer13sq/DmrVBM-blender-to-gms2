/*
	Supports skeletal animation
	
	NOTE: If you don't see any vertices rendering at all, 
	check that u_matpose is populated with some valid matrices.
*/

// Varyings - Passed in from vertex shader
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

varying vec3 v_dirtolight_cs;
varying vec3 v_dirtocamera_cs;
varying vec3 v_normal_cs;

vec3 ColorBurn(vec3 B, vec3 A, float fac)	// Used in image editors like Photoshop
{
	// return max(vec3(0.0), 1.0-((1.0-B)/A)) * fac + B * (1.0-fac); // Used in image editors like Photoshop
	return max(vec3(0.0), 1.0-((1.0-B)) / ( (1.0-fac) + (fac*A) ) ); // Used in Blender
}

void main()
{
	// Varyings -------------------------------------------------------
	vec3 n = normalize(v_normal_cs);		// Vertex Normal
	vec3 l = normalize(v_dirtolight_cs);	// Light Direction
	vec3 e = normalize(v_dirtocamera_cs);	// Camera Direction
	vec3 r = reflect(-l, n);				// Reflect Angle
	
	// Shadow value
	float dp = dot(n, l);
	dp = (dp+1.0)*0.5; // Map to 0-1 range
	dp = pow(dp, 1.0); // Soften shadows
	dp = float(dp > 0.5);
	
	// Specular/Shine Value
	float spe = clamp(dot(e, r), 0.0, 1.0);
	spe = float(spe >= 0.9)*0.04;
	
	// Rimlight Value
	float rim = clamp(dot(normalize(n*vec3(1.0,2.0,1.0)), e), 0.0, 1.0);
	rim = float(rim < 0.3);
	
	// Output
	vec4 basecolor = (v_vColour * texture2D( gm_BaseTexture, v_vTexcoord ));
	
	float burnstrength = (basecolor.r*0.2126+basecolor.g*0.7152+basecolor.b*0.0722); // RGB to BW
	vec3 burnbase = basecolor.rgb*vec3(0.9, 0.9, 1.0);
	vec3 burnactive = vec3(0.0, 0.0, 1.0);
	vec3 burnedcolor = ColorBurn(burnbase, burnactive, burnstrength*0.5);
	
	gl_FragColor.rgb = mix(burnedcolor, basecolor.rgb, dp);
	gl_FragColor.rgb = mix(gl_FragColor.rgb, basecolor.rgb+vec3(0.2), rim);
	gl_FragColor.rgb = mix(gl_FragColor.rgb, basecolor.rgb, 1.0-basecolor.a);
	
	gl_FragColor.a = 1.0;
}
