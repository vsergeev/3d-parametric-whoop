/********************************************************
 * HDZero Lux Camera Harness - vsergeev
 * https://github.com/vsergeev/3d-parametric-whoop
 * CC-BY-4.0
 * v1.0
 ********************************************************/

camera_xyz_segments = [[6, 4.5, 3.5], [14.5, 4.6, 1], [10, 7.5, 4.5]];

harness_x_width = 14.25;
harness_y_length = camera_xyz_segments[0].y + camera_xyz_segments[1].y + camera_xyz_segments[2].y;
harness_z_height = 17;
mount_hole_xy_diameter = 2.25;
mount_hole_y_pitch = 10;

/* [Hidden] */

overlap_epsilon = 0.01;

$fn = 100;

/******************************************************************************/
/* 2D Profiles */
/******************************************************************************/

module mounting_hole_yz_footprint() {
    mount_hole_y_offset = camera_xyz_segments[0].y / 2;

    union() {
        translate([-mount_hole_y_offset, mount_hole_xy_diameter])
            circle(d=mount_hole_xy_diameter);

        translate([-mount_hole_y_offset - mount_hole_y_pitch, mount_hole_xy_diameter])
            circle(d=mount_hole_xy_diameter);
    }
}

/******************************************************************************/
/* 3D Extrusions */
/******************************************************************************/

module camera_slot() {
    segment_offsets = [ for (i = 0, o = 0; i < len(camera_xyz_segments); i = i + 1,  o = o + camera_xyz_segments[i - 1].y) o];

    union() {
        for (i = [0:len(camera_xyz_segments) - 1]) {
            translate([-camera_xyz_segments[i].x / 2, segment_offsets[i] - overlap_epsilon, camera_xyz_segments[i].z - overlap_epsilon])
                 cube([camera_xyz_segments[i].x, camera_xyz_segments[i].y + 2 * overlap_epsilon, harness_z_height - camera_xyz_segments[i].z + 2 * overlap_epsilon]);
        }
    }
}

module harness() {
    difference() {
        /* Base */
        translate([0, harness_y_length / 2, harness_z_height / 2])
            cube([harness_x_width, harness_y_length, harness_z_height], center=true);

        /* Camera Slot */
        camera_slot();

        /* Mounting Holes */
        rotate([90, 0, -90])
            translate([0, 0, -harness_x_width])
                linear_extrude(harness_x_width * 2, convexity=2)
                    mounting_hole_yz_footprint();
    }
}

/******************************************************************************/
/* Top Level */
/******************************************************************************/

harness();
