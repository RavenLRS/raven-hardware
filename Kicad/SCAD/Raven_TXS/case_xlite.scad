pcb_z_offset = 11.5;

translate([0, 10.8, pcb_z_offset]) {
	color("lime", 0.5) {
		*import("../../Raven_TXS/Raven_TXS.stl");
	}
}

use <../lib/fillets2d.scad>;
use <../lib/raven.scad>;

debug = false;
fdm = true; // Make some changes to make 3d printing the piece via FDM easier
top_bottom_separation = 15;

PART_BASE = 0;
PART_BOTTOM_TOP = 1;
PART_BOTTOM = 2;
PART_TOP = 3;
PART_SOLID = 4;

PART = PART_BOTTOM_TOP;

thickness = 1.6; // thickness of the case
case_lr_border_radius = 2;
case_tb_border_radius = 1;

bay_height = 41.9; // Pins should line up at the bottom of this
bay_width = 30;
// minimum 4.5
bay_depth = 5.15;

case_width = 30.5 + thickness * 2;
case_width_transition_angle = 60;
case_height = 64 + thickness * 2; // rm9 lite is 62.3
case_depth = 14.85 + bay_depth; // 17,  r9m lite is 15
case_top_depth = 3;

case_bay_bottom_overlap = 1; // How much the case overlaps with the bay base at the bottom (looking from the back of the radio)

pcb_thickness = 1.6;


// Cuts for main rails
rail_width = 2.1;
rail_height = bay_height - 1;
rail_depth = 1.9 + (fdm ? 1 : 0);
rail_width_distance = 1.65;
rail_top_clearance = 1.8;

rail_cut_width = rail_width_distance - 0.2;
rail_cut_opening_height = 4; // r9m lite is ~3mm
rail_cut_height = 7.6; // r9m lite is ~6.6mm
rail_cut_depth = rail_depth - 1;

rail_cut_first_bottom_offset = 2.9;
rail_cut_second_bottom_offset = 22.8;

// Cut for the central clip
clip_cut_width = 10;
clip_cut_height = 2.5;
clip_cut_distance_to_bay = 30.5; // to bottom of pin bay

// Pin bay
pin_count = 8; // Starting from the right (seen from the back)
pin_bay_margin = 4.4;
pin_holder_height = 3; // Plastic length is 2.8mm, everything else should go inside the plastic
pin_width = 2.625;
pin_depth = 2.4;
pin_hole_depth = pin_depth + (fdm ? 0.5 : 0); // Add some space since printing without support will cause some collapsing of the material
pin_hole_dia = 1.4 + (fdm ? 0.6 : 0); // thickest part of the pin is 1.2mm
pin_hole_length = 10;
pin_hole_top_hole_clearance = 0.2; // Extra space from the top hole to expose the pins to the bay
pin_hole_buried_length = 4.4 - 2.8; // 4.4 is from "fat" metal to base, 2.8 is the plastic length

// Screws
screw_dia = 3.2; // This fits M3 screws when 3d printed
screw_pitch = 0.50;
screw_wall_width = 1;
screw_depth = 5;
screw_base_dia = screw_dia + screw_wall_width * 2;
screw_base_rad = screw_base_dia / 2;
screw_head_dia = 5.4;
screw_head_countersunk_angle = 90; // 0 to disable, countersunk screws typically use 82deg. Note that this is the angle of that both sides of the screw form when crossed by a plane parallel to the thread
// Calculate here for BR screw, used by bottom and top parts
screw_x = case_width / 2 - screw_base_rad  - thickness - 1.5;
screw_y = -(case_height - bay_height) + screw_base_rad + thickness + 0.5;
// Screw for joining base and bottom top half
screw_base_y = 22;
screw_base_height = 3;


// Coupling tabs for joining bottom and top
coupling_tab_width = 3;
coupling_tab_height = 3;
coupling_tab_thickness = 1.6;
coupling_tab_x = case_width / 2 - 10;

// Standoffs
standoff_height = pcb_z_offset - 8.6;
standoff_hole_dia = 0.7;
 // on top of the base bay clamp. Intersection is needed for the ones that fall outside
 // the bay clamp projection.
