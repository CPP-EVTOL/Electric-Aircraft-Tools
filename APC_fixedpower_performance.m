%Alexander Walsh 02/15/2024
clear
format compact

%use this script to find FIXED-POWER performance vs airspeed
%PER3_yourProp.DAT
%available here: https://www.apcprop.com/technical-information/performance-data/

dataFile = "PER3_15x10E.dat";
powerStep = 0.2; %used for plotting only
RPM_MAX = 10000;
plotting = true;

%==========================================================================

%get data at each rpm in the file
RPM_test = 0:1000:RPM_MAX;
data = readlines(dataFile);
RPM_data = [];
V_data = [];
T_data = [];
P_data = [];
Pe_data = [];
   
    %for each test RPM
    for kk = 1:length(RPM_test)
        
        %get data from the file ========================
        RPM = RPM_test(kk);
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
        
        if (dataString~="none")
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
                if length(dataRow)==15
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
            end
            RPM_data = vertcat(RPM_data,RPM);
            V_data = vertcat(V_data,V_mph);
            T_data = vertcat(T_data,T_lbf);
            P_data = vertcat(P_data,P_hp);
            Pe_data = vertcat(Pe_data,Pe);
        end
    
        %===============================================
       
    end

if plotting
    
    %{
    plot3(0,0,0,'ko')
    xlabel("vel")
    ylabel("thrust)")
    zlabel("power")
    hold on
    %for each rpm
    for ii = 1:length(RPM_data)
        %for each velocity at this rpm
        for jj = 1:length(V_data)
            %plot a point
            plot3(V_data(ii,jj),T_data(ii,jj),P_data(ii,jj),'bo')
        end
    end
    %}
    subplot(1,2,1)
    contour(V_data,T_data,P_data,[0:powerStep:max(max(P_data))],"ShowText","on")
    xlabel("Velocity (mph)")
    ylabel("Thrust (lbf)")
    title("Thrust vs Velocity (fixed power)")
    grid on

    subplot(1,2,2)
    contour(V_data,Pe_data,P_data,[0:powerStep:max(max(P_data))],"ShowText","on")
    xlabel("Velocity (mph)")
    ylabel("Pe")
    title("Efficiency vs Velocity (fixed power)")
    grid on

    titleString = strcat("Theoretical Performance vs Velocity with Fixed-Power Contours (hp)");
    sgtitle(titleString)


end