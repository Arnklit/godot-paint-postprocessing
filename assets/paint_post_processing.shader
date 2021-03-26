shader_type spatial;
render_mode unshaded;

uniform sampler2D paint_daub : hint_white;
uniform vec2 grid = vec2(50.0, 50.0);
uniform vec2 daub_size = vec2(0.05, 0.05);
uniform float rand_rot : hint_range(0.0, 180.0) = 30.0;
uniform float seed_frame_rate = 6.0;

void vertex() {
  POSITION = vec4(VERTEX, 1.0);
}


vec2 rand2(vec2 x) {
    return fract(cos(vec2(dot(x, vec2(13.9898, 8.141)),
						  dot(x, vec2(3.4562, 17.398)))) * 43758.5453);
}

vec3 rand3(vec2 x) {
    return fract(cos(vec3(dot(x, vec2(13.9898, 8.141)),
                          dot(x, vec2(3.4562, 17.398)),
                          dot(x, vec2(13.254, 5.867)))) * 43758.5453);
}

vec4 tiler(vec2 uv, vec2 tile, vec2 d_size, int overlap, vec2 _seed, sampler2D scr_tex, float offset, float rotate, float scale, float value, sampler2D daub) {
	float c = 0.0;
	vec3 rc = vec3(0.0);
	vec3 col = vec3(0.0);
	vec3 rc1;
	for (int dx = -overlap; dx <= overlap; ++dx) {
		for (int dy = -overlap; dy <= overlap; ++dy) {
			vec2 pos = (floor(uv*tile)+vec2(float(dx), float(dy))+vec2(0.5))/tile-vec2(0.5);
			vec2 seed = rand2(pos+_seed);
			rc1 = rand3(seed);
			pos = pos+vec2(0.0/tile.x, 0.0)*floor(mod(pos.y*tile.y, 2.0))+offset*seed/tile;
			//float mask = $mask(fract(pos+vec2(0.5)));
			vec3 color_mask = textureLod(scr_tex, pos+vec2(0.5),0.0).rgb;
			
			vec2 pv = fract(uv - pos)-vec2(0.5);
			seed = rand2(seed);
			float angle = (seed.x * 2.0 - 1.0) * rotate * 0.01745329251;
			float ca = cos(angle);
			float sa = sin(angle);
			pv = vec2(ca*pv.x+sa*pv.y, -sa*pv.x+ca*pv.y);
			pv *= (seed.y-0.5)*2.0*scale+1.0;
			pv /= d_size;
			pv += vec2(0.5);
			pv = clamp(pv, vec2(0.0), vec2(1.0));
			seed = rand2(seed);
			float c1 = texture(daub, pv).r * (1.0 - value * seed.x);
			c = max(c, c1);
			col = mix(col, color_mask, step(c, c1));
			rc = mix(rc, rc1, step(c, c1));
			
		}
	}
	return vec4(col, c);
}

void fragment() {
	vec4 til = tiler(SCREEN_UV, grid, daub_size, 1, vec2( float(int(TIME * seed_frame_rate)) ), SCREEN_TEXTURE, 1.0, rand_rot, 0.3, 0.0, paint_daub);
	//vec4 til = tiler(UV, vec2(50.0, 50.0), 1, vec2( 0.0 ), TEXTURE, 1.0, 30.0, 0.3, 0.0, paint_daub);
	ALBEDO = til.rgb;
	//ALBEDO = vec3(linear_depth);
}