standoff_base_height = -3.5 + pcb_z_offset;
standoff_base_dia = 2;
standoffs = [
	[-13.5, 37.75],
	[13, 37.75],
	[13, -0.75],
	[-13.5, -14.8],
];

screen_center = [0, 8.6];
screen_width = 26.5;
screen_height = 14.7;

led_center = [-0.9, -6.2];
led_dia = 9; // Led is around 5mm, but we increase the diameter to let more light pass

LED_TYPE_PERFORATIONS = 0;
LED_TYPE_LOGO = 1;

led_type = LED_TYPE_LOGO;

// Button
button_dia = 4; // button is 2mm, but we use a bigger cylinder to make it more solid
button_height = 7; // Total height of the button
button_helper_distance = 0.2; // Distance from the top of the button to the bottom of the helper
button_center = [6.6, -7.7];

antenna_hole_dia = 6.8; // antenna screw is around 5.8
antenna_nut_height = 8; // 8mm as measured with the caliper from opposing sides

//$fn = 36;
$fa = 0.1;
$fs = 0.1;

// Calculated variables
case_width_transition_delta = case_width - bay_width;
case_width_transition_depth = tan(90 - case_width_transition_angle) * case_width_transition_delta;

bay_clamp_screw = PART == PART_BASE;
bay_clamp_top_rails = bay_clamp_screw;
bottom_top_floor = PART == PART_BOTTOM_TOP;

 {
	if (PART == PART_BASE || PART == PART_BOTTOM_TOP || PART == PART_BOTTOM || PART == PART_SOLID) {
		union() {
			if (PART != PART_BOTTOM_TOP) {
				bottom_case_bottom();
			}
			if (PART != PART_BASE) {
				bottom_case_top();
			}
		}
	}
	if (PART == PART_TOP || PART == PART_SOLID) {
		translate([0, 0, PART == PART_TOP ? 0 : top_bottom_separation]) {
			union() {
				top_case();
			}
		}
	}
}

/* BOTTOM CASE */

module bottom_case_polygon(delta) {
	translate([-delta, 0, 0]) {
		polygon([
			[0, 0],
			[case_width + delta * 2, 0],
			[case_width + delta * 2 - case_width_transition_delta / 2, case_width_transition_depth],
			[case_width_transition_delta / 2, case_width_transition_depth]
		]);
	}
}

module bottom_case_top_transition(tz) {
	union() {
		difference() {
			intersection() {
				translate([0, 0, -case_width_transition_depth]) {
					hull() {
						translate([0, 0, case_width_transition_depth]) {
							linear_extrude(height=0.01) {
								rounding2d(case_tb_border_radius) {
									square([case_width, case_height]);
								}
							}
						}
						linear_extrude(height=thickness) {
							translate([case_width_transition_delta / 2, 0]) {
								square([bay_width, case_height]);
							}
						}
					}
				}
				rotate([-90, 0, 0]) {
					linear_extrude(height=case_height) {
						bottom_case_polygon(0);
					}
				}
			}
			rotate([-90, 0, 0]) {
				translate([0, 0, thickness]) {
					linear_extrude(height=case_height - thickness * 2) {
						bottom_case_polygon(-thickness);
					}
				}
			}
			// Remove top plane
			translate([thickness, thickness, -0.005]) {
				cube([case_width - thickness * 2, case_height - thickness * 2, 0.01]);
			}
			// Remove bottom plane
			translate([(case_width - bay_width) / 2 + thickness, thickness, -case_width_transition_depth - 0.005]) {
				cube([bay_width - thickness * 2, case_height - thickness * 2, 0.01]);
			}
		}
		// Bottom plane
		bpl = case_height - bay_height + case_bay_bottom_overlap - case_tb_border_radius;
		translate([(case_width - bay_width) / 2, 0, -case_width_transition_depth]) {
			cube([bay_width, bpl, thickness]);
		}
		// Radius for the bottom plane
		translate([bay_width + thickness, bpl - 0.01, -thickness]) {
			rotate([0, -90, 0]) {
				union() {
					intersection() {
						cylinder(r=case_tb_border_radius, h=bay_width);
						cube([case_tb_border_radius, case_tb_border_radius, bay_width]);
					}
					translate([-thickness + case_tb_border_radius, 0, 0]) {
						cube([thickness - case_tb_border_radius, case_tb_border_radius, bay_width]);
					}
				}
			}
		}
	}
}

