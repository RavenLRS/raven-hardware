min_wall_thickness = 1.6;
thickness = 4.5;

standoff_hole_dia = 2.8;
standoff_dia = 2.3;
standoff_raiser_height = 1;
standoff_height = 3.5;
//standoff_height = standoff_raiser_height + 3.2; // This aligns the top of the standoff with the screen top
width = 27.3;
height = 27;

pins_width = 11.5;
pins_height = 2.6;

PINS_BACKSIDE = true;
HIPOWER_CUT = true;

$fn = 72;

use <../lib/fillets2d.scad>;

difference() {
	union() {
		base();
		standoffs();
		if (PINS_BACKSIDE) {
			pins_backside();
		}
	}
	if (HIPOWER_CUT) {
		hipower_module_cut();
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

module base() {
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

module standoff() {
	// Distances to the border of the PCB
	width_d = 1;
	height_d = 0.5;
	translate([width / 2 - standoff_hole_dia / 2 - width_d, height / 2 - standoff_hole_dia / 2 - height_d, thickness]) {
		union() {
			cylinder(d=standoff_dia, h=standoff_height);
			cylinder(d=standoff_dia + 1, h=standoff_raiser_height);
		}
	}
}

module standoffs() {
	for (x = [0:1]) {
		for (y = [0:1]) {
			mirror([x, y, 0]) {
				standoff();
			}
		}
	}
}