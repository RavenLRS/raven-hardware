min_wall_thickness = 1.6;

standoff_hole_dia = 2.8;
standoff_dia = 2.3;
standoff_raiser_height = 1;
//standoff_height = standoff_raiser_height + 3.2; // This aligns the top of the standoff with the screen top
width = 27.3;
height = 27;

pins_width = 11.5;
pins_height = 2.6;

OLED_SUPPORT_FIT_DIA = 1.5;
OLED_SUPPORT_FIT_MARGIN = 1;
OLED_SUPPORT_Y_OFFSET = 2.45;

BOTTOM_HELPER_HEIGHT = 3;
BOTTOM_HELPER_PINS_HEIGHT = 4;
BOARD_HELPER_THICKNESS = 1;

ESP32_HEIGHT = 3.1;

PINS_BACKSIDE = false;
HIPOWER_CUT = false;

include <jr_vars.scad>;

use <fillets2d.scad>;
use <raven.scad>;

function jr_oled_top_thickness(pcb_z_offset, oled_z_offset) = oled_z_offset - pcb_z_offset - (BOARD_THICKNESS + ESP32_HEIGHT + standoff_raiser_height);
function jr_oled_top_z(pcb_z_offset, oled_z_offset) = oled_z_offset - jr_oled_top_thickness(pcb_z_offset, oled_z_offset) - standoff_raiser_height;

module jr_oled_support_base(thickness)
{
    linear_extrude(height=thickness) {
        difference() {
            rounding2d(1) {
                square([width, height], center=true);
            }
            translate([0, (height - pins_height) / 2]) {
                square([pins_width, pins_height], center=true);
            }
        }
    }
}

module jr_oled_fit_standoffs(pcb_z_offset, oled_z_offset, extra_dia=0, extra_height=0)
{
    fit_height = jr_oled_top_thickness(pcb_z_offset, oled_z_offset) / 2 + extra_height;
    copy_mirror([1, 0, 0]) {
        tx = width / 2 - OLED_SUPPORT_FIT_DIA / 2 - OLED_SUPPORT_FIT_MARGIN;
        ty = height / 2 - OLED_SUPPORT_FIT_DIA / 2 - OLED_SUPPORT_FIT_MARGIN;
        translate([tx, ty, 0]) {
            cylinder(d=OLED_SUPPORT_FIT_DIA + extra_dia, h=fit_height);
        }
    }
}

module jr_oled_support_top(pcb_z_offset, oled_z_offset, screen)
{
    thickness = jr_oled_top_thickness(pcb_z_offset, oled_z_offset);

    module standoff() {
        // Distances to the border of the PCB
        width_d = 1.85;
        height_d = 0.5;
        standoff_height = TOTAL_DEPTH - jr_oled_top_z(pcb_z_offset, oled_z_offset) - thickness - 0.1;
        translate([width / 2 - standoff_hole_dia / 2 - width_d, height / 2 - standoff_hole_dia / 2 - height_d, thickness]) {
            union() {
                cylinder(d=standoff_dia, h=standoff_height);
                cylinder(d=standoff_dia + 1, h=standoff_raiser_height);
            }
        }
    }

    module standoffs() {
        mirror([1, 0, 0]) {
            mirror([0, 1, 0]) {
                standoff();
            }
        }
        mirror([0, 1, 0]) {
            standoff();
        }
        copy_mirror([1, 0, 0]) {
            standoff();
        }
    }

    module hipower_module_cut() {
        cw = (width - pins_width) / 2 - min_wall_thickness;
        ch = 8;
        cd = 20;
        translate([-(width / 2 - cw / 2) - 0.01, height / 2 - ch / 2 + 0.01, cd / 2 - 0.01]) {
            cube([cw, ch, cd], center=true);
        }
    }

    module pins_backside() {
        pt = min_wall_thickness;
        
        module backside() {
            translate([0, height / 2 + pt / 2, thickness / 2]) {
                cube([pins_width, pt, thickness], center=true);
            }
        }
        
