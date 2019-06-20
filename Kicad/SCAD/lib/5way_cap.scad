include <jr_vars.scad>

use <fillets2d.scad>;
use <raven.scad>;

CAP_RADIUS = 5;
CAP_HALF_RADIUS = CAP_RADIUS / 2;

CAP_RING_RADIUS = 3;
CAP_RING_HEIGHT = 2;
CAP_RING_TOLERANCE = 0.5;

CAP_RING_TAB_SIZE = 1;
CAP_RING_TAB_TOLERANCE_FACTOR = 1.2;

function jr_5way_button_cap_cylinder_dia(stick) = max(stick[0], stick[1]) + THICKNESS;
function jr_5way_button_cap_clearance(stick, radius) = radius * 2 * sin(stick[4]);
function jr_5way_button_cap_zoffset(pcb_z_offset, stick) = pcb_z_offset + BOARD_THICKNESS + stick[3];

function jr_5way_button_cap_translation(pcb_z_offset, button_pos, stick) = [button_pos[0], button_pos[1], jr_5way_button_cap_zoffset(pcb_z_offset, stick)];

module jr_5way_button_cap(pcb_z_offset, button_pos, stick, debug=false)
{
    cap_clearance = jr_5way_button_cap_clearance(stick, CAP_RADIUS);
    od = jr_5way_button_cap_cylinder_dia(stick);

    module jr_5way_button_cap_top() {
        difference() {
            union() {
                cylinder(d=od, h=od);
                translate([0, 0, 1]) {
                    sphere(d=od + 1);
                }
            }
            translate([0, 0, 1]) {
                translate([0, 0, od * 0.9]) {
                    cube(od, center=true);
                }
                sd = od - 0.5;
                translate([0, 0, 0.2 * sd]) {
                    sphere(d=sd);
                }
            }
        }
    }

    stick_base_offset = stick[3];
    stick_hole_height = stick[2] - stick_base_offset - 0.5;
    zoffset = jr_5way_button_cap_zoffset(pcb_z_offset, stick);
    ch = TOTAL_DEPTH + BAY_COVER_DEPTH - zoffset + cap_clearance;
    union() {
        translate(jr_5way_button_cap_translation(pcb_z_offset, button_pos, stick)) {
            union() {
                difference() {
                    cylinder(d=od, h=ch);
                    translate([0, 0, -0.01]) {
                        linear_extrude(height=stick_hole_height + 0.01) {
                            square([stick[0], stick[1]], center=true);
                        }
                    }
                }
                translate([0, 0, ch - 0.01]) {
                    jr_5way_button_cap_top();
                }
            }
        }
        jr_5way_button_cap_ring(pcb_z_offset, button_pos, stick, debug);
    }
}

module jr_5way_button_cap_ring(pcb_z_offset, button_pos, stick, debug=false)
{
    od = jr_5way_button_cap_cylinder_dia(stick);
    hole_dia = od + CAP_RING_TOLERANCE;
    cap_clearance = jr_5way_button_cap_clearance(stick, CAP_RING_RADIUS);
    total_height = CAP_RING_HEIGHT + cap_clearance;
    translate([button_pos[0], button_pos[1], TOTAL_DEPTH - CAP_RING_HEIGHT - cap_clearance]) {
        difference() {
            // Main solid
            hull() {
                cylinder(r=CAP_RING_RADIUS, h=CAP_RING_HEIGHT);
                translate([0, 0, total_height]) {
                    cylinder(d=od, h=0.01);
                }
            }
            // Center hole
            /*translate([0, 0, -0.01]) {
                cylinder(d=hole_dia, h=total_height + 0.03);
            }*/
        }
    }
}