module bottom_case_top_transition_floor() {
	// Generate floor for the top half of the bottom
	cl = pin_hole_length + pin_hole_buried_length;
	translate([0, 0, -case_width_transition_depth]) {
		union() {
			difference() {
				translate([-bay_width / 2, cl, 0]) {
					cube([bay_width, bay_height - cl, thickness]);
				}
				translate([0, 0, -0.01]) {
					screw_passthrough([0, screw_base_y, 0], bay_depth, screw_dia, screw_head_dia, bay_depth, clearance=-0.5, head_clearance=-0.5);
				}
				copy_mirror([1, 0, 0]) {
					translate([bay_width / 2 - thickness * 2 - 0.25, screw_base_y, -0.01]) {
						scale([1, 1, 1.1]) {
							cube([thickness + 0.5, pin_hole_length + thickness, thickness]);
						}
					}
				}
			}
			translate([0, screw_base_y * 2, screw_base_height]) {
				rotate([180, 0, 0]) {
					screw_receptacle([0, screw_base_y, 0], screw_base_height, screw_dia, screw_pitch, screw_wall_width, screw_depth, approx=debug);
				}
			}
		}
	}
}
			

module bottom_standoffs() {
	translate([0, 0, -case_width_transition_depth - thickness]) {
		for (s = standoffs) {
			standoff([s[0], s[1], 0], standoff_height, standoff_hole_dia / 2,  standoff_base_height, standoff_base_dia / 2);
		}
	}
}

module screw_head_hole(xy, height) {
	d = screw_head_dia + thickness;
	difference() {
		translate([xy[0], xy[1], 0]) {
			cylinder(d=d, h=height);
		}
		ch = height - thickness;
		if (screw_head_countersunk_angle > 0) {
			translate([xy[0], xy[1], -0.01]) {
				d1 = screw_head_dia + 0.5;
				d2 = screw_dia + 0.5;
				csh = tan(90 - screw_head_countersunk_angle / 2) * (d1 - d2);
				union() {
					translate([0, 0, ch - csh]) {
						cylinder(d1=d1, d2=d2, h=csh + 0.01);
					}
					cylinder(d=d1, h=ch - csh + 0.01);
				}
			}
		} else {
			// Add some sacrificial bridging for fdm, since we don't
			// have an angle to rely on without a countersunk screw
			sc_br = fdm ? 0.1 : 0;
			translate([xy[0], xy[1], -0.01 - sc_br]) {
				cylinder(d=screw_head_dia + 0.5, h=ch + 0.01);
			}
		}
		translate([xy[0], xy[1], ch - 0.01]) {
			cylinder(d=screw_dia + 0.5, h=thickness + 0.02);
		}
	}
}

module bottom_screws(height) {
	copy_mirror([1, 0, 0]) {
		screw_head_hole([screw_x, screw_y], height);
	}
}

module bottom_coupling_tabs() {
	copy_mirror([1, 0, 0]) {
		translate([coupling_tab_x, bay_height - thickness, case_depth - bay_depth - case_width_transition_depth]) {
			rotate([90, 90, 0]) {
				linear_extrude(height=coupling_tab_width, scale=0.5) {
					square([coupling_tab_thickness, coupling_tab_height]);
				}
			}
		}
    }
}

module bottom_case_top_intersection_body() {
	union() {
		rotate_x_translate(90, [0, bay_height, -case_width_transition_depth]) {
			linear_extrude(height=case_height) {
				polygon([
					[-bay_width / 2, 0],
					[bay_width / 2, 0],
					[case_width / 2, case_width_transition_depth],
					[case_width / 2, case_depth - bay_depth],
					[-case_width / 2, case_depth - bay_depth],
					[-case_width / 2, case_width_transition_depth],
				]);
			}
		}
		// If we're generating 2 separate pieces for the base
		// we have a solid at the bottom of the extruded polygon
		// so we don't need the standoffs to meet the base
		if (!bottom_top_floor) {
			translate([-bay_width / 2, 0, -(bay_depth + case_width_transition_depth)]) {
				cube([bay_width, bay_height, bay_depth]);
			}
		}
	}
}

