//Generate the base of the case
CaseBase = true;
// Generate the antenna mount too
AntennaMount = true;

debug = true;

board_width = 43.5;
board_height = 59.5;
board_thickness = 1.6;
board_back_height = 4.1; // how much the biggest component in the back comes out (the LoRa module in this case)

raiser_height = 5; // actual component height from the bottom is around 4.3mm
raiser_top_height = 3;

hole_dia = 3.1;

bay_cover_width = 48.8 - 0.5; // measured - tolerance
bay_cover_height = 64 - 0.5;
bay_cover_depth = 1.9 - 0.3;
bay_cover_rounding = 1;
bay_cover_corner_rounding = 2;


top_hole_top_distance = 2.1;
top_hole_side_distance = 2.0;

bottom_hole_bottom_distance = 2.0; // hole is centered horizontally

connector_bottom_clearance = 16.5; // ~16.1mm plus some tolerance
connector_side_clearance = 10; // this is measured to the THT pins in the connector deeper inside the PCB, so it's like 2mm more than required

// Screw hole parameters
screw_dia = 3.2; // This fits M3 screws when 3d printed
screw_pitch = 0.50;
screw_wall_width = 1;
screw_depth = 5;

// Button
button_bottom_distance = 4.7; // from the center of the button
button_left_distance = 8.7; // from the center of the button
button_hole_dia = 4.5;

// Screen
screen_center_x_offset = -0.25;
screen_bottom_distance = 14.8;
screen_size = [26.5, 14.8];

// Snap fit
snap_cut_height = 19.7;
snap_cut_vertical_offset = 0.5; // The tabs are 0.5mm up from the center
snap_cut_side_distance = 6.4; // from cover side to inner side of the cut
snap_cut_outer_side_distance = 2; // to the outer side out of the cut
snap_cut_depth = 12.3;
snap_cut_thickness = 1.2;
snap_cut_tab_horizontal_distance = 1.3; // from cut to tab, was 0.8mm
snap_cut_tab_vertical_distance = 1.2;
snap_tab_top_width = 5; // width of the top "hat"
snap_tab_protuberance_top_distance = 3;
snap_tab_protuberance_width = 1.5; // was 1mm

// Antenna
antenna_mount_size = [19, 23, 13];
antenna_mount_height = 40; // from the base of the mount (looking from the back of the radio) - should be ~20mm more than the pigtail length
antenna_mount_protruding_width = 13; // width of the antenna after it leaves the case
antenna_hole_dia = 6.8; // antenna screw is around 5.8

// Walls
wall_thickness = 0.8;
wall_rounding = 0.3;
sma_wall_cut_x = -6.5; // mm from center
sma_wall_cut_length = 14;



// Bay
bay_width = 44.5;
bay_height = 60;
bay_depth = 19.8;

total_depth = bay_depth - board_thickness - board_back_height;


use <../lib/fillets2d.scad>;
use <../lib/raven.scad>;

thickness = 1.6;

$fn = 360;

union() {
	if (CaseBase) {
		case_cover();
		bottom_screws();
	}
	if (AntennaMount) {
		case_cover_antenna_mount();
	}
}

module bottom_screw(center) {
	rotate_y_translate(180, [0, 0, total_depth]) {
		screw_receptacle([center[0], center[1], 0], total_depth, screw_dia, screw_pitch, screw_wall_width, screw_depth, approx=debug);
	}
}

module bottom_screws() {
	top_x = board_width / 2 - top_hole_side_distance - hole_dia / 2;
	top_y = board_height / 2 - top_hole_top_distance - hole_dia / 2;
	bottom_y = -board_height / 2 + bottom_hole_bottom_distance + hole_dia / 2;
	bottom_screw([top_x, top_y]);
	bottom_screw([-top_x, top_y]);
	bottom_screw([0, bottom_y]);
}

module case_cover_snap_fit_hole_2d(delta=0)
{
	snap_fit_translate_y = snap_cut_vertical_offset;
	translate([bay_cover_width / 2 - snap_cut_side_distance / 2, snap_fit_translate_y]) {
		square([snap_cut_side_distance, snap_cut_height], center=true);
	}
}

module case_cover_2d(delta=0)
{
	offset(delta=delta) {
		difference() {
			square([bay_cover_width, bay_cover_height], center=true);
			copy_mirror([1, 0, 0]) {
				// Snap fit holes
				case_cover_snap_fit_hole_2d(delta);
			}
		}
	}
}

