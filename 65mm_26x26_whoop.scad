include <whoop.scad>;

// Dimensional changes
whoop_xy_wheelbase = 65;
motor_cage_xy_diameter = 33;
motor_cage_z_depth = 13.5;
battery_cage_xz_dimensions = [11.9, 7.0];

// Weight savings overrides
motor_cage_strut_count = 3;
motor_cage_strut_z_angle = 0;
motor_base_z_thickness = 1.5;
motor_cage_xyz_thickness = 1.5;
motor_cage_loop_z_thickness = 2.75;
crossbar_z_thickness = 2.75;
battery_cage_xz_thickness = 1.5;
battery_cage_bracket_y_thickness = 2.5;

whoop();
