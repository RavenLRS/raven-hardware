include <jr_vars.scad>

use <fillets2d.scad>;
use <raven.scad>;
use <threads.scad>

/******** ANTENNA MOUNT ********/
module jr_antenna_mount(antenna, debug=false)
{
    base_width = antenna[0];
    base_height = antenna[1];
    mount_height = antenna[2];
    mount_length = antenna[3];

	snap_fit_thickness = THICKNESS * 3;

	module mount_base_polygon(delta) {
		angle = 60;
		offset(delta=delta) {
			polygon([
				[0, 0],
				[mount_length + THICKNESS * 2, 0],
				[mount_length + THICKNESS * 2, mount_height],
				[(mount_height) * tan(90 - angle), mount_height],
			]);
		}
	}

	module mount_polygon() {
		bx = -base_width / 2;
		jx = -ANTENNA_MOUNT_WIDTH / 2;
		copy_mirror([1, 0, 0]) {
			polygon([
				[0, 0],
				[bx, 0],
				[bx,  base_height],
				[jx,  base_height - (bx - jx)],
				[jx, mount_length],
				[0, mount_length],
			]);
		}
	}
		
	module mount_snap_fit_solid(zr) {
		rotate([-90, 0, zr]) {
			linear_extrude(height=snap_fit_thickness) {
				polygon([
					[0, -3],
					[0, 0],
					[0, THICKNESS * 2],
					[1.8, THICKNESS],
					[1, THICKNESS],
					[1, -4],
				]);
			}
		}
	}
	
	module mount_snap_fit(xy, zr) {
		translate([base_width / 2 - 1 + xy[0], BAY_COVER_HEIGHT / 2 - THICKNESS * 2 - base_height + xy[1], TOTAL_DEPTH + THICKNESS]) {
			mount_snap_fit_solid(zr);
		}
	}

    module mount_body_logo(antenna)
    {
        img = "../images/raven_0.dxf";
        img_w = 170;
        img_h = 200;
        sc = 0.07;
        // 2 layers on top, one on the bottom for bridinging
        rem = LAYER_HEIGHT * 3;
        h = mount_body_radius - rem;
        translate([0, antenna[2] + THICKNESS, antenna[2] + mount_body_radius + LAYER_HEIGHT / 2]) {
            linear_extrude(height=h) {
                difference() {
                    translate([-img_w / 2 * sc, 0]) {
                        scale([sc, sc]) {
                            import(img);
                        }
                    }
                    /*
                    translate([-0.25, 0]) {
                        square([0.5, img_h * sc]);
                    }
                    translate([0, img_h / 2 * sc]) {
                        square([img_w * sc, 0.5], center=true);
                    }
                    */
                }
            }
        }
    }
		
	mount_body_radius = 1;
		
	module mount_body() {
		module back_triangle() {
			translate([-base_width / 2 - 0.01, 0, -1]) {
                h = mount_height + THICKNESS * 2;
				rotate([90, 0, 90]) {
					linear_extrude(height=base_width + 0.02) {
						polygon([
							[-1, 0],
							[-1, h + 1],
							[h + 1, h + 1],
						]);
					}
				}
			}
		}

        union() {
            difference() {
                translate([0, 0, mount_body_radius]) {                 
                    minkowski() {
                        difference() {
                            linear_extrude(height=mount_height) {
                                mount_polygon();
                            }
                            back_triangle();
                        }
                        sphere(r=mount_body_radius, center=true, $fn=debug ? 8 : 32);
                    }
                }
                translate([0, -mount_body_radius, -THICKNESS + mount_body_radius]) {
                    difference() {
                        linear_extrude(height=mount_height + THICKNESS) {
                            rounding2d(1) {     
                                mount_polygon();
                            }
                        }
                        back_triangle();
                    }
                }
                mount_body_logo(antenna);
            }
        }
        // Bottom cover
        linear_extrude(height=THICKNESS) {
            intersection() {
                mount_polygon();
                translate([-base_width / 2, base_height]) {
                    square([base_width, mount_length]);
                }
            }
        }
        // Undo the fillet at the bottom
        translate([0, 0, 0]) {
            linear_extrude(height=mount_body_radius) {
                intersection() {
                    shell(mount_body_radius)
                    offset(mount_body_radius) {
                        intersection() {
                            mount_polygon();
                            translate([-base_width / 2, 0]) {
                                square([base_width, base_height]);
                            }
                        }
                    }
                }
            }
        }
	}