module bottom_case_top() {
	th = bay_depth + case_width_transition_depth;
	translate([0, 0, th]) {
		union() {
			difference() {
				union() {
					translate([-case_width / 2, -(case_height - bay_height), 0]) {
						bottom_case_top_transition(th);
					}
					if (bottom_top_floor) {
						bottom_case_top_transition_floor();
					}
				}
				// Holes for screws
				copy_mirror([1, 0, 0]) {
					sh = pcb_z_offset - bay_depth;
					rotate_x_translate(180, [0, screw_y * 2, sh - thickness - 0.9]) {
						screw_passthrough([screw_x, screw_y, 0], sh, screw_dia, screw_head_dia, sh);
					}
				}
			}
			translate([0, 0, -case_width_transition_depth + thickness]) {
				bottom_screws(pcb_z_offset - bay_depth - thickness);
			}
			// Standoffs
			intersection() {
				// Extend standoffs until they touch a solid
				bottom_case_top_intersection_body();
				bottom_standoffs();
			}
			// Case shell
			difference() {
				eh = case_depth - bay_depth - case_width_transition_depth;
				translate([-case_width / 2, -(case_height - bay_height), 0]) {
					linear_extrude(height=eh) {
						difference() {
							rounding2d(case_tb_border_radius) {
								square([case_width, case_height]);
							}
							offset(-thickness) {
								square([case_width, case_height]);
							}
						}
					}
				}
				// Antenna hole
				rotate_x_translate(90, [0, bay_height + 0.005, eh]) {
					cylinder(r = antenna_hole_dia / 2, h = thickness + 0.01);
				}
				// Side fittings from top half
				translate([0, 0, eh]) {
					top_case_enclosure_side_fittings(delta=0.01, hdelta=1);
				}
			}
			// Coupling tabs for top/bottom join
			bottom_coupling_tabs();
		}
	}
}

module bay_clip_cut() {
	translate([-clip_cut_width / 2, clip_cut_distance_to_bay, 0]) {
		cube([clip_cut_width, clip_cut_height, bay_depth - thickness * 2]);
	}
}

module bay_clamp() {
    difference() {
        translate ([-bay_width / 2, 0, 0]) {
            linear_extrude(height=bay_depth) {
                square([bay_width, bay_height]);
            }
        }
        copy_mirror([1, 0, 0]) {
            bay_clamp_rail();
        }
		bay_clip_cut();
		pin_bay();
		// Top hole
		top_hole_width = bay_width - thickness * 2;
		top_hole_height = bay_height - pin_hole_buried_length - pin_holder_height - thickness;
		top_hole_y = pin_holder_height + pin_hole_buried_length;
		top_hole_z = rail_depth + thickness;
		translate([-top_hole_width / 2, top_hole_y, top_hole_z]) {
			cube([top_hole_width, top_hole_height, bay_depth]);
		}
		// Connect the top hole with the pin holes
		pin_top_hole_width = pin_count * pin_width;
		translate([-pin_top_hole_width / 2, top_hole_y, thickness]) {
			cube([pin_top_hole_width, top_hole_height, bay_depth]);
		}
    }
	if (fdm) {
		// These help support the bridge across the pin bay while printing.
		// Using slicer generated supports makes them too difficult to remove
		copy_mirror([1, 0, 0]) {
			union() {
				copy_translate([0, pin_holder_height / 2, 0]) {
					st = pin_width / 2 * pin_count - 1;
					cube([st, 0.6, 0.6]);
					for (sc = [st:-2.5:0]) {
						translate([sc, 0.3, 0]) {
							union() {
								cylinder(h = pin_hole_depth, r = 0.3);
								cylinder(h = pin_hole_depth, r = 0.1);
							}
						}
					}
				}
			}
		}
	}
}

