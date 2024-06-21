%Alexander Walsh 6/13/2024
clear
format compact

%This script plots an approximation of the longitudinal moment vs alpha for
%a tandem wing aircraft. Assumes a trapezoidal wing with control surface
%chord radios of 0.3 (optimal).

%NOTE: This script is a linear approximation, it should only be used to get
%an idea of control surface deflections for trimpoints of the aircraft

%================================= INPUT ==================================

%Wing locations, cg location (inches)
x1 = 11;
x2 = 66;
xcg = 40;
%Wing dimensions (inches)
b1 = 45.5;%TOTAL span
b2 = 88.5;%TOTAL span
CR1 = 14.22;%root chord
CR2 = 19.99;%tip chord
lambda1 = 0.6;
lambda2 = 0.5;
ai1 = 6.52;%incidence, degrees
ai2 = 2.8;%incidence, degrees
%Control surface locations (semispan startpoints as a coefficient
%from 0 to 1 of the semispan
bCS1 = 0.2;
bCS2 = 0.5;
%Control surface deflections (degrees, positive is TE up) +-45 degrees MAX
dE1 = -30;
dE2 = 30;
%airfoil characteristics (2D, degrees and degrees^-1)
CLmax = 1.78;
aStall = 15;
aZL = -1.2;
CLa = 0.104;
%other parameters
Vinf = 88;%ft/s
rho = 0.0023;%slug/cu.ft

%==========================================================================

%wing area (square inches)
S1 = (CR1+lambda1*CR1)*0.5*(b1);
S2 = (CR2+lambda2*CR2)*0.5*(b2);

%get airfoil coefficients for deflected control surfaces
%The following anonymous functions are approximated from the data in table
%10-4 of Gudmundsson sectino 10.3 for a plain flap with a chord radio cf/c
%of 0.3

CL0 = -1*aZL*CLa;
dCLmax = @(d) ((0.51)/(45))*(d);
daStall = @(d) (0.002444*((abs(d)-30).^2)-2.2).*sign(d)*-1;
dCL0 = @(d) 0.078*sqrt(abs(d)).*sign(d).*-1;

%define anonymous function for lift distribution (raymer), function of
%semispan ratio (https://www.desmos.com/calculator/t7tn69ne86)
CLratio = @(b) (sqrt((1.27^2)*(1-(b^2))))*(((0.78*b)^3.4)-0.2*b+1);

%get airfoil parameters for deflected control surfaces
CLmax1 = CLmax+dCLmax(dE1);
CLmax2 = CLmax+dCLmax(dE2);
aStall1 = aStall+daStall(dE1);
aStall2 = aStall+daStall(dE2);
CL01 = CL0+dCL0(dE1);
CL02 = CL0+dCL0(dE2);
CLa1 = (CLmax1-CL0)/aStall1;
CLa2 = (CLmax2-CL0)/aStall2;

%unit conversions (inches/square inches to ft/square ft)
b1 = b1/12; b2 = b2/12;
S1 = S1/144; S2 = S2/144;
CR1 = CR1/12; CR2 = CR2/12;
Chord1 = @(b) CR1+(lambda1*CR1-CR1)*b;
Chord2 = @(b) CR2+(lambda1*CR2-CR2)*b;

q = 0.5*rho*(Vinf^2);
%wing inner section area
Sinner1 = (CR1+Chord1(bCS1))*0.5*(bCS1)*(b1);
Sinner2 = (CR2+Chord2(bCS2))*0.5*(bCS2)*(b2);
%wing outer (flapped) section area
Souter1 = (Chord1(bCS1)+lambda1*CR1)*0.5*(1-bCS1)*(b1);
Souter2 = (Chord2(bCS2)+lambda2*CR2)*0.5*(1-bCS2)*(b2);

%for each alpha (degrees)
M1plot = [];
M2plot = [];
aPlot = [];
L1plot = [];
L2plot = [];
for a = -5:0.1:max([aStall1,aStall2])
    alpha1 = a+ai1;
    alpha2 = a+ai2;
    %Lift force lbf
    Linner1 = q*Sinner1*(CL0+CLa*alpha1);
    Louter1 = q*Souter1*(CL01+CLa1*alpha1);
    Linner2 = q*Sinner2*(CL0+CLa*alpha2);
    Louter2 = q*Souter2*(CL02+CLa2*alpha2);
    %correct for spanwise lift distribution
    Linner1 = Linner1*CLratio(bCS1*0.5);
    Louter1 = Louter1*CLratio(bCS1+(1-bCS1)*0.5);
    Linner2 = Linner2*CLratio(bCS2*0.5);
    Louter2 = Louter2*CLratio(bCS2+(1-bCS2)*0.5);
    L1 = Linner1+Louter1;
    L2 = Linner2+Louter2;
    %Pitching moment in*lbf
    M1 = (Linner1+Louter1)*(xcg-x1);
    M2 = (Linner2+Louter2)*(xcg-x2); 
    %sae data to plot
    M1plot = [M1plot,M1];
    M2plot = [M2plot,M2];
    aPlot = [aPlot,a];
    L1plot = [L1plot,L1];
    L2plot = [L2plot,L2];
    
end

%subplot(1,2,1)
Mplot = M1plot+M2plot;
[tpMoment,tpIndex] = min(abs(Mplot));
plot(aPlot,Mplot,'k')
hold on
grid on
plot([aStall1,aStall1],[min(Mplot),max(Mplot)],'r--')
plot([aStall2,aStall2],[min(Mplot),max(Mplot)],'b--')
plot([aStall,aStall],[min(Mplot),max(Mplot)],'g--')
plot(aPlot(tpIndex),0,'ro')
plot(0,0,'kd')
legend("Moment","Front Wing Stall","Rear Wing Stall","Wing Unflapped Region Stall","Trimpoint")
xlabel("Alpha (degrees)")
ylabel("Pitching Moment (in*lbf)")
title("Pitching Moment vs alpha")

%{
subplot(1,2,2)
Lplot = L1plot+L2plot;
CLplot = Lplot/(q*(S1+S2));
plot(aPlot,CLplot)
xlabel("Alpha (Degrees)")
ylabel("CL")
grid on
xlim([min(aPlot),min([aStall1,aStall2,aStall])])
title("Lift Coefficient vs alpha")

disp("  Pitching Moment Results:")
fprintf("Trimpoint at alpha: %.2f degrees\n",aPlot(tpIndex))
fprintf("Trimpoint CL: %.3f (%.2f lbf of lift)\n",CLplot(tpIndex),Lplot(tpIndex))
fprintf("(L1: %.2f lbf, L2: %.2f lbf)\n",L1plot(tpIndex),L2plot(tpIndex))
%}
if (Mplot(end)<Mplot(1))
    fprintf("Acft is statically stable\n\n")
else
    fprintf("Acft is statically unstable\n\n")
end