    function antenna_top_screw_od() = SCREW_DIA + THICKNESS;

    module antenna_top_screw() {
        od = antenna_top_screw_od();
        or = od / 2;
        sh = THICKNESS;
        translate([base_width / 2 - od / 2, -or, 0]) {
            difference() {
                linear_extrude(height=sh) {
                    union() {
                        circle(d=od);
                        translate([0, 0]) {
                            square(or);
                        }
                        translate([-or, 0]) {
                            square(or);
                        }
                        translate([0, -or]) {
                            square(or);
                        }
                    }
                }
                translate([0, 0, sh + 0.01]) {
                    mirror([0, 0, 1]) {
                        screw_thread(sh + 0.02, debug);
                    }
                }
            }
        }
    }
    module antenna_screws() {
        copy_mirror([1, 0, 0]) {
            translate([0, base_height, 0]) {
                antenna_top_screw();
            }
            mirror([0, 1, 0]) {
                translate([0, , 0]) {
                    antenna_top_screw();
                }
            }
        }
    }
    translate([0, BAY_COVER_HEIGHT / 2 - antenna[1] - ANTENNA_DEFAULT_TOP_DISTANCE, TOTAL_DEPTH + BAY_COVER_DEPTH - 0.01]) {
        union() {
            difference() {
                mount_body();
                rotate_x_translate(90, [0, mount_length + mount_body_radius, (mount_height + THICKNESS) / 2]) {
                    cylinder(d=ANTENNA_HOLE_DIA, h = THICKNESS * 2);
                }
            }
            antenna_screws();
        }
    }
}

module jr_case_top_guides()
{
    guide_tolerance = 0.5;
    guide_width = THICKNESS;
    guide_r = 0.5;
    copy_mirror([0, 1, 0]) {
        copy_mirror([1, 0, 0]) {
            translate([0, 0, -THICKNESS]) {
                translate([-CASE_WIDTH / 2 + guide_width + guide_tolerance, -CASE_HEIGHT / 2 + guide_width + guide_tolerance, 0]) {
                    linear_extrude(height=THICKNESS) {
                        fillet2d(guide_r) {
                            rounding2d(guide_r) {
                                union() {
                                    square([guide_width, CASE_GUIDE_LENGTH]);
                                    square([CASE_GUIDE_LENGTH, guide_width]);
                                }    
                            }
                        }
                    }
                }
            }
        }
    }
}


/******** TOP OF THE CASE ********/
module jr_case_top(pcb_z_offset, screws=[],
    screw_head_dia=-1, screw_head_countersunk_angle=0,
    button=[], screen=[],
    antenna=[], debug=false)
{
    translate([0, 0, BAY_DEPTH]) {
        union() {
            case_cover_top(pcb_z_offset, screws, screw_head_dia,
                button, screen, antenna, debug);

            for (screw = screws) {
                case_top_screw(pcb_z_offset, screw, debug);
            }
            copy_mirror([1, 0, 0]) {
                st = BAY_COVER_HEIGHT / 2 - ANTENNA_DEFAULT_TOP_DISTANCE;
                translate([0, st, 0]) {
                    case_cover_top_antenna_screw(antenna, screw_head_dia,
                        screw_head_countersunk_angle, debug);
                }
                translate([0, st - antenna[1], 0]) {
                    mirror([0, 1, 0]) {
                        case_cover_top_antenna_screw(antenna, screw_head_dia,
                            screw_head_countersunk_angle, debug);
                    }
                }
            }
            // Place a few guides to help placing the top cover
            jr_case_top_guides();
        }
    }
}

module case_cover_top_antenna_screw(antenna, screw_head_dia,
    screw_head_countersunk_angle, debug)
{
    h = SCREW_DEPTH - THICKNESS;
    d = SCREW_DIA + THICKNESS;
    r = d / 2;
    translate([antenna[0] / 2 - d / 2, -r, -h + THICKNESS]) {
        difference() {
            linear_extrude(height=h) {
                union() {            
                    circle(d=d);
                    square(r);
                    translate([-r, 0]) {
                        square(r);
                    }
                    translate([0, -r]) {
                        square(r);
                    }
                    translate([0, -r]) {
                        square(d);
                    }
                }
            }
            translate([0, 0, h + 0.01]) {
                mirror([0, 0, 1]) {
                    screw_thread(h + 0.02, debug);
                }
            }
        }
    }
}

