use <../involute_gears.scad>

$fn = $preview ? 50 : 200;

sun_teeth = 15;
ring_teeth = 41;
planet_teeth = (ring_teeth - sun_teeth)/2;
tooth_difference = -1;
ring_width = 2;
planets = 5;
pressure_angle = 25;
mod = 1;
thickness = 10;
backlash = 0.1;
translate_planets = [50, 0, 0];
helix_angle = 30;

in_ring_pitch_r = pitch_radius(mod, ring_teeth);
in_ring_r = in_ring_pitch_r + mod + ring_width;
out_ring_pitch_r = pitch_radius(mod, ring_teeth+tooth_difference);
out_ring_r = pitch_radius(mod, ring_teeth+tooth_difference) + mod + ring_width;

reduction = (ring_teeth/sun_teeth+1)*(ring_teeth+tooth_difference)*planet_teeth/(ring_teeth-planet_teeth);
echo(str("Reduction: ", reduction));

module hexagon(width) {
  x = width/2/sqrt(3);
  y = width/2;
  polygon([[x, y], [2*x, 0], [x, -y], [-x, -y], [-2*x, 0], [-x, y]]);
}

// Input set
planetary_gear_set(sun_teeth=sun_teeth, ring_teeth=ring_teeth, ring_width=ring_width, num_planets=planets, pressure_angle=pressure_angle, mod=mod, thickness=thickness, backlash=backlash, translate_planets=translate_planets);
translate([0, 0, thickness]) cylinder(1, 8.5, 8.5);
translate([0, 0, thickness+1]) linear_extrude(10) hexagon(17);
rotate([0, 0, 30]) translate([0, 0, thickness+1]) linear_extrude(10) hexagon(17);

// Support set
translate([0, 0, -thickness*3-2]) planetary_gear_set(sun_teeth=sun_teeth, ring_teeth=ring_teeth, ring_width=ring_width, num_planets=planets, pressure_angle=pressure_angle, mod=mod, thickness=thickness, backlash=backlash, translate_planets=translate_planets);

planet_dist = pitch_radius(mod, sun_teeth) + pitch_radius(mod, planet_teeth);
// Planet centers are the same, so adding one to the ring adds one to each planet
out_planet_teeth = planet_teeth + tooth_difference;
out_sun_teeth = ring_teeth + tooth_difference - 2*out_planet_teeth;

// Output set
translate([0, 0, -2*thickness-1]) planetary_gear_set(sun_teeth=out_sun_teeth, ring_teeth=ring_teeth+tooth_difference, ring_width=ring_width, num_planets=planets, pressure_angle=pressure_angle, mod=mod, thickness=2*thickness, backlash=backlash, translate_planets=translate_planets);

// Output outer gear
teeth = round(2*out_ring_r/mod+3*mod)+6;
echo(teeth);

translate([0, 0, -2*thickness-1]) difference() {
  herringbone_gear(num_teeth=teeth, pressure_angle=pressure_angle, mod=mod, thickness=2*thickness, backlash=backlash, helix_angle=helix_angle);
  translate([0, 0, -0.1]) cylinder(2*thickness+0.2, out_ring_r, out_ring_r);
}
// Planet connectors
planet_connector_r = pitch_radius(mod, out_planet_teeth) + mod;

translate(translate_planets) for (i = [0:planets-1]) {
  rotate(i*360/planets) translate([planet_dist, 0, -1]) cylinder(1, planet_connector_r, planet_connector_r);
  rotate(i*360/planets) translate([planet_dist, 0, -2*thickness-2]) cylinder(1, planet_connector_r, planet_connector_r);
}

// Stand
difference() {
  // change height to accomodate rack
  translate([-in_ring_r, -in_ring_r, 0]) cube([in_ring_r*2, out_ring_r+2, thickness+1]);
  translate([0, 0, -0.1]) cylinder(thickness+1.2, in_ring_r, in_ring_r);
  translate([-in_ring_r+5, out_ring_r+2-14, 5]) rotate([-90, 0, 0]) cylinder(14.1, 1.75, 1.75);
  translate([in_ring_r-5, out_ring_r+2-14, 5]) rotate([-90, 0, 0]) cylinder(14.1, 1.75, 1.75);
}

// Retention rings
translate([0, 0, thickness]) difference() {
  cylinder(1, in_ring_r, in_ring_r);
  translate([0, 0, -0.1]) cylinder(1.2, in_ring_pitch_r-1.25*mod, in_ring_pitch_r-1.25*mod);
}

translate([0, 0, -thickness*3-3]) difference() {
  cylinder(1, in_ring_r, in_ring_r);
  translate([0, 0, -0.1]) cylinder(1.2, in_ring_pitch_r-1.25*mod, in_ring_pitch_r-1.25*mod);
}

translate([0, -40, -2*thickness-1]) herringbone_rack(length=PI*40, width=thickness*2, base_thickness=5, pressure_angle=pressure_angle, mod=mod, backlash=backlash, helix_angle=-helix_angle);