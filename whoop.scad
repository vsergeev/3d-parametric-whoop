/********************************************************
 * Parametric Whoop Frame - vsergeev
 * https://github.com/vsergeev/3d-parametric-whoop
 * CC-BY-4.0
 * v1.0
 ********************************************************/

/* [General] */

whoop_xy_wheelbase = 75;

/* [Motor Base] */

motor_base_xy_diameter = 10;
motor_base_z_thickness = 1.75;
motor_base_xy_mounting_holes = [[4.2, 0, 0], [1.6, 6.6 / 2, 0], [1.6, 6.6 / 2, 120], [1.6, 6.6 / 2, 240]];

/* [Motor Cage] */

motor_cage_xy_diameter = 43;
motor_cage_z_depth = 15;
motor_cage_xyz_thickness = 1.75;
motor_cage_duct_z_thickness = 3.5;
motor_cage_strut_xy_thickness = 3;
motor_cage_strut_base_xy_thickness = 5;
motor_cage_strut_count = 4;
motor_cage_strut_z_angle = 45;

/* [Crossbars] */

crossbar_xy_width = 4;
crossbar_z_thickness = 3.5;
crossbar_xy_offset = 0.4;

/* [Flight Controller Mount] */

fc_mounting_hole_xy_pitch = 26;
fc_mounting_hole_xy_diameter = 2;
fc_mounting_ring_xy_diameter = 4.5;
fc_mounting_crossbar_xy_width = 5;
fc_mounting_crossbar_z_thickness = 1.5;

/* [Battery Cage] */

battery_cage_xz_dimensions = [15.6, 7.4];
battery_cage_xz_thickness = 2;
battery_cage_xz_inside_radius = 1.0;
battery_cage_xz_outside_radius = 0.5;
battery_cage_y_length = 20;
battery_cage_bracket_y_thickness = 3;
battery_cage_arm_y_thickness = 2.5;

/* [Hidden] */

overlap_epsilon = 0.01;

$fn = $preview ? 40 : 100;

/******************************************************************************/
/* Derived Parameters */
/******************************************************************************/

/* Place battery cage flush with motor cage bottom if possible, otherwise at crossbar z offset */
battery_cage_z_offset = max(motor_cage_z_depth - battery_cage_xz_thickness - battery_cage_xz_dimensions.y / 2, battery_cage_xz_dimensions.y / 2 + battery_cage_xz_thickness + crossbar_z_thickness);

battery_cage_arm_xyz_origin = [battery_cage_xz_dimensions.x / 2 + battery_cage_xz_thickness / 2, battery_cage_y_length / 2 - battery_cage_xz_thickness / 2,  -battery_cage_z_offset + battery_cage_xz_dimensions.y / 2];
battery_cage_arm_xy_angle = atan2(sin(45) / 2 * (whoop_xy_wheelbase) - battery_cage_arm_xyz_origin.y, cos(45) / 2 * (whoop_xy_wheelbase) - battery_cage_arm_xyz_origin.x);

/******************************************************************************/
/* 2D Profiles */
/******************************************************************************/

module motor_base_mounting_holes_xy_footprint() {
    union() {
        for (mounting_hole = motor_base_xy_mounting_holes) {
            rotate(mounting_hole[2])
                translate([0, mounting_hole[1]])
                    circle(d=mounting_hole[0]);
        }
    }
}

module motor_cage_xy_footprint() {
    circle(d = motor_cage_xy_diameter);
}

module motor_cage_relief_xy_footprint() {
    difference() {
      /* Cage Footprint */
      circle(d = motor_cage_xy_diameter + 2 * motor_cage_xyz_thickness);

      /* Base Footprint */
      circle(d = motor_base_xy_diameter + overlap_epsilon);
    }
}

module crossbar_xy_footprint() {
    relief_y_length = sin(45) / 2 * whoop_xy_wheelbase - sqrt((motor_cage_xy_diameter / 2) ^ 2 - (crossbar_xy_offset * motor_cage_xy_diameter / 2 + crossbar_xy_width) ^ 2);

    difference() {
        square([whoop_xy_wheelbase / 2, crossbar_xy_width], center=true);

        /* Relief */
        translate([0, crossbar_xy_width])
            resize([relief_y_length * 2, crossbar_xy_width * 2])
                circle(d=1);
    }
}

module fc_mounting_crossbar_xy_footprint() {
    difference() {
        union() {
            /* Crossbar */
            translate([0,  fc_mounting_crossbar_xy_width / 4])
                square([whoop_xy_wheelbase, fc_mounting_crossbar_xy_width / 2], center=true);

            /* Mounting Ring */
            circle(d=fc_mounting_ring_xy_diameter);
        }

        /* Bore */
        circle(d=fc_mounting_hole_xy_diameter);
    }
}