module case_cover_top()
{
	translate([0, 0, total_depth]) {
		linear_extrude(height=bay_cover_depth) {
			intersection() {
				union() {
					band = 10; // Used to make the outer corners have different radius
					rounding2d(bay_cover_corner_rounding) {
						translate([0, bay_cover_height / 2 - band / 2]) {
							square([bay_cover_width, band], center=true);
						}
					}
					rounding2d(bay_cover_corner_rounding) {
						translate([0, -bay_cover_height / 2 + band / 2]) {
							square([bay_cover_width, band], center=true);
						}
					}
					square([bay_cover_width, bay_cover_height - (band - bay_cover_corner_rounding) * 2], center=true);
				}
				rounding2d(bay_cover_rounding) {
					difference() {
						case_cover_2d();
						// Button hole
						button_r = button_hole_dia / 2;
						button_x = -board_width / 2 + button_left_distance;
						button_y = -board_height / 2 + button_bottom_distance;
						translate([button_x, button_y]) {
							circle(r=button_r);
						}
						// Screen hole
						screen_translate_y = -board_height / 2 + screen_size[1] / 2 + screen_bottom_distance;
						translate([screen_center_x_offset, screen_translate_y]) {
							rounding2d(1) {
								square([screen_size[0], screen_size[1]], center=true);
							}
						}
						// Antenna base hole
						translate([0, bay_height / 2 - antenna_mount_size[1] / 2 - thickness]) {
							square([antenna_mount_size[0], antenna_mount_size[1]], center=true);
						}
					}
				}
			}
		}
	}
}

module case_cover_snap_fit_bay_base(reduce_w=0, reduce_h=0, forced_w=-1)
{
	w = snap_cut_side_distance - snap_cut_outer_side_distance + snap_cut_thickness - reduce_w;
	h = snap_cut_height + snap_cut_thickness * 2 - reduce_h;
	ew = forced_w > 0 ? forced_w : w;
	et = forced_w > 0 ? forced_w / 2 : 0;
	translate([bay_cover_width / 2 - w / 2 - snap_cut_outer_side_distance + et, snap_cut_vertical_offset]) {
		square([ew, h], center=true);
	}
}

module case_cover_snap_fit_bay()
{
	linear_extrude(height=snap_cut_depth) {
		intersection() {
			rounding2d(bay_cover_rounding) {
				case_cover_2d();
			}
			case_cover_snap_fit_bay_base();
		}
	}
	linear_extrude(height=snap_cut_thickness) {
		case_cover_snap_fit_bay_base();
	}
}

module case_cover_snap_fit_tab()
{
	reduce_w = snap_cut_tab_horizontal_distance + thickness;
	reduce_h = (snap_cut_tab_vertical_distance + thickness) * 2;
	union() {
		linear_extrude(height=snap_cut_depth) {
			case_cover_snap_fit_bay_base(reduce_w, reduce_h);
		}
		tab_z = snap_cut_depth - bay_cover_depth;
		translate([0, 0, tab_z]) {
			linear_extrude(height=bay_cover_depth) {
				rounding2d(1) {
					case_cover_snap_fit_bay_base(reduce_w, reduce_h, forced_w=snap_tab_top_width);
				}
			}
			ph = snap_cut_height + snap_cut_thickness * 2 - reduce_h;
			th = snap_cut_depth - snap_tab_protuberance_top_distance - snap_cut_thickness - bay_cover_depth;

			rotate_x_translate(-90, [bay_cover_width / 2 - snap_cut_outer_side_distance, -ph / 2 + snap_cut_vertical_offset, -tab_z + th + snap_cut_thickness]) {
				linear_extrude(height=ph) {
					polygon([
						[0, 0],
						[snap_tab_protuberance_width, 0],
						[0, th],
					]);
				}
			}
		}
	}
}

module case_cover_snap_fit()
{
	translate([0, 0, total_depth-snap_cut_depth + thickness]) {
		union() {
			case_cover_snap_fit_bay();
			case_cover_snap_fit_tab();
		}
	}
}

module case_cover_snap_fits()
{
	copy_mirror([1, 0, 0]) {
		case_cover_snap_fit();
	}
}

module case_cover_walls()
{
	translate([0, 0, total_depth - snap_cut_depth]) {
		linear_extrude(height=snap_cut_depth) {
			// Intersect with the case base polygon to avoid
			// the walls running into the side snap fit tabs
			intersection() {
				difference() {
					rounding2d(wall_rounding) {
						shell(wall_thickness) {
						square([board_width, board_height], center=true);
						}
					}
					// Small cut for the SMA nut
					translate([sma_wall_cut_x, board_height / 2 - wall_thickness / 2]) {
						square([sma_wall_cut_length, wall_thickness + 0.02], center=true);
					}
				}
				case_cover_2d();
			}
		}
	}
}

module case_cover_antenna_mount()
{
	snap_fit_thickness = thickness * 3;

	module mount_base_polygon(delta) {
		angle = 60;
		offset(delta=delta) {
			polygon([
				[0, 0],
				[antenna_mount_height + thickness * 2, 0],
				[antenna_mount_height + thickness * 2, antenna_mount_size[2]],
				[(antenna_mount_size[2]) * tan(90 - angle), antenna_mount_size[2]],
			]);
		}
	}
	module mount_polygon() {
		bx = -antenna_mount_size[0] / 2;
		jx = -antenna_mount_protruding_width / 2;
		copy_mirror([1, 0, 0]) {
			polygon([
				[0, 0],
				[bx, 0],
				[bx,  antenna_mount_size[1]],
				[jx,  antenna_mount_size[1] - (bx - jx)],
				[jx, antenna_mount_height],
				[0, antenna_mount_height],
			]);
		}
	}
		
