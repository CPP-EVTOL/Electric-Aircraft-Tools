This repository is for miscellaneous design/analysis tools for electric aircraft.

electricAircraftRange.m

This script takes information such as number of battery cells, C rating, L/D ratio, etc and returns the expected range for the aircraft. You still have to find the powertrain efficiency "eta" before using this script.

electricHoverEndurance.m

This script takes similar inputs to the range script, and returns the expected hover endurance, max amp draw from the battery, and voltage sag. You still have to find the powertrain efficiency "eta" of the wires and ESC's as well as the static efficiency "figure of merit" (FOM) for the propeller before using this script.
