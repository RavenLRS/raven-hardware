use <threads.scad>;
use <fillets2d.scad>;

/* Create several small perforations on a circular pattern at
 * the given xyz point where a solid of height h starts.
 */
module perforations(xyz, h, r, min_r = 0, step = 0.5, pr=0.15) {
    translate([xyz[0], xyz[1], xyz[2]]) {
        led_perforation_steps = 1;
        for (d = [min_r:step:r]) {
            led_perforation_steps = max(1, 2 * d);
            for (s = [0:led_perforation_steps - 1]) {
                angle = s * (360 / led_perforation_steps);
                translate([cos(angle) * d, sin(angle) * d, 0]) {
                    cylinder(h=h, r=pr);
                }
            }
        }
    }
}

/* Create a standoff of height h with a base of height base_h, for
 * a total height of (h + base_h). The radius of the base and standoff
 * are specified by r and base_r. The top part extrusion scale can be
 * adjusted by the scale argument.
 */
module standoff(xyz, h, r, base_h, base_r, scale = 0.5) {
    translate([xyz[0], xyz[1], xyz[2]]) {
        union() {
            cylinder(h = base_h, r = base_r);
            translate([0, 0, base_h]) {
                linear_extrude(height = h, scale = scale) {
                    circle(r = r);
                }
            }
        }
    }
}

/* Analogous to mirror, but creates a copy of its children rather than
 * moving the original nodes.
 */
module copy_mirror(vec=[0, 0, 0]) {
    children();
    mirror(vec) {
        children();
    }
}

module copy_translate(vec=[0, 0, 0]) {
    children();
    translate(vec) {
        children();
    }
}

module shell(thickness) { 
    difference(){ 
        children(); 
        offset(-thickness) {
            children();
        } 
    }
}

module xy_mirror(orig=true, x=false, y=false, xy=false, all=false) {
    if (orig || all) {
        children();
    }
    if (x || all) {
        mirror([1, 0, 0]) {
            children();
        }
    }
    if (y || all) {
        mirror([0, 1, 0]) {
            children();
        }
    }
    if (xy || all) {
        mirror([1, 0, 0]) {
            mirror([0, 1, 0]) {
                children();
            }
        }
    }
}

use <threads.scad>;

/* Creates a vertical screw receptacle at xyz determined by its total height h, screw
 * diameter dia, screw pitch pitch and wall thickness around the screw thread  wall_thickness.
 * Optionally, walls can be added to the receptacle by using the walls argument, which takes
 * the form of an array of either [angle, width, length] or just angle. If wall width
 * is <= 0 or undef, the wall will have the width equal to the receptacle diameter. If length
 * is <= 0 or undef, it's assumed to be zero. The length is counted from the outside of the
 * receptacle.
 * To make development easier, the approx argument can be used to replace the screw thread with
 * just a cylinder to make rendering faster.
 */
module screw_receptacle(xyz, h, dia, pitch, wall_thickness, depth, walls=[], approx=false) {
    translate([xyz[0], xyz[1], xyz[2]]) {
        difference() {
            linear_extrude(height = h) {
                r = (dia / 2) + wall_thickness;
                union() {
                    circle(r = r);
                    for (w = walls) {
                        angle = w[0] == undef && len(w) == undef ? w : w[0];
                        thickness = w[1] == undef || w[1] <= 0 ? dia + wall_thickness * 2 : w[1];
                        length = r + (w[2] == undef ? 0 : w[2]);
                        rotate([0, 0, -angle]) {
                            translate([-thickness / 2, 0, 0]) {
                                square([thickness, length]);
                            }
                        }
                    }
                }
            }
            translate([0, 0, h - depth]) {
                // Avoid z-fighting
                d = depth + 0.1;
                if (approx) {
                    cylinder(h = d, r = dia / 2);
                } else {
                    metric_thread(dia, pitch, d);
                }
            }
        }        
    }
}

module m3_screw_receptacle(xyz, h, wall_thickness, depth, walls=[], approx=false) {
    // This fits M3 screws when 3d printed
    dia = 3.2;
    pitch = 0.50;
    screw_receptacle(xyz, h, dia, pitch, wall_thickness, depth, walls, approx);
}

/* Create a hole for a screw of diameter dia to pass through of total height h, making some
 * space for the screw head, as specified by head_dia and head_h (< h).
 */
module screw_passthrough(xyz, h, dia, head_dia, head_h, clearance = 0.5, head_clearance = 0.5) {
    translate([xyz[0], xyz[1], xyz[2]]) {
        linear_extrude(height = h + 0.01) {
            circle(r = (dia + clearance) / 2);
        }
        translate([0, 0, h - head_h]) {
            linear_extrude(height = head_h + 0.01) {
                circle(r = (head_dia + head_clearance) / 2);
            }
        }
    }
}

module shell2d(width, outer=false) {
    if (outer) {
        difference() {
            offset(delta=width) {
                children();
            }
            children();
        }
    } else {
        difference() {
            children();
            offset(delta=-width) {
                children();
            }
        }
    }
}

module rotate_x(angle) {
    rotate([angle, 0, 0]) {
        children();
    }
}

module rotate_y(angle) {
    rotate([0, angle, 0]) {
        children();
    }
}

module rotate_z(angle) {
    rotate([0, 0, angle]) {
        children();
    }
}

module rotate_x_translate(angle, vec=[0, 0, 0]) {
    translate(vec) {
        rotate_x(angle) {
            children();
        }
    }
}

module rotate_y_translate(angle, vec=[0, 0, 0]) {
    translate(vec) {
        rotate_y(angle) {
            children();
        }
    }
}

module rotate_z_translate(angle, vec=[0, 0, 0]) {
    translate(vec) {
        rotate_z(angle) {
            children();
        }
    }
}

module _button_helper_cut_base(delta, button_dia, length) {
    offset(delta=delta) {
        circle(r=button_dia / 2);
        translate([-button_dia / 2, 0]) {
            square([button_dia, length]);
        }
    }
}

module button_helper(xyz, button_dia, height, thickness, bend_thickness = 0, cut_width=0.5, cut_length=0, zr=0) {
    t = [xyz[0], xyz[1], xyz[2] - height];
    union() {
        difference() {
            children();
            translate(t) {
                rotate([0, 0, zr]) {
                    translate([0, 0, height - 0.005]) {
                        cl = cut_length > 0 ? cut_length : button_dia;
                        linear_extrude(height=thickness + 0.01) {
                            difference() {
                                _button_helper_cut_base(cut_width, button_dia, cl);
                                _button_helper_cut_base(0, button_dia, cl);
                                translate([-button_dia/2, cl]) {
                                    square([button_dia, cut_width]);
                                }
                            }
                        }
                        if (bend_thickness > 0) {
                            translate([-button_dia / 2, cl, -0.005]) {
                                cube([button_dia, cut_width, bend_thickness]);
                            }
                        }
                    }
                }
            }
        }
        translate([t[0], t[1], t[2] + 0.01]) {
            cylinder(h = height + 0.01, r = button_dia / 2);
        }
    }
}

module masked_rounding2d(r, t) {
    union() {
        difference() {
            children(0);
            translate([t[0] * r, t[1] * r]) {
                children(1);
            }
        }
        rounding2d(r) {
            intersection() {
                children(0);
                children(1);
            }
        }
    }
}