	module mount_snap_fit_solid(zr) {
		rotate([-90, 0, zr]) {
			linear_extrude(height=snap_fit_thickness) {
				polygon([
					[0, -3],
					[0, 0],
					[0, thickness * 2],
					[1.8, thickness],
					[1, thickness],
					[1, -4],
				]);
			}
		}
	}
	
	module mount_snap_fit(xy, zr) {
		translate([antenna_mount_size[0] / 2 - 1 + xy[0], bay_cover_height / 2 - thickness * 2 - antenna_mount_size[1] + xy[1], total_depth + thickness]) {
			mount_snap_fit_solid(zr);
		}
	}
	
	module mount_snap_fits() {
		// This one needs to be trimmed a bit, otherwise the
		// antenna connector won't pass
		difference() {
			mount_snap_fit([-antenna_mount_size[0] / 2 + snap_fit_thickness / 2 + 1, antenna_mount_size[1] - 1], 90);
			translate([-5, bay_height / 2 - thickness * 2, total_depth + thickness * 2]) {
				cube([10, 10, 10]);
			}
		}
		mount_snap_fit([-antenna_mount_size[0] / 2 - snap_fit_thickness / 2 + 1, 1], -90);
		copy_mirror([1, 0, 0]) {
			mount_snap_fit([0, 0], 0);
			mount_snap_fit([0, antenna_mount_size[0] / 2], 0);
		}
		// Don't mirror this one, since it would touch the SMA
		mount_snap_fit([0, antenna_mount_size[0] - snap_fit_thickness / 2], 0);
	}
	
	mount_body_radius = 1;
		
	module mount_body() {
		module back_triangle() {
			translate([-antenna_mount_size[0] / 2 - 0.01, antenna_mount_size[2], 0]) {
				rotate([0, -90, 180]) {
					linear_extrude(height=antenna_mount_size[0] + 0.02) {
						polygon([
							[-1, 0],
							[-1, antenna_mount_size[2]],
							[antenna_mount_size[2] + 1, antenna_mount_size[2] + 1],
						]);
					}
				}
			}

		}
		rotate([90, 90, 0]) {
			translate([0, 0, -total_depth - thickness]) {
				union() {
					difference() {
						translate([0, 0, 0]) {
							minkowski() {
								difference() {
									linear_extrude(height=antenna_mount_size[2]) {
										offset(delta=0) {
											mount_polygon();
										}
									}
									back_triangle();
								}
								sphere(r=mount_body_radius, center=true, $fn=debug ? 8 : 32);
							}
						}
						translate([0, 0, 0]) {
							difference() {
								linear_extrude(height=antenna_mount_size[2] + thickness) {
									rounding2d(1) {
										offset(delta=0) {
											mount_polygon();
										}
									}
								}
								back_triangle();
							}
						}				
					}
				}
				// Bottom cover
				translate([0, 0, antenna_mount_size[2] - thickness + mount_body_radius]) {
					linear_extrude(height=thickness) {
						intersection() {
							mount_polygon();
							translate([-antenna_mount_size[0] / 2, antenna_mount_size[1]]) {
								square([antenna_mount_size[0], antenna_mount_height]);
							}
						}
					}
				}
				// Undo the fillet at the bottom
				translate([0, 0, antenna_mount_size[2] - thickness + mount_body_radius]) {
					linear_extrude(height=thickness) {
						intersection() {
							shell(mount_body_radius)
							offset(mount_body_radius) {
								intersection() {
									mount_polygon();
									translate([-antenna_mount_size[0] / 2, 0]) {
										square([antenna_mount_size[0], antenna_mount_size[1]]);
									}
								}
							}
						}
					}
				}
			}
		}
	}
	union() {
		translate([0, bay_height / 2 - antenna_mount_size[1] - thickness, total_depth]) {
			rotate([90, 0, 90]) {
				difference() {
					mount_body();
					rotate_y_translate(90, [antenna_mount_height - thickness, antenna_mount_size[2] / 2 + thickness + mount_body_radius, 0]) {
						cylinder(d=antenna_hole_dia, h = thickness * 2);
					}
				}
			}
		}
		if (!CaseBase) {
			mount_snap_fits();
		}
	}
}


module case_cover()
{
	union() {
		case_cover_top();
		case_cover_walls();
		case_cover_snap_fits();
	}
}

module bottom_case_base()
{
	linear_extrude(height=thickness) {
		rounding2d(1) {
			difference() {
				square([board_width, board_height], center=true);
				translate([(board_width - connector_side_clearance) / 2 , -(board_height - connector_bottom_clearance) / 2]) {
					square([connector_side_clearance, connector_bottom_clearance], center=true);
				}
			}
		}
	}
}