module battery_cage_xz_footprint() {
    difference() {
        /* Base */
        offset(r=battery_cage_xz_outside_radius)
            offset(delta=-battery_cage_xz_outside_radius)
                offset(delta=battery_cage_xz_thickness)
                    square(battery_cage_xz_dimensions, center=true);

        /* Battery Slot */
        offset(r=battery_cage_xz_inside_radius)
            offset(delta=-battery_cage_xz_inside_radius)
                square(battery_cage_xz_dimensions, center=true);
    }
}

module battery_cage_rails_xz_footprint() {
    difference() {
        battery_cage_xz_footprint();
        square([battery_cage_xz_dimensions.x, battery_cage_xz_dimensions.y * 2], center=true);
        square([battery_cage_xz_dimensions.x * 2, battery_cage_xz_dimensions.y], center=true);
    }
}

module battery_cage_arm_yz_footprint() {
    battery_cage_arm_xy_vector = [cos(battery_cage_arm_xy_angle), sin(battery_cage_arm_xy_angle)];
    battery_cage_arm_xy_origin = [battery_cage_arm_xyz_origin.x, battery_cage_arm_xyz_origin.y];
    motor_cage_xy_origin = [cos(45) / 2 * (whoop_xy_wheelbase), sin(45) / 2 * (whoop_xy_wheelbase)];
    battery_cage_arm_xy_length = -(battery_cage_arm_xy_vector * (battery_cage_arm_xy_origin - motor_cage_xy_origin)) - sqrt((battery_cage_arm_xy_vector * (battery_cage_arm_xy_origin - motor_cage_xy_origin))^2 - (norm(battery_cage_arm_xy_origin - motor_cage_xy_origin) ^ 2 - (motor_cage_xy_diameter / 2)^2)) + overlap_epsilon;
    battery_cage_arm_z_height = battery_cage_z_offset - battery_cage_xz_dimensions.y / 2;
    battery_cage_arm_z_angle = atan2(battery_cage_arm_z_height - motor_cage_duct_z_thickness - battery_cage_xz_thickness, battery_cage_arm_xy_length - motor_cage_xyz_thickness);

    offset(r=battery_cage_xz_outside_radius)
        offset(delta=-battery_cage_xz_outside_radius)
            polygon([
                [-battery_cage_xz_thickness, 0],
                [-battery_cage_xz_thickness, battery_cage_xz_thickness],
                [0, battery_cage_xz_thickness],
                [battery_cage_arm_xy_length - motor_cage_xyz_thickness, battery_cage_xz_thickness + tan(battery_cage_arm_z_angle) * (battery_cage_arm_xy_length - motor_cage_xyz_thickness)],
                [battery_cage_arm_xy_length - motor_cage_xyz_thickness, battery_cage_arm_z_height],
                [battery_cage_arm_xy_length, battery_cage_arm_z_height],
                [battery_cage_arm_xy_length, tan(battery_cage_arm_z_angle) * (battery_cage_arm_xy_length - battery_cage_xz_thickness)],
                [battery_cage_xz_thickness, 0]
            ]);
}

/******************************************************************************/
/* 3D Extrusions */
/******************************************************************************/

module motor_cage_profile() {
    minkowski() {
        cylinder(d=motor_cage_xy_diameter / 8, h=motor_cage_z_depth / 2, center=true);
        sphere(d=motor_cage_xy_diameter);
    }
}

module motor_cage_relief() {
    difference() {
        /* Base */
        translate([0, 0, -motor_cage_z_depth - overlap_epsilon])
            linear_extrude(motor_cage_z_depth + motor_cage_duct_z_thickness, convexity=2)
                motor_cage_relief_xy_footprint();

        /* Struts */
        for (i = [0 : motor_cage_strut_count - 1]) {
            rotate(i * (360 / motor_cage_strut_count) + motor_cage_strut_z_angle)
                rotate([90, 0, 180])
                    linear_extrude(motor_cage_xy_diameter)
                        polygon([[-motor_cage_strut_base_xy_thickness / 2, 0], [motor_cage_strut_base_xy_thickness / 2, 0], [motor_cage_strut_xy_thickness / 2, -motor_cage_z_depth - 2 * overlap_epsilon], [-motor_cage_strut_xy_thickness / 2, -motor_cage_z_depth - 2 * overlap_epsilon]]);
        }
    }
}