module case_cover_top(pcb_z_offset, screws, screw_head_dia,
    button, screen, antenna, debug)
{
    linear_extrude(height=BAY_COVER_DEPTH) {
        intersection() {
            rounding2d(BAY_CORNER_ROUNDING) {
                    square([BAY_COVER_WIDTH, BAY_COVER_HEIGHT], center=true);
            }
            rounding2d(BAY_ROUNDING) {
                difference() {
                    case_cover_2d(base=false, smooth=true);
                    // Button hole
                    translate([button[0], button[1]]) {
                        circle(d=button[2]);
                    }
                    // Screen hole
                    translate([screen[0], screen[1]]) {
                        corner_radius = screen[4] == undef ? SCREEN_DEFAULT_CORNER_RADIUS : screen[4];
                        rounding2d(corner_radius) {
                            square([screen[2], screen[3]], center=true);
                        }
                    }
                    // Antenna base hole
                    translate([0, BAY_COVER_HEIGHT / 2 - antenna[1] / 2 - ANTENNA_DEFAULT_TOP_DISTANCE]) {
                        rounding2d(ANTENNA_DEFAULT_CORNER_RADIUS) {
                            square([antenna[0], antenna[1]], center=true);
                        }
                    }
                }
            }
        }
    }
}

module case_top_screw(pcb_z_offset, xy, debug)
{
    h = BAY_DEPTH - pcb_z_offset - BOARD_THICKNESS;
    od = SCREW_DIA + THICKNESS;
    sl = SCREW_DEPTH + 0.01;
    translate([xy[0], xy[1], 0]) {
        mirror([0, 0, 1]) {
            difference() {
                cylinder(d=od, h=h);
                translate([0, 0, h - SCREW_DEPTH]) {
                    screw_thread(sl, debug);
                }
            }
        }
    }
}

/******** BOTTOM OF THE CASE ********/

// pcb_z_offset: Offset from the bottom of the PCB from 0
// screws: coordinates for each screw, in [x, y] form
// screw_head_dia: diameter of the head of the screw
// screw_head_countersunk_angle: angle that both sides of the screw form
//  when crossed by a plane parallel to the thread. Use 0 to disable.
module jr_case_base(pcb_z_offset, screws=[],
    screw_head_dia=-1, screw_head_countersunk_angle=0,
    debug=false)
{
    union() {
        case_base(pcb_z_offset, screws, screw_head_dia,
            screw_head_countersunk_angle, debug);
        case_snap_fits();
    }
}


/******** CASE COVER ********/

module case_cover_2d(delta=0, base=true, smooth=false)
{
    r = smooth ? BAY_ROUNDING : 0;
    cr = smooth ? BAY_CORNER_ROUNDING : 0;
    w = base ? CASE_WIDTH : BAY_COVER_WIDTH;
    h = base ? CASE_HEIGHT : BAY_COVER_HEIGHT;
    extra_hole_width = base ? 0 : (BAY_COVER_WIDTH - CASE_WIDTH) / 2;
    intersection() {
        rounding2d(cr) {
            square([w, h], center=true);
        }
        fillet2d(r) {
            rounding2d(r) {
                offset(delta=delta) {
                    difference() {
                        square([w, h], center=true);
                        copy_mirror([1, 0, 0]) {
                            // Snap fit holes
                            case_snap_fit_hole_2d(extra_width=extra_hole_width);
                        }
                    }
                }
            }
        }
    }
}

/******** CASE BASE ********/

function screw_cylinder_inner_dia(screw_head_dia) = screw_head_dia + SCREW_HEAD_TOLERANCE;
function screw_wall_thickness() = INNER_THICKNESS;
function screw_cylinder_dia(screw_head_dia) = screw_cylinder_inner_dia(screw_head_dia) + screw_wall_thickness() * 2;


