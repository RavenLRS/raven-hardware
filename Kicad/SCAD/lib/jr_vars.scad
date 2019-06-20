// Small adjustments to make 3D printing via FDM easier
FDM = true;

// Bay, should be universal
BAY_WIDTH = 44.5;
BAY_HEIGHT = 60;
BAY_DEPTH = 19.8;

CASE_WIDTH = 43.5;
CASE_HEIGHT = 59.5;

BAY_ROUNDING = 1;
BAY_CORNER_ROUNDING = 2; // Used for just the corners

CASE_GUIDE_LENGTH = 4; // Length of the "guides" on the top to match the bottom half

CONNECTOR_SIZE = [2.54, 12.90];
// Make vertical tolerance a bit higher, since 5pin SMD connector is likely cut by hand
CONNECTOR_TOLERANCE = [0.5, 1.5];
// From w, h from center of model to center of the connector
CONNECTOR_DISTANCE = [16.4, -20.9];

// Snap fit, should work on all JR bays
SNAP_CUT_HEIGHT = 19.7; // Height of the cut, as looked from the back of the radio
SNAP_CUT_PROTUBERANCE_TOP_DISTANCE = 4.1; // Depth from the top of the case where the protuberance ends
SNAP_CUT_PROTUBERANCE_BASE_DISTANCE = 8.6; // Depth from the top of the case where the protuberance starts
// XXX: Changed to 0 to workaround screwup in L1 v1.1 PCB
SNAP_CUT_VERTICAL_OFFSET = 0; // The tabs are 0.5mm up from the center
SNAP_CUT_WIDTH = 5.5; // How much the case shell moves innerwards
SNAP_CUT_TAB_BASE_HORIZONTAL_DISTANCE = 0; // Horizontal distance from the case to the tab at the base
SNAP_CUT_TAB_VERTICAL_DISTANCE = 1.2;
SNAP_CUT_TAB_WIDTH_PROTUBERANCE = 2; // How much the tab protrudes from the base of the case
SNAP_CUT_TAB_WIDTH_PROTUBERANCE_RECESSION_DELTA = 0.5;
SNAP_CUT_TAB_HAT_WIDTH_PROTUBERANCE = 3.5; // How much the tab "hat" protrudes from the base of the case
SNAP_CUT_TAB_HAT_UNDER_ANGLE = 5; // Angle from the "hat" to the tab
SNAP_CUT_TAB_HINGE_WIDTH = 0.8; // Width of the hinge at the bottom of the tab. Zero to disable.
SNAP_CUT_TAB_HINGE_HEIGHT = 1;

// This is specific to FrSky radios
BAY_COVER_WIDTH = 48.8 - 0.5; // measured - tolerance
BAY_COVER_HEIGHT = 64 - 0.5;
BAY_COVER_DEPTH = 1.9 - 0.3;

// Screw hole parameter.
SCREW_DIA = 3.2; // This fits M3 screws when 3d printed
SCREW_PITCH = 0.50;
SCREW_WALL_WIDTH = 1;
SCREW_DEPTH = 5;
// Wether a countersunk screw removes all extra material
// from the joint to its base
// (i.e. to plane perpendicular to the screw) 
SCREW_COUNTERSUNK_NO_EXTRA_MATERIAL = true;

SCREW_TOLERANCE = 0.5;
SCREW_HEAD_TOLERANCE = 0.5;

SCREEN_DEFAULT_CORNER_RADIUS = 0.5;

ANTENNA_DEFAULT_TOP_DISTANCE = 4.5;
ANTENNA_DEFAULT_CORNER_RADIUS = 1;
ANTENNA_MOUNT_WIDTH = 11; // width of the "pipe" for the antenna
ANTENNA_HOLE_DIA = 6.8; // This should fit an SMA connector


// This is specific to the PCB/design

THICKNESS = 1.6;
INNER_THICKNESS = 0.8;
CONNECTOR_HOLDER_THICKNESS = INNER_THICKNESS;
LAYER_HEIGHT = 0.1;
BOARD_THICKNESS = 1.6;

TOTAL_DEPTH = BAY_DEPTH;
