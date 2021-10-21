/// @desc

if window_get_width() != camerawidth
|| window_get_height() != cameraheight
{
	camerawidth = window_get_width();
	cameraheight = window_get_height();
	matproj = matrix_build_projection_perspective_fov(50, camerawidth/cameraheight, znear, zfar);
	
	surface_resize(application_surface, camerawidth, cameraheight);
	
	event_user(1);
}

vbmode ^= keyboard_check_pressed(ord("M"));
isplaying ^= keyboard_check_pressed(vk_space);

keymode ^= keyboard_check_pressed(ord("K"));
wireframe ^= keyboard_check_pressed(ord("L"));

if keyboard_check_pressed(vk_space)
{
	layout_model.FindElement("toggleplayback").Toggle();
}

// Controls
if !middlelock {layout_model.Update();}

var levplayback = 0;
if isplaying {levplayback = trackposspeed;}

if (!layout_model.IsMouseOver() && !layout_model.active)
|| middlelock
{
	levplayback += trackposspeed*LevKeyPressed(VKey.greaterThan, VKey.lessThan);
	
	// Pose Matrices
	lev = LevKeyPressed(VKey.bracketClose, VKey.bracketOpen);
	if lev != 0
	{
		poseindex = Modulo(poseindex+lev, array_length(posemats));
		array_copy(matpose, 0, posemats[poseindex], 0, array_length(posemats[poseindex]));
	}
	
	if mouse_check_button_pressed(mb_middle)
	|| (keyboard_check(vk_alt) && mouse_check_button_pressed(mb_left))
	{
		mouseanchor[0] = window_mouse_get_x();
		mouseanchor[1] = window_mouse_get_y();
		cameraanchor[0] = camera[0];
		cameraanchor[1] = camera[1];
		cameraanchor[2] = camera[2];
		rotationanchor[0] = cameradirection;
		rotationanchor[1] = camerapitch;
		
		middlemode = keyboard_check(vk_shift);
		middlelock = 1;
	}
	
	if middlelock
	{
		// Rotate
		if middlemode == 0
		{
			var r, u;
			r = window_mouse_get_x() - mouseanchor[0];
			u = window_mouse_get_y() - mouseanchor[1];
		
			cameradirection = rotationanchor[0] - r/4;
			camerapitch = rotationanchor[1] + u/4;
		}
		// Pan
		else
		{
			var r, u;
			var d = cameradist/40;
			r = (window_mouse_get_x() - mouseanchor[0])*d/20;
			u = (window_mouse_get_y() - mouseanchor[1])*d/20;
			
			camera[0] = cameraanchor[0] + (cameraright[0]*r) + (cameraup[0]*u);
			camera[1] = cameraanchor[1] + (cameraright[1]*r) + (cameraup[1]*u);
			camera[2] = cameraanchor[2] + (cameraright[2]*r) + (cameraup[2]*u);
		}
		
		// Wrap
		var _mx = window_mouse_get_x(),
			_my = window_mouse_get_y();
		var _w = window_get_width(),
			_h = window_get_height();
		
		if _mx < 0 {window_mouse_set(_mx+_w, _my); mouseanchor[0] += _w;}
		else if _mx >= _w-1 {window_mouse_set(_mx-_w, _my); mouseanchor[0] -= _w;}
		_mx = window_mouse_get_x();
		
		if _my <= 0 {window_mouse_set(_mx, _my+_h); mouseanchor[1] += _h;}
		else if _my >= _h-1 {window_mouse_set(_mx, _my-_h); mouseanchor[1] -= _h;}
		_my = window_mouse_get_y();
		
		if mouse_check_button_released(mb_middle)
		|| (mouse_check_button_released(mb_left))
		{
			while (cameradirection < 0) {cameradirection += 360;}
			cameradirection = cameradirection mod 360;
		
			while (camerapitch < 0) {camerapitch += 360;}
			camerapitch = camerapitch mod 360;
		
			middlelock = 0;
		}
	}
	
	//mouselook.Update(mouse_check_button(mb_middle) || (mouse_check_button(mb_left) && keyboard_check(vk_alt)));
	
	var lev = (keyboard_check(ord("W")) - keyboard_check(ord("S")))*0.1;
	lev += 4 * (mouse_wheel_up() - mouse_wheel_down());
	if lev != 0
	{
		var d = 1.2;
		cameradist *= (lev<0)? d: (1/d);
	}

	x += keyboard_check(vk_right) - keyboard_check(vk_left);
	y += keyboard_check(vk_up) - keyboard_check(vk_down);

	zrot += keyboard_check(ord("E")) - keyboard_check(ord("Q"));
}

// Animation Playback ================================================================

if levplayback != 0
{
	trackpos += levplayback;
	if trackpos < trackdata.positionrange[0] {trackpos = trackdata.positionrange[1];}
	if trackpos > trackdata.positionrange[1] {trackpos = trackdata.positionrange[0];}
	
	exectime[0] = get_timer();
	EvaluateAnimationTracks(lerp(trackdata.positionrange[0], trackdata.positionrange[1], trackpos), 
		2, keymode? vbx.bonenames: 0, trackdata, inpose);
	exectime[0] = get_timer()-exectime[0];
	
	exectime[1] = get_timer();
	CalculateAnimationPose(
		vbx.bone_parentindices, vbx.bone_localmatricies, vbx.bone_inversematricies, 
		inpose, matpose);
	exectime[1] = get_timer()-exectime[1];
}

// Rendering ==============================================================

drawmatrix = BuildDrawMatrix(
	1, 
	dm_emission, //*(string_pos("emi", vbx.vbnames[i]) != 0),
	dm_shine,
	dm_sss//(string_pos("skin", vbx.vbnames[i]) != 0),
	);

mattran = matrix_build(x,y,z, 0,0,zrot, 1,1,1);

UpdateView();

