/// @desc

gpu_push_state();

// GPU State
gpu_set_cullmode(demo.cullmode);	// Don't draw tris facing away from camera
gpu_set_ztestenable(true);	// Enable depth checking per pixel
gpu_set_zwriteenable(true);	// Enable depth writing per pixel

shader_set(shd_complete);

// Set Uniforms
drawmatrix = FetchDrawMatrix();

shader_set_uniform_f_array(u_shd_complete_drawmatrix, drawmatrix);
shader_set_uniform_f_array(u_shd_complete_light, obj_modeltest.lightdata);

// Pose
shader_set_uniform_matrix_array(u_shd_complete_matpose, matpose);
shader_set_uniform_matrix_array(u_shd_complete_mattex, mattex);

matrix_set(matrix_world, matrix_build(
	obj_modeltest.modelposition[0], 
	obj_modeltest.modelposition[1],
	obj_modeltest.modelposition[2], 
	0, 0, -obj_modeltest.modelzrot, 1, 1, 1));

// Draw Meshes
var n = vbx.vbcount;
var _primitivetype = demo.wireframe? pr_linelist: pr_trianglelist;
var _dm;
var _name;

for (var i = 0; i < n; i++)
{
	if meshvisible[i]
	{
		drawmatrix[3] = string_pos("skin", vbx.vbnames[i])? skinsss: sss;
		shader_set_uniform_f_array(u_shd_complete_drawmatrix, drawmatrix);
		
		texture_set_stage(u_shd_complete_texnormal, demo.usenormalmap? meshnormalmap[i]: -1);
		
		if demo.drawnormal {vertex_submit(vbx.vb[i], _primitivetype, meshnormalmap[i]);}
		else if demo.usetextures {vertex_submit(vbx.vb[i], _primitivetype, meshtexture[i]);}
		else {vertex_submit(vbx.vb[i], _primitivetype, -1);}
	}
}

// Restore State
shader_reset();
gpu_pop_state();