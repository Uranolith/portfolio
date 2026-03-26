shader_type canvas_item;

// --- Farben ---
uniform vec4 background_color : source_color = vec4(0.2, 0.25, 0.302, 1.0); 
uniform vec4 minor_grid_color : source_color = vec4(0.5, 0.5, 0.5, 0.33); 
uniform vec4 major_grid_color : source_color = vec4(0.5, 0.5, 0.5, 0.5); 

// --- Gitter Konfiguration ---
uniform float minor_grid_size = 20.0;
uniform float major_grid_ratio : hint_range(2, 20, 1) = 10.0;

// --- Größen ---
uniform float dot_size : hint_range(1.0, 5.0) = 2.0; 
uniform float major_line_thickness : hint_range(1.0, 5.0) = 1.5; 

// --- Dichte-Kontrolle ---
uniform float density_fade_start = 20.0; 
uniform float density_fade_end = 5.0; 

// --- Kameradaten ---
uniform vec2 camera_position = vec2(0.0);
uniform float camera_zoom = 1.0;

vec2 get_grid_intensity(vec2 pos, float size, float zoom, float thickness_px) {
	vec2 grid = mod(pos, size);
	float half_width_world = (thickness_px / zoom) * 0.5;
	float aa_range = (1.0 / zoom) * 0.5; 
	
	float d_x = min(grid.x, size - grid.x);
	float val_x = 1.0 - smoothstep(half_width_world - aa_range, half_width_world + aa_range, d_x);
	
	float d_y = min(grid.y, size - grid.y);
	float val_y = 1.0 - smoothstep(half_width_world - aa_range, half_width_world + aa_range, d_y);
	
	return vec2(val_x, val_y);
}

void fragment() {
	vec2 world_pos = (FRAGCOORD.xy / camera_zoom) + camera_position;
	
	// 1. Gitter berechnen
	vec2 minor_grid = get_grid_intensity(world_pos, minor_grid_size, camera_zoom, dot_size);
	float is_minor_dot = minor_grid.x * minor_grid.y;
	
	vec2 major_grid = get_grid_intensity(world_pos, minor_grid_size * major_grid_ratio, camera_zoom, major_line_thickness);
	float is_major_line = max(major_grid.x, major_grid.y);
	
	// 2. Dichte (LOD)
	float screen_cell_size = minor_grid_size * camera_zoom;
	float minor_alpha_factor = smoothstep(density_fade_end, density_fade_start, screen_cell_size);
	
	// 3. Mischen (RGB only!)
	vec3 final_rgb = background_color.rgb;
	
	// A) Punkte mischen
	// Wir nutzen den Alpha-Wert der Farbe (minor_grid_color.a) als "Deckkraft" für den Mix
	float minor_mix_amount = is_minor_dot * minor_alpha_factor * minor_grid_color.a;
	final_rgb = mix(final_rgb, minor_grid_color.rgb, minor_mix_amount);
	
	// B) Linien mischen
	float major_mix_amount = is_major_line * major_grid_color.a;
	final_rgb = mix(final_rgb, major_grid_color.rgb, major_mix_amount);
	
	// Ergebnis ausgeben (Alpha fest auf 1.0 zwingen!)
	COLOR = vec4(final_rgb, 1.0);
}