%Alexander Walsh 02/15/2024
clear
format compact

%use this script to read DYNAMIC performance data at a given RPM
%PER3_yourProp.DAT
%available here: https://www.apcprop.com/technical-information/performance-data/

dataFile = "PER3_15x10E.dat";
RPM = 8000;
plotting = true;

%==========================================================================

data = readlines(dataFile);

dataSearch = false;
dataStart = length(data);
dataString = "none";
%look through every line
for ii = 1:length(data)

    line = data(ii);
    line = char(erase(line," "));

    %look for desired RPM
    if (length(line) >= 9)
        line = line(9:end);
        if length(line)==length(char(string(RPM)))
            if char(string(RPM))==line
                dataStart = ii+4;
                dataSearch=true;
            end
        end
    end

    if dataSearch == true
        if (strtrim(data(ii+4))=="")
            dataEnd = ii+4;
            dataString = data(dataStart:dataEnd);
            dataSearch = false;
        end
    end

end

if (dataString=="none")
    error("Data not found in file, check input RPM.")
end
dataString = dataString(1:end-1);%cut off last empty row
%format:
%V mph, J, Pe, Ct, Cp, POWER hp, TORQUE in*lbf, THRUST lbf, POWER W,...
%...TORQUE N*m, THRUST N, THR/PWR g/W, Mach at tip, Re at 75% span, FOM
%J = V/nD advance ratio
%Ct = T/(rho*n^2*D^4) thrust coef
%Cp = P/(rho*n^3*D^5) power coef
%Pe = Ct*J/Cp efficiency
%Mach is at tip, Re at 75% span


V_mph = zeros(1, length(dataString));
J = zeros(1, length(dataString));
Pe = zeros(1, length(dataString));
Ct = zeros(1, length(dataString));
Cp = zeros(1, length(dataString));
P_hp = zeros(1, length(dataString));
Q_inlb = zeros(1, length(dataString));
T_lbf = zeros(1, length(dataString));
P_w = zeros(1, length(dataString));
Q_nm = zeros(1, length(dataString));
T_n = zeros(1, length(dataString));
tp_gw = zeros(1, length(dataString));
M = zeros(1, length(dataString));
Re = zeros(1, length(dataString));
FOM = zeros(1, length(dataString));

%for each line in the matrix
for ii = 1:length(dataString)
    %use space as delimeter
    dataRow = split(dataString(ii), " ");
    %get rid of empty spaces
    dataRow = dataRow(dataRow~="");
    V_mph(ii) = double(dataRow(1));
    J(ii) = double(dataRow(2));
    Pe(ii) = double(dataRow(3));
    Ct(ii) = double(dataRow(4));
    Cp(ii) = double(dataRow(5));
    P_hp(ii) = double(dataRow(6));
    Q_inlb(ii) = double(dataRow(7));
    T_lbf(ii) = double(dataRow(8));
    P_w(ii) = double(dataRow(9));
    Q_nm(ii) = double(dataRow(10));
    T_n(ii) = double(dataRow(11));
    tp_gw(ii) = double(dataRow(12));
    M(ii) = double(dataRow(13));
    Re(ii) = double(dataRow(14));
    FOM(ii) = double(dataRow(15));
end

if plotting
    subplot(3,2,1)
    plot(V_mph,P_hp)
    title("Power vs Velocity")
    xlabel("V (mph)")
    ylabel("Power (hp)")
    grid on

    subplot(3,2,2)
    plot(V_mph,T_lbf)
    title("Thrust vs Velocity")
    xlabel("V (mph)")
    ylabel("Thrust (lbf)")
    grid on

    subplot(3,2,3)
    plot(V_mph,Q_inlb)
    title("Torque vs Velocity")
    xlabel("V (mph)")
    ylabel("Torque (in*lbf)")
    grid on

    subplot(3,2,4)
    plot(V_mph,Pe)
    title("Efficiency vs Velocity")
    xlabel("V (mph)")
    ylabel("Pe")
    grid on

    subplot(3,2,5)
    plot(T_lbf,P_hp,'r')
    title("Power vs Thrust")
    xlabel("Thrust (lbf))")
    ylabel("Power (hp)")
    grid on

    subplot(3,2,6)
    plot(T_lbf,Pe,'r')
    title("Efficiency vs Thrust")
    xlabel("Thrust (lbf)")
    ylabel("Efficiency")
    grid on

    titleString = strcat("Theoretical Performance: ",string(RPM), " RPM");
    sgtitle(titleString)
end

