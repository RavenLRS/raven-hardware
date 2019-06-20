
use <../lib/fillets2d.scad>;
use <../lib/fillets3d.scad>;

use <../lib/raven.scad>;

translate([0, 0, 7.6]) {
    import("../../Raven_TX_L1/Raven_TX_L1.stl");
}

// Toggles
debug = true; // Make some renders faster during development
// Enable/disable which parts to design (for exporting as separate STL files)
bottom_piece = true;
top_piece = false;
bottom_top_separation = 15; // For debugging

// All dimensions are from looking at the module bay from the back of the radio

// Main case dimensions
width = 43.5; 
height = 59.5;
depth = 22; // Just for the bottom part
top_depth = 2; // Top part
thickness = 1.6;
tab_inside_thickness = 0.8; // Wall thickness in the inside of the side tabs, to save some space for the raven TXS v1 PCB


// Screw hole parameters
screw_dia = 3.2; // This fits M3 screws when 3d printed
screw_pitch = 0.50;
screw_wall_width = 1;
screw_depth = 5;
screws = [false, false, true, true]; // TR, BR, BL, TL
screw_base_dia = screw_dia + screw_wall_width * 2;
screw_base_rad = screw_base_dia / 2;
screw_head_dia = 5.4;
// Calculate here for TR screw, used by bottom and top parts
screw_x = width / 2 - screw_base_rad  - thickness;
screw_y = height / 2 - screw_base_rad - thickness;



// Mounting holes
mounting_hole_diameter = 1;
mounting_hole_base_diameter = 2;
mounting_hole_depth = 2.5;
mounting_standoff_depth = 7.6;
mounting_holes = [
    // These touch the case, will be fixed in next PCB rev
    //[18, 28],
    //[-8.5, 28],
    //[-8.5, -10.5],
    [18, -10.5]
];

// Bay
bay_width = 44.5;
bay_height = 60;

// Cut for the 5-pin connector
conn_width = 3;
conn_height = 14;
conn_distance_right = 6; // From the bay to the pins - either 6 or 5.5
conn_distance_bottom = 2.15; // From the bay to the bottom pin
conn_margin_offset = 0.5;

// Tabs
tab_width = 3; // Width as looked from the back, 3 could be better
tab_width_clearance = 0.5;
tab_width_top_protrusion = 3; // How many mm the tab top protrudes from the case body
tab_width_mid_protrusion = 1.5; // How many mm the tab middle protrudes from the case body
tab_height = 12;
tab_height_clearance = 1;
tab_base_width = 0.8;
tab_base_depth = 0.4;
tab_hole_width = tab_width - 1;
tab_hole_depth = 2.5;
tab_hole_front_distance = 2;

// Cut for fitting the bay
cut_height = tab_height + tab_height_clearance * 2;
cut_bottom_distance = 24.5; // Distance from the bottom of the tab to the bottom of the bay
cut_depth_start = 12;
cut_thickness = tab_width + tab_width_clearance;
cut_join_thickness = 0.8; // How thick is the horizontal join between half and bottom

// Screen size/location
screen = [-10, -8];
screen_width = 26.5;
screen_height = 15;

// RGB led size/location
led_radius = 2.5; // Must be a multiple of 0.5mm
led_translate_x = 3.5;
led_translate_y = -14;

// Antenna mount
antenna_mount_width = 16;
antenna_mount_height = 20;
antenna_mount_depth = 15;

// Coupling tabs for joining bottom and top
coupling_tab_width = 5;
coupling_tab_height = 5;
coupling_tab_thickness = 3;
coupling_tab_y = -20;

// Button
button_dia = 2;
button_distance = 6.15; // From bottom of the top piece. This value fits the 7mm button
button_helper_cut_length = button_dia * 2;
button_translate_x = 11.6;
button_translate_y = -17.5;

alpha = 0.5;

$fn = 25;

//**** BOTTOM PIECE ***/
if (bottom_piece) {
    union() {
        color("azure", alpha) {
            bottom_bottom_half();
            bottom_screws();
            bottom_mounting_standoffs();
            bottom_half_join();
            bottom_top_half();
            bottom_tabs();
            bottom_inner_tabs();
        }
    }
}

//**** TOP PIECE ***/
if (top_piece) {
    translate([0, 0, bottom_top_separation + depth]) {
        union() {
             {
                top_base();
                top_antenna();
                top_inner_tabs();
                top_button_helper();
            }
        }
    }
}


/*** Bottom half on the bottom case ***/

module bottom_bottom_shape(delta) {
    offset(delta=delta) {
        rounding2d(1)
        square([width, height]);
    }
}

