%Alexander Walsh 6/7/2024
clear
format compact

%This script estimates the cruise range of a UAV or electric aircraft using
%normal Lithium-Polymer batteries.

%================================= INPUT ==================================

cells = 6;%number of battery cells
mAh = 16000;%battery capacity in milliamp hours
mBatt = 0.178;%battery mass in kg
mEmpty = 14;%aircraft empty (no batt or payload) mass in kg
mPayload = 3.5;%payload mass in kg
C = 10;%battery C rating (1/hr)
eta = 0.76;%total powertrain efficiency
LDcruise = 6;%aircraft L/D in cruise
Vcruise = 32;%aircraft cruise velocity in m/s
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

%calculate mass specific energy (W*hr/kg)
Estar = Unom*I0/mBatt;
mGross = mBatt+mEmpty+mPayload;
T = (mGross*9.81)/LDcruise;%thrust in N
Pout = T*Vcruise;%power actually delivered by propellers (W)
Pin = Pout/eta;%power supplied to motors from the battery (W)
Ptot = Pin+5*(parasiteDraw);%total power supplied from the battery (W)

%Range calculated from Breguet range equation (more idealized):
%This one assumes a constant voltage, does not consider current.
Estar_SI = Estar*3600;
R1 = Estar_SI*(1/9.81)*eta*LDcruise*(mBatt/mGross);

%Range from 1d iterative calculation (more accurate):
%This one accounts for voltage sag and uses a realistic discharge curve
%for the battery.
t = 0;
x = 0;
dt = 0.1;%timestep (sec)
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
    x = x+(Vcruise*dt);
    t = t+dt;
    tPlot(ii) = t;
    Iplot(ii) = Current;
    Uplot(ii) = Unow;
    UsagPlot(ii) = Usag;
    ii = ii+1;

end

disp("  Cruise Range Results:")s

if sagLimit
    fprintf("  Warning: excessive voltage sag!\n")
end
if currentLimit
    fprintf("  Warning: max battery current draw exceeded!\n")
end

R2 = x;
R1mi = R1*6.2137e-4;
R2mi = R2*6.2137e-4;

fprintf("Range 1 ( Breguet ): %.2f m (%.2f mi)\nRange 2 (Iterative):" + ...
    " %.2f m (%.2f mi)\nMax Current: %.2f A\n",R1,R1mi,R2,R2mi,Current);
fprintf("Time: %.2f min\n\n",t/60);