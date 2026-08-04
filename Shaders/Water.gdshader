shader_type canvas_item;

// Color uniforms to easily customize your ocean in the inspector
uniform vec4 shallow_color : source_color = vec4(0.35, 0.75, 0.85, 1.0);
uniform vec4 deep_color : source_color = vec4(0.15, 0.40, 0.65, 1.0);
uniform vec4 foam_color : source_color = vec4(0.85, 0.95, 1.0, 1.0);

// Wave parameters
uniform float wave_speed : hint_range(0.1, 5.0) = 1.0;
uniform float wave_frequency : hint_range(1.0, 50.0) = 15.0;
uniform float wave_amplitude : hint_range(0.001, 0.05) = 0.01;

void fragment() {
    // Standardized UV space using screen coordinates for infinite seamless tiling
    vec2 uv = SCREEN_UV;
    
    // Wave movement calculation
    float wave1 = sin(uv.x * wave_frequency + TIME * wave_speed);
    float wave2 = cos(uv.y * (wave_frequency * 0.8) - TIME * (wave_speed * 1.2));
    float combined_wave = (wave1 + wave2) * wave_amplitude;
    
    // Distort UV coordinates
    vec2 distorted_uv = uv + vec2(combined_wave, combined_wave);
    
    // Mix deep and shallow water based on height/waves
    float color_mix = sin(distorted_uv.y * 10.0 + TIME * wave_speed * 0.5) * 0.5 + 0.5;
    vec4 water_base = mix(deep_color, shallow_color, color_mix);
    
    // Add subtle animated foam highlights
    float foam_threshold = 0.82;
    float foam = step(foam_threshold, sin(distorted_uv.x * 30.0 + distorted_uv.y * 30.0 + TIME * wave_speed * 2.0));
    
    // Output final pixel color
    COLOR = mix(water_base, foam_color, foam * 0.3);
}