module bottom_bottom_half() {
    bottom_depth = cut_depth_start - cut_join_thickness;
    translate([-width / 2, -height / 2, 0]) {
        difference() {
            linear_extrude(height=bottom_depth) {
                bottom_bottom_shape(0);
            }
            translate([0, 0, thickness]) {
                linear_extrude(height=bottom_depth) {
                    bottom_bottom_shape(-thickness);
                }
            }
            conn_x = -conn_width + (bay_width + width) / 2 - conn_distance_right + conn_width / 2;
            conn_y = -(bay_height - height) / 2 + conn_distance_bottom;
            translate([0, 0, 0]) {
                linear_extrude(height=thickness * 2) {
                    offset(delta=conn_margin_offset) {
                        translate([conn_x, conn_y]) {
                            square([conn_width, conn_height]);
                        }
                    }
                }
            }
            // Workaround the fuckup in the PCB, it's too long
            translate([width - 31 - 1.3, height - thickness * 1.5, 7.4]) {
                cube([31, thickness * 2, 2.1]);
            }
        }
    }
}

module bottom_screw() {
	screw_receptacle([screw_x, screw_y, 0], depth, screw_dia, screw_pitch, screw_wall_width, screw_depth, walls=[0, 90], approx=debug);
}

module bottom_screws() {
	xy_mirror(orig=screws[0], x=screws[3], y=screws[1], xy=screws[2]) {
		bottom_screw();
	}
}

module bottom_mounting_standoff(point) {
	standoff([point[0], point[1], 0], mounting_hole_depth, mounting_hole_diameter / 2,  mounting_standoff_depth, mounting_hole_base_diameter / 2);
}

module bottom_mounting_standoffs() {
    for (p = mounting_holes) {
        bottom_mounting_standoff(p);
    }
}

/*** Top half on the bottom case ***/

module case_base_polygon(delta) {
    cut_y_top = -height / 2 + cut_height + cut_bottom_distance;
    cut_y_bottom = -height / 2 + cut_bottom_distance;
    offset(delta=delta) {
        fillet2d(0.5)
        rounding2d(1)
        polygon([
            [-width / 2, height / 2],
            [width / 2, height / 2],
            [width / 2, cut_y_top],
            [width / 2 - cut_thickness, cut_y_top],
            [width / 2 - cut_thickness, cut_y_bottom],
            [width / 2, cut_y_bottom],
            [width / 2, -height / 2],
            [-width / 2, -height / 2],
            [-width / 2, cut_y_bottom],
            [-width / 2 + cut_thickness, cut_y_bottom],
            [-width / 2 + cut_thickness, cut_y_top],
            [-width / 2, cut_y_top],
        ]);
    }
}

module bottom_half_join() {
    translate([0, 0, cut_depth_start - cut_join_thickness]) {
        linear_extrude(height=cut_join_thickness) {
            difference() {
                rounding2d(1)
                square([width, height], center=true);
                case_base_polygon(-thickness);
            }
        }
    }
}

module bottom_top_half() {
    translate([0, 0, cut_depth_start]) {
        linear_extrude(height=depth-cut_depth_start) {
            difference() {
                case_base_polygon(0);
                case_base_polygon(-thickness);
            }
        }
    }
}

module bottom_tab() {
    tab_depth = depth - cut_depth_start;
    tab_x = width / 2 - tab_width + tab_width_clearance;
    tab_y = -height / 2 + cut_bottom_distance + tab_height_clearance;
    tab_z = cut_depth_start + tab_depth;
	tab_top_x = tab_width - tab_width_clearance + tab_width_top_protrusion;
	tab_mid_x = tab_top_x - tab_width_top_protrusion + tab_width_mid_protrusion;
    translate([tab_x, tab_y, tab_z]) {
        rotate([-90, 0, 0]) {
            linear_extrude(height=tab_height) {
                tab_top = depth - cut_depth_start;
                difference() {
                    polygon([
                        [0, 0],
                        [0, tab_top],
                        [tab_base_width, tab_top],
                        [tab_base_width, tab_top - tab_base_depth],
					    [tab_mid_x, tab_top - tab_hole_depth - tab_hole_front_distance],
                        [tab_top_x , 0]
                    ]);
                    translate([tab_top_x - tab_hole_width, tab_hole_front_distance]) {
                        square([tab_hole_width, tab_hole_depth]);
                    }
                }
            }
        }
    }
}

module bottom_tabs() {
    bottom_tab();
    mirror([1, 0, 0]) {
        bottom_tab();
    }
}

module bottom_inner_tab() {
    translate([width / 2, coupling_tab_y, depth - coupling_tab_thickness]) {
        rotate([0, -90, 0]) {
            linear_extrude(height=coupling_tab_width, scale=0.5) {
                square([coupling_tab_thickness, coupling_tab_height]);
            }
        }
    }
}


