/// @desc Set matrices and draw VB

// Store room matrices
var roommatrices = [
	matrix_get(matrix_projection),
	matrix_get(matrix_view),
	matrix_get(matrix_world)
];

// Set camera matrices
matrix_set(matrix_projection, matproj);
matrix_set(matrix_view, matview);
matrix_set(matrix_world, mattran); // No effect for default GM shader

// Draw vertex buffer
if (vb_axis >= 0)
{
	vertex_submit(vb_axis, pr_trianglelist, -1);
}

// Restore previous room matrices
matrix_set(matrix_projection, roommatrices[0]);
matrix_set(matrix_view, roommatrices[1]);
matrix_set(matrix_world, roommatrices[2]);

