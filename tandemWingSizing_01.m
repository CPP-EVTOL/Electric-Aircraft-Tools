%Alexander Walsh 6/7/2024
clear
format compact

%This script gives you the size and incidence angle for the front and rear
%wing of a tandem wing aircraft to achieve a certain trim airspeed and
%equivalent horizontal tail volume. You must already know your total wing
%area, location of each wing, target CG location, and estimation of the MAC
%of each wing.

%================================= INPUT ==================================

tgtVht = 0.67;%target equivalent horizontal tail volume
tgtVvt = 0.06;%target vertical tail volume
S = 1850;%total wing area in square inches
x1 = 11.0625;%wing 1 quarter chord location inches
x2 = 66.0625;%wing 2 quarter chord location inches
xvt = 81;%vertical tail quarter chord location inches
xcg = 40;%target cg location inches
MAC = 16;%sum of the MAC's from wings 1 and 2   
W = 40;%lbf weight
v = 60;%mph trim airspeed
rho = 0.002;%slug/cu.ft air density
CLa = 6;% CL vs alpha slope (rad^-1);

%==========================================================================

v = v*1.46667;%convert to ft/sec

S1 = 0:0.05:S;
n = length(S1);
V1 = zeros(1,n);
V2 = V1;
V = V1;
S2 = V1;

%calculate S2 and volumes for all S1
for ii = 1:n
    S2(ii) = S-S1(ii);
    V1(ii) = S1(ii)*(x1-xcg)/(MAC*S);
    V2(ii) = S2(ii)*(x2-xcg)/(MAC*S);
    V(ii) = V1(ii)+V2(ii);
end

%calculate the index of the correct S1, Svt, etc
Verr = abs(V-tgtVht);
[~,index] = min(Verr);
S1 = S1(index); S2 = S2(index);
V1 = V1(index); V2 = V2(index);
fprintf("S1: %.2f sq.in\nS2: %.2f sq.in\n",S1,S2)

%calculate incidence angles
lifts = rref([xcg-x1,xcg-x2,0;1,1,W]);
%get lift for each wing
L1 = lifts(1,3);
L2 = lifts(2,3);
%get CL and aifor each wing
S1ft = S1/144; S2ft = S2/144;
CL1 = (2*L1)/(S1ft*rho*v*v);
CL2 = (2*L2)/(S2ft*rho*v*v);
ai1 = rad2deg(CL1/(CLa));
ai2 = rad2deg(CL2/(CLa));
%calculate stall speed for both wings at a clmax of 1.3
Vs1 = 1.41421*sqrt(abs(L1)/(1.3*S1ft*rho));
Vs2 = 1.41421*sqrt(abs(L2)/(1.3*S2ft*rho));
%convert to mph
Vs1 = Vs1/1.46667;
Vs2 = Vs2/1.46667;

disp("  Tandem Wing Results:")
fprintf("CL_cruise1: %.2f at %.2f deg\nCL_cruise2: %.2f at %.2f deg\nStall Speed: %.2f mph\n",CL1,ai1,CL2,ai2,max([Vs1,Vs2]))
fprintf("Wing 1 Area: %.2f sq.in\nWing 2 Area: %.2f sq.in\n\n",S1,S2)