module bottom_inner_tabs() {
    bottom_inner_tab();
    mirror([0, 1, 0]) {
        bottom_inner_tab();
    }
}

module top_screw_hole() {
	screw_passthrough([screw_x, screw_y, 0], top_depth, screw_dia, screw_head_dia, thickness / 2);
}

module top_screw_holes() {
	xy_mirror(orig=screws[0], x=screws[3], y=screws[1], xy=screws[2]) {
		top_screw_hole();
	}
}

module top_button_helper_cut_base(delta) {
    offset(delta=delta) {
        circle(r=button_dia / 2);
        translate([-button_dia / 2, 0]) {
            square([button_dia, button_helper_cut_length]);
        }
    }
}

module top_base() {
    difference() {
        linear_extrude(height=top_depth) {
            case_base_polygon(0);
        }
        linear_extrude(height=top_depth - thickness) {
            case_base_polygon(-thickness);
        }
        // Screen
        translate([screen[0], screen[1]], 0) {
            linear_extrude(height=top_depth+1) {
                rounding2d(1)
                square([screen_width, screen_height]);
            }
        }
        // Antenna mount hole
        hole_width = antenna_mount_width - thickness * 2;
        hole_height = antenna_mount_height - thickness * 2;
        translate([-hole_width / 2, height / 2 - hole_height - thickness, top_depth - thickness-0.1]) {
            cube([hole_width, hole_height, thickness+0.2]);
        }
        // LED perforations
		perforations([led_translate_x, led_translate_y, top_depth - thickness - 0.1], thickness + 0.2, led_radius);
        // Holes for screws
        top_screw_holes();
        // Cut for letting the button helper bend
        cut_width = 0.5;
        translate([button_translate_x, button_translate_y, 0]) {
            rotate([0, 0, 90]) {
                linear_extrude(height=thickness*2) {
                    difference() {
                        top_button_helper_cut_base(cut_width);
                        top_button_helper_cut_base(0);
                        translate([-button_dia/2, button_helper_cut_length]) {
                            square([button_dia, cut_width]);
                        }
                    }
                }
            }
        }
    }
}

module top_antenna_polygon(delta) {
    offset(delta=delta) {
        polygon([
            [0, 0],
            [antenna_mount_depth, 0],
            [antenna_mount_depth, -antenna_mount_height],
            [0, -antenna_mount_height * 2/3],            
        ]);
    }
}

module top_antenna_solid() {
    union() {
        translate([0, 0, thickness]) {
            mount_height = antenna_mount_width - thickness * 2;
            linear_extrude(height=mount_height) {
                difference() {
                    top_antenna_polygon(0);
                    top_antenna_polygon(-thickness);
                }
            }
            translate([0, 0, mount_height]) {
                linear_extrude(height=thickness) {
                    top_antenna_polygon(0);
                }
            }
            translate([0, 0, -thickness]) {
                linear_extrude(height=thickness) {
                    top_antenna_polygon(0);
                }
            }
        }
    }
}

module top_antenna() {
    translate([-antenna_mount_width / 2, height / 2, antenna_mount_depth + top_depth]) {
        rotate([0, 90, 0]) {
            difference() {
                top_antenna_solid();
                // TODO: Check radius
                antenna_hole_radius = 3.5;
                translate([antenna_mount_depth / 2, thickness, antenna_mount_width / 2]) {
                    rotate([90, 0, 0]) {
                        cylinder(h=thickness * 3, r=antenna_hole_radius, center=false);
                    }
                }
                translate([antenna_mount_depth - thickness - 0.1, -antenna_mount_height + thickness, thickness]) {
                    cube([thickness + 0.2, antenna_mount_height - thickness * 2, antenna_mount_width - thickness * 2]);
                }
            }
        }
    }
}

module top_inner_tab_side(delta) {
    offset(delta=delta) {
        square([coupling_tab_thickness, coupling_tab_height]);
    }
}

module top_inner_tab() {
    outer_offset = 1;
    inner_offset = 0.5;
    tab_z = -inner_offset;
    translate([width / 2 - coupling_tab_width, coupling_tab_y, tab_z]) {
        rotate([0, 90, 0]) {
            linear_extrude(height = coupling_tab_width) {
                difference() {
                    top_inner_tab_side(outer_offset);
                    top_inner_tab_side(inner_offset);
                }
            }
        }
    }
}

module top_inner_tabs() {
    top_inner_tab();
    mirror([0, 1, 0]) {
        top_inner_tab();
    }
}

module top_button_helper() {
    translate([button_translate_x, button_translate_y, -button_distance + top_depth - thickness]) {
        cylinder(h = button_distance, r = button_dia / 2);
    }
}