module case_base(pcb_z_offset, screws,
    screw_head_dia, screw_head_countersunk_angle, debug)
{
    // Make the holder a bit lower than the pcb_z_offset
    // to leave some space for the soldering of the
    // connector pads.
    connector_holder_height = max(pcb_z_offset - 3, 0);
    module connector_base()
    {
        square([CONNECTOR_SIZE[0] + CONNECTOR_TOLERANCE[0], CONNECTOR_SIZE[1] + CONNECTOR_TOLERANCE[1]], center=true);
    }
    module case_base_shell_bottom_hole(x, y)
    {
        translate([x, y, -0.01]) {
            linear_extrude(height=TOTAL_DEPTH + 0.02) {
                children();
            }
        }
    }
    module case_base_shell() {
        difference() {
            linear_extrude(height=TOTAL_DEPTH) {
                case_cover_2d(base=true, smooth=true);
            }
            // Make a shell out of the case
            translate([0, 0, THICKNESS]) {
                linear_extrude(height=TOTAL_DEPTH - THICKNESS + 0.01) {
                    case_cover_2d(-THICKNESS, base=true, smooth=true);
                }
            }
            // Hole for the 5pin connector
            case_base_shell_bottom_hole(CONNECTOR_DISTANCE[0], CONNECTOR_DISTANCE[1]) {
                connector_base();
            }
            // Holes for screws
            for (screw = screws) {
                case_base_shell_bottom_hole(screw[0], screw[1]) {
                    circle(d=screw_head_dia + SCREW_HEAD_TOLERANCE);
                }
            }
            // Opening for the pigtail
            pr = THICKNESS * 0.7;
            translate([0, CASE_HEIGHT / 2 - THICKNESS, THICKNESS]) {
                cylinder(r=pr, h=TOTAL_DEPTH);
            }
        }
    }
    module case_base_connector_holder()
    {
        difference() {
            linear_extrude(height=connector_holder_height) {
                translate([CONNECTOR_DISTANCE[0], CONNECTOR_DISTANCE[1]]) {
                    difference() {
                        rounding2d(BAY_ROUNDING) {
                            offset(CONNECTOR_HOLDER_THICKNESS) {
                                connector_base();
                            }
                        }
                        connector_base();
                    }
                }
            }
            // Make sure we don't overlap any screw insides
            id = screw_cylinder_inner_dia(screw_head_dia);
            for (screw = screws) {
                translate([screw[0], screw[1], -0.01]) {
                    cylinder(d=id, h=pcb_z_offset + 0.02);
                }
            }
        }
    }
    module case_base_connector_guide()
    {
        guide_height = pcb_z_offset - 7.5;
        translate([CONNECTOR_DISTANCE[0], CONNECTOR_DISTANCE[1]]) {
            w = CONNECTOR_SIZE[0] + CONNECTOR_TOLERANCE[0];
            h = CONNECTOR_SIZE[1] + CONNECTOR_TOLERANCE[1];
            difference() {
                linear_extrude(height=guide_height) {
                    square([w, h], center=true);
                }
                for (c = [-2.54 * 2:2.54:2.54*2]) {
                    translate([0, c, -0.01]) {
                        cylinder(d1=2.5, d2=1.5, h=guide_height + 0.02);
                    }
                }
            }
        }
    }

    union() {
        case_base_shell();
        case_base_connector_holder();
        case_base_connector_guide();
        for (screw = screws) {
            difference() {
                case_base_screw(pcb_z_offset, screw,
                    screw_head_dia, screw_head_countersunk_angle,
                    debug);

                // Make sure no base screw overlaps the connector holder
                translate([CONNECTOR_DISTANCE[0], CONNECTOR_DISTANCE[1], 0]) {
                    linear_extrude(height=TOTAL_DEPTH) {
                        offset(CONNECTOR_HOLDER_THICKNESS) {
                            connector_base();
                        }
                    }
                }
            }
        }
    }
}

