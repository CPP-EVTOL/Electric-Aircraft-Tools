%Alexander Walsh 6/7/2024
clear
format compact

%================================= INPUT ==================================

cells = 6;%number of battery cells
mAh = 16000;%battery capacity in milliamp hours
mBatt = 0.178;%battery mass in kg
mEmpty = 14;%aircraft empty (no batt or payload) mass in kg
mPayload = 3.5;%payload mass in kg
C = 12;%battery C rating (1/hr)
FOM = 0.6;%propeller static efficiency parameter
eta = 0.85;%powertrain efficiency (excluding propeller, so esc only)
Dia = 14;%propeller diameter in inches
rho = 0.0021;%air density in slug/cu.ft
nProps = 8;%number of vertical propellers
parasiteDraw = 0.5;%amps drawn on the 5v psp bus at idle
voltageCutoff = 3.2;%low voltage cutoff (per cell voltage)

%==========================================================================

%Approximate the discharge curve of the battery (voltage vs charge state)
%for details of the following parameters, see Gudmundsson Pg. 244,245. If
%you know more details about the battery, change the coefficients on these
%parameters to match it better.
Cexp = 0.14*mAh;
Cnom = 0.82*mAh;
Ccut = mAh;
Ufull = 4.2*cells;
Uexp = 3.97*cells;
Unom = 3.8*cells;
Ucut = 3.27;
I0 = mAh/1000;
Rc = 2e-3;%internal resistance ohms

A = Ufull-Uexp;
B = 3/Cexp;
k = (Ufull-Unom+A*(exp(-B*Cnom)-1))*(Ccut-Cnom)/Cnom;
U0 = Ufull+k+(Rc*I0)-A;
mAhUsed = 0:0.1:mAh;
UOC = U0-((k*Ccut)./(Ccut-mAhUsed))+A*exp(-B*mAhUsed);

mGross = mBatt+mEmpty+mPayload;
T = mGross*9.81;
Ti = T/nProps;

%convert diameter in inches to radius in m
R = (Dia/2)*0.0254;
%convert air density to kg/cu.m
rho = rho*515.379;

%find required power per propeller (W)
%(See G&M pg.51 equation 8)
Pout = Ti*sqrt((2*Ti)/(3.14159*rho))/(2*FOM*R);
%find total required power to propellers (W)
Pout = Pout*nProps;
%find total required power from battery (W)
Pin = Pout/eta;
Ptot = Pin+5*parasiteDraw;

%Get endurance from iterative calculation
t = 0;
dt = 0.1;%timestep (seconds)
Unow = Ufull;
Cused = 0;
Iplot = [];
Uplot = [];
tPlot = [];
UsagPlot = [];
ii = 1;
sagLimit = false;
currentLimit = false;
while Unow > voltageCutoff*cells
    
    %get current voltage
    Unow = U0-((k*Ccut)./(Ccut-Cused))+A*exp(-B*Cused);
    
    Current = Ptot/Unow;
    %account for voltage sag
    Usag = Current*Rc;
    Current = Ptot/(Unow-Usag);
    if Usag > 0.2*cells
        sagLimit = true;
    end
    if Current > I0*C
        currentLimit = true;
    end
    %update stuff
    dC = (Current*1000)*(dt/3600);
    Cused = Cused+dC;
    t = t+dt;
    tPlot(ii) = t;
    Iplot(ii) = Current;
    Uplot(ii) = Unow;
    UsagPlot(ii) = Usag;
    ii = ii+1;

end

disp("  Hover Endurance Results:")

if sagLimit
    fprintf("  Warning: excessive voltage sag!\n")
end
if currentLimit
    fprintf("  Warning: max battery current draw exceeded!\n")
end

fprintf("Endurance: %.2f min\nMax Current: %.2f A\nVoltage " + ...
    "Sag: %.2f V\n\n",t/60,Current,Usag)