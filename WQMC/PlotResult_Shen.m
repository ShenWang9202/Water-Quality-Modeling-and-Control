% insert value at 0 time
X_A_Q = [zeros(nx,1) X_A_Q];
X_B_Q = [zeros(nx,1) X_B_Q];

% display each minute
[nx, Steps] = size(X_A_Q);
TimesSeries = (0:1:Steps)*DeltaTQ;
ReportTime = 60;% seconds.

X_A_Q_Report = [];
X_B_Q_Report = [];
for i = 1:Steps
    if(0 == mod(TimesSeries(i),ReportTime))
        X_A_Q_Report = [X_A_Q_Report X_A_Q(:,i)];
        X_B_Q_Report = [X_B_Q_Report X_B_Q(:,i)];
    end
end



%Extract pipe
% LDE
PipeAvgA = mean(X_A_Q_Report(IndexPipe_Q,:));
PipeAvgB = mean(X_B_Q_Report(IndexPipe_Q,:));
PipeAvg_LDE = [PipeAvgA; PipeAvgB]';


%EPANET

Q_Pipe_EPANET = [];
[Steps, ~] = size(Q_Pipe);
for i = 1:Steps
    if(0 == mod(TimeSeries_EPANET(i),ReportTime))
        Q_Pipe_EPANET = [Q_Pipe_EPANET; Q_Pipe(i,:)];
    end
end

%Extract tank
% LDE
Q_Tank_LDE = [X_A_Q_Report(IndexTank_Q,:); X_B_Q_Report(IndexTank_Q,:)]';
%EPANET
Q_Tank_EPANET = [];
[Steps, ~] = size(Q_Tank);
for i = 1:Steps
    if(0 == mod(TimeSeries_EPANET(i),ReportTime))
        Q_Tank_EPANET = [Q_Tank_EPANET; Q_Tank(i,:)];
    end
end

figure(1)
subplot(2, 1, 1);
plot(PipeAvg_LDE, 'LineWidth', 1)
grid on
ylabel('Concentration (mg/l)')
title('Pipe-LDE')
subplot(2, 1, 2);
plot(Q_Pipe_EPANET, 'LineWidth', 1)
grid on
xlabel('Time (mins)')
ylabel('Concentration (mg/l)')
title('Pipe-EPANET')

figure(2)
subplot(2, 1, 1);
plot(Q_Tank_LDE, 'LineWidth', 1)
grid on
ylabel('Concentration (mg/l)')
title('Tank-LDE')
subplot(2, 1, 2);
plot(Q_Tank_EPANET, 'LineWidth', 1)
grid on
xlabel('Time (mins)')
ylabel('Concentration (mg/l)')
title('Tank-EPANET')