module case_base_screw(pcb_z_offset, xy, screw_head_dia,
    screw_head_countersunk_angle, debug)
{
    od = screw_cylinder_dia(screw_head_dia);
    id = screw_cylinder_inner_dia(screw_head_dia);
    height = pcb_z_offset;
    screw_top_wall_thickness = INNER_THICKNESS;
	difference() {
		translate([xy[0], xy[1], 0]) {
			cylinder(d=od, h=height);
		}
		ch = height - screw_top_wall_thickness;
		if (screw_head_countersunk_angle > 0) {
			translate([xy[0], xy[1], -0.01]) {
                cch = SCREW_COUNTERSUNK_NO_EXTRA_MATERIAL ? ch + screw_top_wall_thickness : ch;
				d1 = id;
				d2 = SCREW_DIA + SCREW_TOLERANCE;
				csh = tan(90 - screw_head_countersunk_angle / 2) * (d1 - d2);
				union() {
					translate([0, 0, cch - csh]) {
						cylinder(d1=d1, d2=d2, h=csh + 0.01);
					}
					cylinder(d=d1, h=cch - csh + 0.01);

                    if (SCREW_COUNTERSUNK_NO_EXTRA_MATERIAL) {
                        translate([0, 0, height - csh]) {
                            difference() {
                                et = screw_wall_thickness() * 2;
                                cylinder(d=od + 0.01, h=height - csh);
                                cylinder(d1=d1 + et, d2=d2 + et, h=csh + 0.01);
                            }
                        }
                    }
				}
			}
		} else {
			// Add some sacrificial bridging for fdm, since we don't
			// have an angle to rely on without a countersunk screw
			sc_br = FDM ? 0.1 : 0;
			translate([xy[0], xy[1], -0.01 - sc_br]) {
				cylinder(d=id, h=ch + 0.01);
			}
		}
		translate([xy[0], xy[1], ch - 0.01]) {
			cylinder(d=SCREW_DIA + SCREW_TOLERANCE, h=screw_top_wall_thickness + 0.02);
		}
	}
}


/******** SNAP FITS ********/

function case_snap_fit_bay_width() = SNAP_CUT_WIDTH - THICKNESS;
function case_snap_fit_xt() = CASE_WIDTH / 2 - case_snap_fit_bay_width() / 2;
function case_snap_fit_yt() = SNAP_CUT_VERTICAL_OFFSET;


module case_snap_fit_hole_2d(extra_width=0)
{
    translate([case_snap_fit_xt() + extra_width / 2,case_snap_fit_yt()]) {
        w = case_snap_fit_bay_width() + extra_width;
		square([w, SNAP_CUT_HEIGHT], center=true);
    }
}

module case_snap_fit()
{
    // Draw right snap fit, then it will get mirrored
    base_width = case_snap_fit_bay_width();
    tab_base_width = base_width - SNAP_CUT_TAB_BASE_HORIZONTAL_DISTANCE;
    tab_top_width = base_width - SNAP_CUT_TAB_WIDTH_PROTUBERANCE + SNAP_CUT_TAB_WIDTH_PROTUBERANCE_RECESSION_DELTA;
    tab_height = TOTAL_DEPTH + BAY_COVER_DEPTH - THICKNESS;
    tab_protuberance_top = tab_height - SNAP_CUT_PROTUBERANCE_TOP_DISTANCE;
    tab_protuberance_bottom = tab_height - SNAP_CUT_PROTUBERANCE_BASE_DISTANCE;
    top_x = tab_base_width - tab_top_width;
    tab_length = SNAP_CUT_HEIGHT - SNAP_CUT_TAB_VERTICAL_DISTANCE * 2;
    hat_x = tab_base_width + SNAP_CUT_TAB_HAT_WIDTH_PROTUBERANCE;
    hat_y_delta = (hat_x + tab_base_width) * sin(SNAP_CUT_TAB_HAT_UNDER_ANGLE);
    hat_depth = BAY_COVER_DEPTH / 2;
    hat_y_end = tab_height - hat_depth - hat_y_delta;
    tab_corner_rounding = 0.5;

    module tab_polygon() {
        polygon([
            [0, 0],
            [top_x, tab_height],
            [hat_x, tab_height],
            [hat_x, tab_height - hat_depth],
            [tab_base_width, hat_y_end],
            [tab_base_width, tab_protuberance_top],
            [tab_base_width + SNAP_CUT_TAB_WIDTH_PROTUBERANCE, tab_protuberance_top],
            [tab_base_width, tab_protuberance_bottom],
            [tab_base_width, 0],
        ]);
    }

    module tab_hinge_side_polygon(w, hinge_y) {
        polygon([
            [0, 0],
            [0, hinge_y],
            [w, SNAP_CUT_TAB_HINGE_HEIGHT],
            [w, 0],
        ]);
    }

    module tab_hinge_side() {
        r = 0.5;
        angle = 80;
        ty = tab_base_width * tan(90 - angle);
        hinge_y = ty + SNAP_CUT_TAB_HINGE_HEIGHT;
        w = tab_base_width / 2 - SNAP_CUT_TAB_HINGE_WIDTH / 2;
        fillet2d(r) {
            union() {
                rounding2d(r) {
                    tab_hinge_side_polygon(w, hinge_y);
                }
                intersection() {
                    tab_hinge_side_polygon(w, hinge_y);
                    square([r * 2, hinge_y]);
                }
                square([0.01, hinge_y + r]);
            }
        }
    }

