%Alexander Walsh 02/15/2024
clear
format compact

%use this script to read STATIC performance data from the file
%PER2_STATIC-2.DAT
%available here: https://www.apcprop.com/technical-information/performance-data/

prop = "15x10E";
plotting = true;

%==========================================================================

data = readlines("PER2_STATIC-2.DAT");

propName = strcat(prop,".dat");
dataSearch = false;
dataStart = length(data);
dataString = "none";
%look through every line
for ii = 1:length(data)
    lineText = strtrim(data(ii));

    if (lineText==propName)
        nameIndex = ii;
        dataStart = ii+5;
        dataSearch = true;
    end
    if (dataSearch==true)
        if (strtrim(data(ii+5))=="")
            dataEnd = ii+4;
            dataString = data(dataStart:dataEnd);
            dataSearch = false;
        end
    end
end

if (dataString=="none")
    error("Data not found in file, check propeller name format i.e. 6x4, 10x5E, etc.")
end

%format:
%RPM, THRUST lbf, POWER hp, TORQUE in*lbf, Cp, Ct, FOM
%Ct = T/(rho*n^2*D^4) thrust coef
%Cp = P/(rho*n^3*D^5) power coef

RPM = zeros(1,length(dataString));
T = zeros(1,length(dataString));%thrust lbf
P = zeros(1,length(dataString));%power hp
Q = zeros(1,length(dataString));%torque in*lbf
Cp = zeros(1,length(dataString));
Ct = zeros(1,length(dataString));
FOM = zeros(1,length(dataString));

%for each line in the matrix
for ii = 1:length(dataString)
    %use space as delimeter
    dataRow = split(dataString(ii), " ");
    %get rid of empty spaces
    dataRow = dataRow(dataRow~="");
    RPM(ii) = double(dataRow(1));
    T(ii) = double(dataRow(2));
    P(ii) = double(dataRow(3));
    Q(ii) = double(dataRow(4));
    Cp(ii) = double(dataRow(5));
    Ct(ii) = double(dataRow(6));
    FOM(ii) = double(dataRow(7));
end

%create SI unit versions
omega = RPM*0.1047;%rad/s
T_SI = 4.44822*T;%newtons
P_SI = 745.7*P;%watts
Q_SI = 0.112985;%N*m

if plotting
    subplot(3,3,1)
    plot(RPM,T)
    title("Thrust vs RPM")
    xlabel("RPM")
    ylabel("Thrust (lbf)")
    grid on

    subplot(3,3,2)
    plot(RPM,P)
    title("Power vs RPM")
    xlabel("RPM")
    ylabel("Power (hp)")
    grid on

    subplot(3,3,3)
    plot(RPM,Q)
    title("Torque vs RPM")
    xlabel("RPM")
    ylabel("Torque (in*lbf)")
    grid on

    subplot(3,3,4)
    plot(RPM,Cp)
    title("cp vs RPM")
    xlabel("RPM")
    ylabel("Cp")
    grid on

    subplot(3,3,5)
    plot(RPM,Ct)
    title("ct vs RPM")
    xlabel("RPM")
    ylabel("Ct")
    grid on

    subplot(3,3,6)
    plot(RPM,FOM)
    title("FOM vs RPM")
    xlabel("RPM")
    ylabel("FOM")
    grid on

    subplot(3,3,7)
    plot(T,P,'r')
    title("Power vs Thrust")
    xlabel("Thrust (lbf)")
    ylabel("Power (hp)")
    grid on

    subplot(3,3,8)
    plot(T,Q,'r')
    title("Torque vs Thrust")
    xlabel("Thrust (lbf)")
    ylabel("Torque (in*lbf)")
    grid on

    subplot(3,3,9)
    plot(T,FOM,'r')
    title("FOM vs Thrust")
    xlabel("Thrust (lbf)")
    ylabel("FOM")
    grid on

    titleString = strcat("Theoretical Static Performance: APC ",prop);
    sgtitle(titleString)
end
