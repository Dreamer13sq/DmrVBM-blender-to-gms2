//
// Simple passthrough vertex shader
//

// Vertex Attributes
attribute vec3 in_Position;	// (x,y,z)
attribute vec3 in_Normal;	// (x,y,z)     
attribute vec4 in_Color;	// (r,g,b,a)
attribute vec2 in_Uv;		// (u,v)

// Passed to Fragment Shader
varying vec3 v_pos;
varying vec2 v_uv;
varying vec4 v_color;
varying vec3 v_nor;

varying vec3 v_lightdir_cs;
varying vec3 v_eyedir_cs;
varying vec3 v_nor_cs;

const vec3 lightpos_ws = vec3(64.0, -128.0, 80.0);

void main()
{
	// Attributes
    vec4 vertexpos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
	vec4 normal = vec4( in_Normal.x, in_Normal.y, in_Normal.z, 0.0);
	
	// Set draw position
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vertexpos;
    
	// Varyings
	v_pos = (gm_Matrices[MATRIX_WORLD] * vertexpos).xyz;
    v_color = in_Color;
	v_color.a = 1.0;
    v_uv = in_Uv;
	v_nor = normalize(gm_Matrices[MATRIX_WORLD] * normal).xyz;
	
	vec3 vertexpos_cs = vec3(0.0)-(gm_Matrices[MATRIX_WORLD_VIEW] * vertexpos).xyz;
	v_eyedir_cs = vec3(0.0) - vertexpos_cs;
	
	vec3 lightpos_cs = (gm_Matrices[MATRIX_VIEW] * vec4(lightpos_ws, 1.0)).xyz;
	v_lightdir_cs = lightpos_cs + v_eyedir_cs;
	
	v_nor_cs = normalize( (gm_Matrices[MATRIX_WORLD_VIEW] * normal).xyz);
}
