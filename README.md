This repository is for miscellaneous design/analysis tools for electric aircraft.

electricAircraftRange.m

This script takes information such as number of battery cells, C rating, L/D ratio, etc and returns the expected range for the aircraft. You still have to find the powertrain efficiency "eta" before using this script.

electricHoverEndurance.m

This script takes similar inputs to the range script, and returns the expected hover endurance, max amp draw from the battery, and voltage sag. You still have to find the powertrain efficiency "eta" of the wires and ESC's as well as the static efficiency "figure of merit" (FOM) for the propeller before using this script.

tandemWingSizing_01.m

If you know your total wing area and x locations of each wing, this script will tell you what size to make each wing. It sizes them based on an equivalent horizontal tail volume. It also tells you the incidence angle you need for each wing for a specific trim airspeed.

constraintDiagramPlotter.m

This script plots the constraint diagram for a fixed wing aircraft. It considers takeoff and landing, climb angle and rage, level turn, max airspeed, and service ceiling. Before using this script, read Gudmundsson section 3.2 about constraint diagrams. If additional performance parameters are needed (such as clumbing turn, etc) the equations can be found in this section as well.

APC_dynamic_performance.m
APC_fixedpower_performance.m
APC_static_performance.m

These scripts are used to visualize the data given on the APC propeller website. Data files for more propellers can be found here: https://www.apcprop.com/technical-information/performance-data/
The "dynamic performance" script plots stuff vs airspeed for a fixed rpm (used for forward flight).
The "fixed power performance" script plots thrust and efficiency vs airspeed for a fixed power input (used for forward flight).
The "static performance" script plots static performance values vs RPM (used for hover).