module bottom_case_bottom() {
	union() {
		difference() {
			bay_clamp();
			if (bay_clamp_screw) {
				translate([0, 0, -0.01]) {
					screw_passthrough([0, screw_base_y, 0], bay_depth, screw_dia, screw_head_dia, bay_depth);
				}
			}
		}
		if (bay_clamp_screw) {
			screw_head_hole([0, screw_base_y], bay_depth);
		}
		if (bay_clamp_top_rails) {
			copy_mirror([1, 0, 0]) {
				rl = pin_hole_length + thickness - 0.5;
				rz = bay_depth - 1;
				rh = thickness + 1;
				translate([bay_width / 2 - thickness * 2, case_bay_bottom_overlap + 0.25, rz]) {
					cube([thickness, rl - case_bay_bottom_overlap, rh]);
				}
				translate([bay_width / 2 - thickness * 2, screw_base_y + 0.25, rz]) {
					cube([thickness, rl, rh]);
				}
			}
		}
	}
}

module pin_bay() {
	translate([bay_width / 2 - pin_bay_margin - pin_width, 0, 0]) {
		for (p = [0:1:pin_count - 1]) {
			translate([-pin_width * p, 0, 0]) {
				union() {
					translate([0, -0.01, -0.01]) {
						cube([pin_width, pin_holder_height + 0.01, pin_hole_depth + 0.01]);
					}
					translate([pin_width / 2, 0, pin_depth / 2]) {
						rotate([-90, 0, 0]) {
							union() {
								h = pin_holder_height + pin_hole_length;
								cylinder(h = h, r = pin_hole_dia / 2);
								if (fdm) {
									// Make the cuts a semicircle that extends up to the upper plane
									ch = pin_depth / 2 + (pin_hole_depth - pin_depth);
									translate([-pin_hole_dia / 2, -ch, 0]) {
										cube([pin_hole_dia, ch, h]);
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

module bay_clamp_rail_cut(delta, support) {
    translate([rail_width_distance, 0, delta]) {
        union() {
            cube([rail_cut_width, rail_depth + 0.1, rail_cut_opening_height]);
			if (!support) {
				translate([0, 0, rail_cut_opening_height - 0.1]) {
					cube([rail_cut_width, rail_cut_depth, rail_cut_height + 0.1]);
				}
			}
        }
    }
}

module bay_clamp_rail(support=false) {
    union() {
        translate([bay_width / 2 - rail_width_distance - rail_width, -0.1, rail_depth]) {
            rotate([-90, 0, 0]) {
                linear_extrude(height=rail_height - rail_top_clearance * 0.1) {
                    square([rail_width, rail_depth + 0.1]);
                }
                bay_clamp_rail_cut(rail_cut_first_bottom_offset, support);
                bay_clamp_rail_cut(rail_cut_second_bottom_offset, support);
            }
        }
    }
}

/* TOP CASE */
module top_case_coupling_tab_holder_side(delta) {
	offset(delta=delta) {
        square([coupling_tab_thickness, coupling_tab_height]);
    }
}

module top_case_coupling_tab_holders() {
	copy_mirror([1, 0, 0]) {
		inner_offset = 0.2;
		outer_offset = inner_offset + 1;
		holder_thickness = outer_offset - inner_offset;
		translate([coupling_tab_x, bay_height - thickness, case_depth - holder_thickness]) {
			union() {
				jch = coupling_tab_thickness + outer_offset * 2;
				jcw = coupling_tab_height + outer_offset * 2;
				translate([-outer_offset, -jch, holder_thickness]) {
					cube([jcw, jch, case_top_depth + thickness]);
				}
				translate([0, 0, outer_offset - inner_offset]) {
					rotate([90, 90, 0]) {
						linear_extrude(height = jch) {
							difference() {
								rounding2d(1) {
									top_case_coupling_tab_holder_side(outer_offset);
								}
								top_case_coupling_tab_holder_side(inner_offset);
							}
						}
					}
				}
			}
		}
    }
}

module top_case_enclosure_side_fittings(delta=0, hdelta=0) {
	h = 5;
	d = case_height - thickness * 4 + hdelta;
	copy_mirror([1, 0, 0]) {
		
		translate([case_width / 2 - thickness - delta, -case_height + bay_height + (case_height - d) / 2, -h + delta]) {
			cube([thickness / 2 + delta, d, h + delta]);
		}
	}
}

module top_case_enclosure_body() {
	tx = -case_width / 2;

	module top_case_side() {
		union() {
			rounding2d(case_lr_border_radius) {
				square([case_width, case_top_depth + thickness]);
			}
			square([case_width, case_top_depth + thickness - case_lr_border_radius]);
		}
	}
	
	module top_side_closing() {
		intersection() {
			union() {
				translate([0, 0, -0]) {
					minkowski() {
						linear_extrude(height=thickness-case_tb_border_radius) {
							offset(delta=-case_tb_border_radius) {
								top_case_side();
							}
						}
						sphere(case_tb_border_radius);
					}
				}
				sd = case_lr_border_radius * 4;
				rotate_x_translate(90, [0, case_tb_border_radius, -sd + thickness]) {
					linear_extrude(height=case_tb_border_radius) {
						rounding2d(case_tb_border_radius) {
							square([case_width, sd]);
						}
					}
				}
			}
			linear_extrude(height=thickness) {
				top_case_side();
			}
		}
	}
	
	translate([tx, -case_height + bay_height, 0]) {
		union() {
			rotate_x_translate(90, [0, case_height, 0]) {
				union() {
					translate([0, 0, thickness]) {
						linear_extrude(height=case_height - thickness * 2) {
							difference() {
								shell(thickness - 0.01) {
									top_case_side();
								}
								translate([thickness, 0]) {
									square([case_width - thickness * 2, thickness]);
								}
							}
						}
					}
					rotate_y_translate(180, [case_width, 0, thickness]) {
						top_side_closing();
					}
					translate([0, 0, case_height - thickness - 0.01]) {
						top_side_closing();
					}
				}
			}
		}
	}
}

module top_case_enclosure() {

	module top_case_screws() {
		screw_height = case_depth + case_top_depth - pcb_z_offset + thickness;
		copy_mirror([1, 0, 0]) {
			rotate_x_translate(180, [0, screw_y * 2, case_top_depth + thickness]) {
				screw_receptacle([screw_x, screw_y, 0], screw_height, screw_dia, screw_pitch, screw_wall_width, screw_depth, approx=debug);
			}
		}
	}
	
	translate([0, 0, case_depth]) {
		union() {
			difference() {
				top_case_enclosure_body();
				diff_z = case_top_depth - 0.005;
				diff_h = thickness + 0.01;
				ah = 10;
				rotate_x_translate(90, [0, bay_height + 0.005, 0]) {
					cylinder(r = antenna_hole_dia / 2, h = ah);
					translate([0, 0, thickness + 0.01]) {
						cylinder(r = antenna_nut_height / 2 * 2 / sqrt(3), h = 2, $fn=6);
					}
				}
				// Screen
				translate([-screen_width / 2 + screen_center[0], - screen_height / 2 + screen_center[1], diff_z]) {
					linear_extrude(height=diff_h) {
						rounding2d(1) {
							square([screen_width, screen_height]);
						}
					}
				}
				// LED
				if (led_type == LED_TYPE_PERFORATIONS) {
					perforations([led_center[0], led_center[1], diff_z], diff_h, led_dia / 2, min_r = 3.5, step=2.5, pr=0.3);
				} else if (led_type == LED_TYPE_LOGO) {
					translate([-8.5, -20, case_top_depth]) {
						linear_extrude(height=thickness - 0.2) {
							difference() {
								shell(0.7) {
									scale([0.1, 0.1]) {
										import("../images/raven_0.dxf");
									}
								}
								translate([7.5, 0]) {
									square([1, 20]);
								}
								translate([0, 7.5]) {
									square([20, 1]);
								}
							}
						}
					}
				}
			}
			top_case_screws();
			translate([0, 0, 0.001]) {
				top_case_enclosure_side_fittings();
			}
		}
	}
}

module top_case() {
	button_distance = case_depth + case_top_depth - button_height - pcb_thickness - pcb_z_offset - button_helper_distance;
	button_helper([button_center[0], button_center[1], case_depth + case_top_depth], button_dia, button_distance, thickness, thickness / 2, zr=-90) {
		union() {
			top_case_enclosure();
			top_case_coupling_tab_holders();
		}
	}
}
