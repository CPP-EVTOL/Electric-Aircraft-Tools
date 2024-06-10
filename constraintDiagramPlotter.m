%Alexander Walsh 5/23/2024
clear
format compact

%================================= INPUT ==================================

%Takeoff/Landing parameters:
ClTO = 0.9;%takeoff CL
CdTO = 0.06;%takeoff CD
Clmax = 1.8;%max CL
SG = 300;%takeoff ground run, ft
SGLAND = 200;%landing ground roll, ft
muTO = 0.04;%wheel friction (0.04 typ)
g = 32.2;%gravity aceleration ft/s/s
rho = 0.002048;%air density slug/cu.ft
VLO = 88;%takeoff velocity ft/s
%Climb angle/rate parameters:
LDmax = 12;%expected L/D max
gamma = 15;%max climb angle degrees
vClimb = 100;%ft/s best rate speed
ROC = 20;%ft/s climb rate
%Level turn parameters:
CdMIN = 0.055;%min drag coef
VT = 110;%turn speed ft/s
k = 0.08;%lift induced drag coefficient
n = 2;%turn load factor
%Max airspeed parameters:
VMAX = 202.5;%max airspeed ft/s
S = 160;%wing area sq.ft
%Service ceiling parameters:
rhomin = 0.001676;%air density at service ceiling slug/cu.ft
VYmin = 110;%best rate airspeed at service ceiling ft/s
%Landing distance parameters:
hobst = 50;%landing obstacle height ft
ClLDG = 0.1;%CL during ground roll
CdLDG = 0.008;%CD during ground roll
muLAND = 0.5;%ground friction during braking
TgrW = 0;%thrust to weight during ground roll (~0 for idle)
tbrake = 0;%reaction time before braking seconds
WS = 4:0.1:20;%wing loading psf (range of values to plot)

%==========================================================================


%example points
wsexample = [10.5,26.2,149,74,18.2,30.7,69,19.6,14.4];
twexample = [0.23,0.29,0.269,1.1,1.4,0.41,0.438,0.227,1];
name = ["C172","DHC-6","747","F-18","EXTRA 300","CIRRUS VISION","LEARJET","AERO COMMANDER","PITTS MODEL 12"];

%gud. equation 3-1 takeoff distance
TW_TO = (1.21/(g*rho*Clmax*SG))*(WS)+(0.605/Clmax)*(CdTO-muTO*ClTO)+muTO;

%eq. 3-6 climb angle
%TW_GAMMA = sind(gamma)+sqrt(4*k*CdMIN);
TW_GAMMA = sind(gamma)+(1/LDmax);

%eq. 3-2 climb rate
qclimb = 0.5*rho*(vClimb^2);
TW_ROC = (ROC/vClimb)+(qclimb./WS)*CdMIN+(k/qclimb)*WS;

qturn = 0.5*rho*(VT^2);
%eq. 3-7 level turn
TW_TURN = qturn*(((CdMIN)./(WS))+k*((n/qturn)^2)*WS);

qmax = 0.5*rho*(VMAX^2);
%eq. 3-10 max cruise speed
TW_VMAX = qmax*CdMIN*(1./WS)+k*(1/qmax)*(WS);

qceil = 0.5*rhomin*(VYmin^2);
%eq. 3-11 service ceiling
TW_CEILING = (1.667/VYmin)+(qceil./WS)*CdMIN+(k/qceil)*WS;
%Calculate landing stuff:

%eq. 3-13 total landing distance over obstacle
A = rho*Clmax;
B = g*((0.605/Clmax)*(CdLDG-muLAND*ClLDG)+muLAND-(TgrW));
S_LDG = 19.08*hobst+(0.007923+1.556*tbrake*(sqrt(A./WS))+1.21/(B)).*(WS/A);
%eq. 3-14 landing ground roll
S_LGR = (0.01583+1.556*tbrake*(sqrt(A./WS))+(1.21/B)).*(WS/A);

wsLandable = interp1(S_LGR,WS,SGLAND);

%subplot(1,2,1)
hold on
grid on
for ii = 1:length(name)
    text(wsexample(ii)-1.5,twexample(ii)-0.025,name(ii));
end
plot(wsexample,twexample,'rd')
plot(WS,TW_TO)
plot(WS,TW_GAMMA*ones(1,length(WS)))
plot(WS,TW_TURN)
plot(WS,TW_VMAX)
plot(WS,TW_CEILING)
plot([wsLandable,wsLandable],[0,1])
plot(WS,TW_ROC)
title("Constraint Diagram")
xlabel("W/S (psf)")
ylabel("T/W")
legend('Example points','Takeoff','climb angle','turn','max speed','ceiling','landing ground roll','climb rate')
xlim([min(WS),max(WS)])
ylim([0,0.7])
[x,y] = ginput(1);
plot(x,y,'r+')

disp("  Constraint Diagram Results:")
fprintf("W/S: %.2f psf\nT/W: %.2f\n\n",x,y)


%{
subplot(1,2,2)
hold on
grid on
plot(WS,S_LDG)
plot(WS,S_LGR)
title("Landing Distance")
xlabel("W/S (psf)")
ylabel("Distance (ft)")
legend("over obstacle","ground roll")
%}