/********************************************************
 * Parametric Whoop Canopy - vsergeev
 * https://github.com/vsergeev/3d-parametric-whoop
 * CC-BY-4.0
 * v1.0
 ********************************************************/

/* [General] */

canopy_z_height = 20;
canopy_xyz_thickness = 2;

/* [Mounting Holes] */

canopy_mounting_hole_xy_pitch = 26;
canopy_mounting_hole_xy_diameter = 2;
canopy_mounting_ring_xy_diameter = 5;
canopy_mounting_nut_xy_width = 3.5;
canopy_mounting_nut_z_depth = 1;

canopy_antenna_hole_xy_diameter = 2;

/* [Camera Mount] */

camera_mount_x_width = 14;
camera_mount_y_depth = 14;
camera_mount_z_offset = 8;
camera_mount_x_thickness = 2;
camera_mount_yz_radius = 1;
camera_mounting_hole_xy_diameter = 2.25;
camera_mounting_hole_y_pitch = 10;
camera_mounting_hole_z_offset = 0;

/* [Hidden] */

overlap_epsilon = 0.01;

$fn = $preview ? 50 : 100;

/******************************************************************************/
/* Derived Parameters */
/******************************************************************************/

canopy_xy_width = canopy_mounting_hole_xy_pitch / sin(45);

/******************************************************************************/
/* 2D Profiles */
/******************************************************************************/

module mounting_ring_xy_footprint() {
    circle(d = canopy_mounting_ring_xy_diameter);
}

module mounting_hole_xy_footprint() {
    circle(d=canopy_mounting_hole_xy_diameter);
}

module mounting_nut_xy_footprint() {
    circle(d=canopy_mounting_nut_xy_width, $fn=6);
}

module canopy_xy_footprint() {
    width = canopy_xy_width;

    polygon([
        [-canopy_mounting_ring_xy_diameter / 2, width / 2],
        [canopy_mounting_ring_xy_diameter / 2, width / 2],
        [width / 2, canopy_mounting_ring_xy_diameter / 2],
        [width / 2, -canopy_mounting_ring_xy_diameter / 2],
        [canopy_mounting_ring_xy_diameter / 2, -width / 2],
        [-canopy_mounting_ring_xy_diameter / 2, -width / 2],
        [-width / 2, -canopy_mounting_ring_xy_diameter / 2],
        [-width / 2, canopy_mounting_ring_xy_diameter / 2]
    ]);
}

module camera_mount_yz_footprint() {
    camera_mount_y_length = canopy_xy_width - tan(45) * (camera_mount_x_width + camera_mount_x_thickness * 2);

    offset(r=camera_mount_yz_radius)
        offset(delta=-camera_mount_yz_radius)
            polygon([
                [-camera_mount_y_length / 2, camera_mount_x_thickness],
                [-camera_mount_y_depth / 2, canopy_z_height],
                [camera_mount_y_depth / 2, canopy_z_height],
                [camera_mount_y_length / 2, camera_mount_x_thickness]
            ]);
}

module camera_mounting_holes_yz_footprint() {
    union() {
        /* Center Mounting Hole */
        translate([camera_mounting_hole_y_pitch / 2, camera_mount_z_offset + camera_mounting_hole_z_offset])
            circle(d=camera_mounting_hole_xy_diameter);

        /* Tilt Mounting Holes */
        for (a = [0:1:40]) {
            translate([camera_mounting_hole_y_pitch / 2, camera_mount_z_offset + camera_mounting_hole_z_offset])
                rotate([0, 0, -a])
                    translate([-camera_mounting_hole_y_pitch, 0])
                        circle(d=camera_mounting_hole_xy_diameter);
        }
    }
}

/******************************************************************************/
/* 3D Extrusions */
/******************************************************************************/

module shell() {
    hull() {
        linear_extrude(canopy_xyz_thickness)
            canopy_xy_footprint();

        translate([0, 0, camera_mount_z_offset])
            resize([camera_mount_x_width, camera_mount_x_width, canopy_xyz_thickness])
                sphere(d=1);
    }
}

module mounting_ring() {
    linear_extrude(canopy_xyz_thickness)
        mounting_ring_xy_footprint();
}

module mounting_hole() {
    translate([0, 0, -canopy_xyz_thickness])
        linear_extrude(canopy_xyz_thickness * 2)
            mounting_hole_xy_footprint();
}

module mounting_nut() {
    translate([0, 0, canopy_xyz_thickness - canopy_mounting_nut_z_depth])
        linear_extrude(canopy_xyz_thickness)
            mounting_nut_xy_footprint();
}

module camera_mount_side() {
    rotate([90, 0, -90])
        translate([0, 0, -camera_mount_x_thickness / 2])
            linear_extrude(camera_mount_x_thickness)
                camera_mount_yz_footprint();
}

module canopy() {
    difference() {
        union() {
            shell();

            /* Camera Mount Left */
            translate([-camera_mount_x_width / 2 - camera_mount_x_thickness / 2, 0])
                camera_mount_side();

            /* Camera Mount Right */
            translate([camera_mount_x_width / 2 + camera_mount_x_thickness / 2, 0])
                camera_mount_side();

            /* Mounting Rings */
            for (i = [0:3]) {
                rotate(90 * i)
                    translate([0, (canopy_mounting_hole_xy_pitch / 2) / sin(45)])
                        mounting_ring();
            }
        }

        /* Mounting Holes and Nuts */
        for (i = [0:3]) {
            rotate(90 * i) {
                translate([0, (canopy_mounting_hole_xy_pitch / 2) / sin(45)]) {
                    mounting_hole();
                    mounting_nut();
                }
            }
        }

        /* Interior */
        translate([0, 0, -overlap_epsilon])
            resize([canopy_xy_width - canopy_xyz_thickness * 2, canopy_xy_width - canopy_xyz_thickness * 2, camera_mount_z_offset])
                shell();

        /* Front Camera Relief */
        translate([0, canopy_xy_width / 4, camera_mount_z_offset - camera_mounting_hole_xy_diameter])
            linear_extrude(canopy_z_height)
                square([camera_mount_x_width + overlap_epsilon, canopy_xy_width / 2], center=true);

        /* Rear Camera Relief */
        translate([0, -canopy_xy_width / 4, 1.5 * canopy_xyz_thickness])
            linear_extrude(canopy_z_height)
                square([camera_mount_x_width + overlap_epsilon, canopy_xy_width / 2 + overlap_epsilon], center=true);

        /* Camera Mounting Holes */
        rotate([90, 0, -90])
            translate([0, 0, -camera_mount_x_width])
                linear_extrude(camera_mount_x_width * 2, convexity=2)
                    camera_mounting_holes_yz_footprint();

        /* Right Antenna Hole */
        translate([((camera_mount_x_width + camera_mount_x_thickness) / 2 + (canopy_mounting_hole_xy_pitch / 2) / sin(45)) / 2, 0])
            cylinder(d=canopy_antenna_hole_xy_diameter, h=canopy_z_height / 2);

        /* Left Antenna Hole */
        translate([-((camera_mount_x_width + camera_mount_x_thickness) / 2 + (canopy_mounting_hole_xy_pitch / 2) / sin(45)) / 2, 0])
            cylinder(d=canopy_antenna_hole_xy_diameter, h=canopy_z_height / 2);
    }
}