    module tab_body() {
        rotate([90, 0, 0]) {
            linear_extrude(height=tab_length) {
                difference() {
                    union() {
                        fillet2d(tab_corner_rounding) {
                            rounding2d(tab_corner_rounding) {
                                tab_polygon();
                            }
                        }
                        intersection() {
                            tab_polygon();
                            square([tab_base_width, tab_corner_rounding]);
                        }
                        translate([-SNAP_CUT_TAB_BASE_HORIZONTAL_DISTANCE + 0.01, 0]) {
                            difference() {
                                square(SNAP_CUT_TAB_BASE_HORIZONTAL_DISTANCE);
                                translate([0, SNAP_CUT_TAB_BASE_HORIZONTAL_DISTANCE]) {
                                    circle(r=SNAP_CUT_TAB_BASE_HORIZONTAL_DISTANCE);
                                }
                            }
                        }
                    }
                    if (SNAP_CUT_TAB_HINGE_WIDTH > 0) {
                        hw = SNAP_CUT_TAB_HINGE_WIDTH;
                        translate([0, 0]) {
                            tab_hinge_side();
                        }
                        translate([tab_base_width, 0]) {
                            mirror([1, 0]) {
                                tab_hinge_side();
                            }
                        }
                    }
                }
            }                    
        }
    }

    module tab_body_intersection() {
        iw = tab_base_width + SNAP_CUT_TAB_HAT_WIDTH_PROTUBERANCE + SNAP_CUT_TAB_BASE_HORIZONTAL_DISTANCE;
        translate([-SNAP_CUT_TAB_BASE_HORIZONTAL_DISTANCE, -tab_length, 0]) {
            union() {
                linear_extrude(height=tab_protuberance_bottom) {
                    rounding2d(BAY_ROUNDING) {
                        square([tab_base_width, tab_length]);
                    }
                }
                translate([0, 0, tab_protuberance_bottom]) {
                    hull() {
                        linear_extrude(height=0.01) {
                            rounding2d(BAY_ROUNDING) {
                                square([tab_base_width, tab_length]);
                            }
                        }
                        translate([0, 0, SNAP_CUT_PROTUBERANCE_BASE_DISTANCE - SNAP_CUT_PROTUBERANCE_TOP_DISTANCE]) {
                            linear_extrude(height=0.01) {
                                rounding2d(BAY_ROUNDING) {
                                    square([tab_base_width + SNAP_CUT_TAB_WIDTH_PROTUBERANCE, tab_length]);
                                }
                            }
                        }
                    }                    
                }
                translate([0, 0, tab_protuberance_bottom]) {
                    linear_extrude(height=hat_y_end - tab_protuberance_bottom) {
                        rounding2d(BAY_ROUNDING) {
                            square([tab_base_width, tab_length]);
                        }
                    }
                }
                translate([-BAY_CORNER_ROUNDING * 2, 0, hat_y_end]) {
                    linear_extrude(height=tab_height - hat_y_end) {
                        rounding2d(BAY_CORNER_ROUNDING) {
                            square([iw + BAY_CORNER_ROUNDING * 2, tab_length]);
                        }
                    }
                }
            }
        }
    }

    translate([case_snap_fit_xt(), case_snap_fit_yt(), 0]) {
        union() {
            // Draw the base
            linear_extrude(height=THICKNESS) {
                union() {
                    bh = SNAP_CUT_HEIGHT - SNAP_CUT_TAB_VERTICAL_DISTANCE * 2;
                    rounding2d(BAY_ROUNDING) {
                        square([base_width, bh], center=true);
                    }
                    translate([-base_width / 2 - 0.001, -bh / 2]) {
                        square([base_width / 2, bh]);
                    }
                }
            }
            // Draw the main tab
            translate([base_width / 2 - tab_base_width, tab_length / 2, THICKNESS - 0.01]) {
                intersection() {
                    tab_body();
                    tab_body_intersection();
                }
            }
        }
    }
}

module case_snap_fits()
{
	copy_mirror([1, 0, 0]) {
		case_snap_fit();
	}
}

module screw_thread(h, debug)
{
    if (debug) {
        cylinder(d=SCREW_DIA, h=h);
    } else {
        metric_thread(SCREW_DIA, SCREW_PITCH, h);
    }
}