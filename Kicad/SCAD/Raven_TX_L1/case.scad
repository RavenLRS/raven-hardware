use <../lib/fillets2d.scad>;
use <../lib/fillets3d.scad>;

use <../lib/5way_cap.scad>;
use <../lib/jr.scad>;
use <../lib/oled_support.scad>;
use <../lib/raven.scad>;

// Height the PCB should sit at
PCB_Z_OFFSET = 9.5;
// Height of the OLED
OLED_Z_OFFSET = 16.7;
// Screw head diameter
SCREW_HEAD_DIA = 5.7;
// Screw countersunk angle (angle of the head by viewing screw from the side)
SCREW_HEAD_COUNTERSUNK_ANGLE = 90;
// Screws to place
SCREWS = [[-11.75, -25.5], [11, -25.5], [-15.5, 18.5], [16.5, 14.5]];

// [base_width, base_height, stick_total_height, stick_base_distance_to_pcb, movement_degs]
// According to datasheet, base is 1.90x1.90
BUTTON_STICK = [2.00, 2.00, 6, 2.80, 15];
// Button hole [x, y, diameter]
// Calculate hole diameter from stick
BUTTON = [0, -22, jr_5way_button_cap_cylinder_dia(BUTTON_STICK) * (1 + sin(BUTTON_STICK[4])) + 0.5];

// Screen hole [x, y, width, height, [corner_radius]]
SCREEN = [-0.5, -5.7, 26.5, 14.8];

// Antenna [hole_w, hole_h, mount_height, mount_length]
ANTENNA = [18, 18, 12, 40];

PART = "B"; // [B:Base, T:Top, A:Antenna, C:Cap, CR: Cap ring, ST:Screen support top, SB:Screen support bottom, SH:Support Helper, ALL:All]
// Resolution for circles
$fn = 72; // [36, 72, 144]
DEBUG = false;

translate([0, 0, PCB_Z_OFFSET]) {
	color("green", 0.7) {
		import("../../Raven_TX_L1/Raven_TX_L1_v1.2.stl");
	}
}

*translate([-0.5, -17.1, OLED_Z_OFFSET]) {
	rotate([90, 0, 180]) {
		color("blue", 0.7)
		import("../OLED/oled_096.stl");
	}
}

if (PART == "B" || PART == "ALL") {
	jr_case_base(PCB_Z_OFFSET, screws=SCREWS,
		screw_head_dia=SCREW_HEAD_DIA,
		screw_head_countersunk_angle=SCREW_HEAD_COUNTERSUNK_ANGLE,
		debug=DEBUG);
}
if (PART == "T" || PART == "ALL") {
	jr_case_top(PCB_Z_OFFSET, screws=SCREWS,
		screw_head_dia=SCREW_HEAD_DIA,
		screw_head_countersunk_angle=SCREW_HEAD_COUNTERSUNK_ANGLE,
		button=BUTTON,
		screen=SCREEN,
		antenna=ANTENNA,
		debug=DEBUG);
}

if (PART == "A" || PART == "ALL") {
	jr_antenna_mount(antenna=ANTENNA, debug=DEBUG);
}

if (PART == "C" || PART == "ALL") {
	t = PART == "ALL" ? [0, 0, 0] : jr_5way_button_cap_translation(PCB_Z_OFFSET,  BUTTON, BUTTON_STICK);
	translate([-t[0], -t[1], -t[2]]) {
		jr_5way_button_cap(PCB_Z_OFFSET, BUTTON, BUTTON_STICK, debug=DEBUG);
	}
}

if (PART == "CR" || PART == "ALL") {
	intersection() {
	jr_5way_button_cap_ring(PCB_Z_OFFSET, BUTTON, BUTTON_STICK, debug=DEBUG);
		cube([100, 42, 40], center=true);
	}
}

if (PART == "ST" || PART == "ALL") {
	jr_oled_support_top(PCB_Z_OFFSET, OLED_Z_OFFSET, SCREEN);
}

if (PART == "SB" || PART == "ALL") {
	// XXX: Space for pullup on PCB v1.1, remove it eventually
	difference() {
		jr_oled_support_bottom(PCB_Z_OFFSET, OLED_Z_OFFSET, SCREEN);
		translate([-11.5, -17, PCB_Z_OFFSET])
		cube([4, 10, 4]);
	}
}

if (PART == "SH" || PART == "ALL") {
	jr_oled_support_helper(PCB_Z_OFFSET, OLED_Z_OFFSET, SCREEN);
}
