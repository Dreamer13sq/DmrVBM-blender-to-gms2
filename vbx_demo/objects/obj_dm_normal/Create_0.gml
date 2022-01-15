/// @desc

event_inherited();

// Vertex Format: [pos3f, normal3f, color4B, uv2f]
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_normal();
vertex_format_add_color();
vertex_format_add_texcoord();
vbf = vertex_format_end();

vb = OpenVertexBuffer(DIRPATH + "curly_normal.vb", vbf);

drawmatrix = BuildDrawMatrix();

// Uniforms
var _shd;
_shd = shd_model;
u_shd_model_drawmatrix = shader_get_uniform(_shd, "u_drawmatrix");
u_shd_model_light = shader_get_uniform(_shd, "u_light");

event_user(1);