        module join() {
            translate([pins_width / 2, height / 2, 0]) {
                intersection() {
                    cylinder(r=pt, h=thickness);
                    cube([pt, pt, thickness]);
                
                }
            }
        }
        union() {
            backside();
            join();
            mirror([1, 0, 0]) {
                join();
            }
        }
    }

    translate([screen[0], screen[1] + OLED_SUPPORT_Y_OFFSET, jr_oled_top_z(pcb_z_offset, oled_z_offset)]) {
        rotate([0, 0, 180]) {
            difference() {
                union() {
                    jr_oled_support_base(thickness);
                    standoffs();
                    if (PINS_BACKSIDE) {
                        pins_backside();
                    }
                }
                if (HIPOWER_CUT) {
                    hipower_module_cut();
                }
                translate([0, 0, -0.01]) {
                    jr_oled_fit_standoffs(pcb_z_offset, oled_z_offset, extra_dia=0.5, extra_height=0.5);
                }
            }
        }
    }
}

module jr_oled_support_bottom(pcb_z_offset, oled_z_offset, screen)
{
    bottom_z = pcb_z_offset + BOARD_THICKNESS;
    bottom_thickness = jr_oled_top_z(pcb_z_offset, oled_z_offset) - bottom_z;
    translate([screen[0], screen[1] + OLED_SUPPORT_Y_OFFSET, bottom_z]) {
        union() {
            rotate([0, 0, 180]) {
                intersection() {
                    jr_oled_support_base(bottom_thickness);
                    union() {
                        translate([0, (height - BOTTOM_HELPER_HEIGHT) / 2, bottom_thickness / 2]) {
                            cube([width, BOTTOM_HELPER_HEIGHT, bottom_thickness], center=true);
                        }
                        translate([0, (height - BOTTOM_HELPER_PINS_HEIGHT) / 2, bottom_thickness / 2]) {
                            cube([pins_width + 1, BOTTOM_HELPER_PINS_HEIGHT, bottom_thickness], center=true);
                        }
                    }
                }
                translate([0, 0, bottom_thickness - 0.01]) {
                    jr_oled_fit_standoffs(pcb_z_offset, oled_z_offset);
                }
            }
        }
    }
}

module jr_oled_support_helper(pcb_z_offset, oled_z_offset, screen) {
    bottom_z = pcb_z_offset + BOARD_THICKNESS;
    bottom_thickness = jr_oled_top_z(pcb_z_offset, oled_z_offset) - bottom_z;
    hw = 3;
    hl = screen[1] + 16.95;
    helper_z = bottom_thickness - BOARD_HELPER_THICKNESS;
    difference() {
        translate([screen[0], screen[1] - height / 2 + OLED_SUPPORT_Y_OFFSET - hl, bottom_z]) {
            tx = width / 2 - hw;
            bhh = 1;
            copy_mirror([1, 0]) {
                union() {
                    translate([tx, 0, 0]) {
                        linear_extrude(height=bottom_thickness) {
                            square([hw, 1]);
                        }
                    }
                    translate([0, -bhh, -BOARD_THICKNESS]) {
                        linear_extrude(height=bottom_thickness + BOARD_THICKNESS) {
                            square([tx + hw, bhh]);
                        }
                    }
                    translate([tx, 0, helper_z]) {
                        linear_extrude(height=BOARD_HELPER_THICKNESS) {
                            square([hw, hl]);
                        }
                    }
                    translate([tx, hl - hw, helper_z]) {
                        linear_extrude(height=BOARD_HELPER_THICKNESS) {
                            square([hw * 2, hw * 3]);
                        }
                    }
                }
            }
        }
        linear_extrude(height=bottom_z + bottom_thickness + 0.01) {
            offset(delta=0.25) {
                projection() {
                    jr_oled_support_bottom(pcb_z_offset, oled_z_offset, screen);
                }
            }
        }
    }
}