module motor_cage() {
    difference() {
        union() {
            /* Supporting Ducts */
            translate([0, 0, -motor_cage_duct_z_thickness]) {
                linear_extrude(motor_cage_duct_z_thickness) {
                    difference() {
                        circle(d=motor_cage_xy_diameter + 2 * motor_cage_xyz_thickness);
                        circle(d=motor_cage_xy_diameter);
                    }
                }
            }

            intersection() {
                difference() {
                    /* Spherical Base */
                    resize([motor_cage_xy_diameter + 2 * motor_cage_xyz_thickness, motor_cage_xy_diameter + 2 * motor_cage_xyz_thickness, 2 * motor_cage_z_depth + motor_cage_xyz_thickness / 2])
                        motor_cage_profile();

                    /* Hollow out inside */
                    resize([motor_cage_xy_diameter + overlap_epsilon, motor_cage_xy_diameter + overlap_epsilon, 2 * (motor_cage_z_depth - motor_base_z_thickness)])
                        motor_cage_profile();

                    /* Relief */
                    motor_cage_relief();
                }

                /* Keep everything inside motor cage */
                translate([0, 0, -motor_cage_z_depth])
                    linear_extrude(motor_cage_z_depth)
                        circle(d=motor_cage_xy_diameter + 2 * motor_cage_xyz_thickness - overlap_epsilon);
            }
        }

        /* Motor Base Mounting Holes */
        translate([0, 0, -(motor_cage_z_depth + overlap_epsilon)])
            linear_extrude(motor_cage_xyz_thickness * 1.5, convexity=2)
                motor_base_mounting_holes_xy_footprint();
    }
}

module support_crossbar() {
    translate([0, 0, -crossbar_z_thickness]) {
        linear_extrude(crossbar_z_thickness) {
            difference() {
                /* Motor Cage Crossbars */
                translate([0, sin(45) / 2 * whoop_xy_wheelbase + crossbar_xy_width / 2 + motor_cage_xy_diameter / 2 * crossbar_xy_offset])
                    crossbar_xy_footprint();

                /* Subtract overlap with Motor Cages */
                for (i = [0:3]) {
                    translate([cos(45 + i * 90) * whoop_xy_wheelbase / 2, sin(45 + i * 90) * whoop_xy_wheelbase / 2])
                        motor_cage_xy_footprint();
                }
            }
        }
    }
}

module fc_mounting_crossbar() {
    translate([0, 0, -fc_mounting_crossbar_z_thickness]) {
        linear_extrude(fc_mounting_crossbar_z_thickness) {
            difference() {
                /* Flight Controller Crossbars */
                translate([0, (fc_mounting_hole_xy_pitch / 2) / sin(45)])
                    fc_mounting_crossbar_xy_footprint();

                /* Subtract overlap with Motor Cages */
                for (i = [0:3]) {
                    translate([cos(45 + i * 90) * whoop_xy_wheelbase / 2, sin(45 + i * 90) * whoop_xy_wheelbase / 2])
                        motor_cage_xy_footprint();
                }
            }
        }
    }
}

module battery_cage() {
    rotate([90, 0, 0]) {
        union() {
            /* Battery Cage Rails */
            translate([0, 0, -battery_cage_y_length / 2])
                linear_extrude(battery_cage_y_length)
                    battery_cage_rails_xz_footprint();

            /* Front bracket */
            translate([0, 0, -battery_cage_y_length / 2])
                linear_extrude(battery_cage_bracket_y_thickness)
                    battery_cage_xz_footprint();

            /* Middle bracket */
            translate([0, 0, -battery_cage_bracket_y_thickness / 2])
                linear_extrude(battery_cage_bracket_y_thickness)
                    battery_cage_xz_footprint();

            /* Back bracket */
            translate([0, 0, battery_cage_y_length / 2 - battery_cage_bracket_y_thickness])
                linear_extrude(battery_cage_bracket_y_thickness)
                    battery_cage_xz_footprint();
        }
    }
}

module battery_cage_arm() {
    rotate([90, 0, 0]) {
        translate([0, 0, -battery_cage_arm_y_thickness / 2]) {
            /* Battery Cage Arm */
            linear_extrude(battery_cage_arm_y_thickness)
                battery_cage_arm_yz_footprint();
        }
    }
}

module whoop() {
    union() {
        /* Motor Cages */
        for (i = [0:3]) {
            translate([cos(45 + i * 90) * whoop_xy_wheelbase / 2, sin(45 + i * 90) * whoop_xy_wheelbase / 2])
                rotate(i < 2 ? 180 : 0)
                    motor_cage();
        }

        /* Support Crossbars */
        for (i = [0:3]) {
            rotate(90 * i)
                support_crossbar();
        }

        /* Flight Controller Mounting Crossbars */
        for (i = [0:3]) {
            rotate(90 * i)
                fc_mounting_crossbar();
        }

        /* Battery Cage */
        translate([0, 0, -battery_cage_z_offset])
            battery_cage();

        /* Battery Cage Arms */
        for (i = [0:3]) {
            translate([(i == 0 || i == 3 ? 1 : -1) * battery_cage_arm_xyz_origin.x, (i == 0 || i == 1 ? 1 : -1) * battery_cage_arm_xyz_origin.y, battery_cage_arm_xyz_origin.z])
                rotate(((i == 0 || i == 2) ? battery_cage_arm_xy_angle : (90 - battery_cage_arm_xy_angle)) + 90 * i)
                    battery_cage_arm();
        }
    }
}
