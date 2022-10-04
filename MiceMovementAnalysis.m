function MiceMovementAnalysis() 
    % mice Movement Analysis
    % Unit: frame
    fid = fopen('MovementObservation.csv');
    csv_title = textscan(fid,'%s',1);
    fclose(fid);
    filename = string(cell2mat(extractBetween(cell2mat(csv_title{1}), 'scorer,',',')));
    
    DataFile = xlsread('MovementObservation.csv');
    NumberOfFrames = size(DataFile, 1);
    mouseA_x_1 = DataFile(1:NumberOfFrames,2);
    mouseA_y_1 = DataFile(1:NumberOfFrames,3);
    mouseA_x_2 = DataFile(1:NumberOfFrames,5);
    mouseA_y_2 = DataFile(1:NumberOfFrames,6);
    mouseB_x_1 = DataFile(1:NumberOfFrames,17);
    mouseB_y_1 = DataFile(1:NumberOfFrames,18);
    mouseB_x_2 = DataFile(1:NumberOfFrames,20);
    mouseB_y_2 = DataFile(1:NumberOfFrames,21);
    
    mice_distance = getDistanceBetweenMice(0,NumberOfFrames,mouseA_x_1,mouseA_y_1,mouseB_x_1,mouseB_y_1);
    mice_angle = getAngleBetweenMice(0,NumberOfFrames,mouseA_x_1,mouseA_y_1,mouseA_x_2,mouseA_y_2,mouseB_x_1,mouseB_y_1,mouseB_x_2,mouseB_y_2);
    
    excelname = filename + '.xlsx';
    header1 = {'mouseA_x_1', 'mouseA_y_1', 'mouseA_x_2', 'mouseA_y_2', 'mouseB_x_1', 'mouseB_y_1', 'mouseB_x_2', 'mouseB_y_2', 'mice_distance', 'mice_angle'};
    T = table(mouseA_x_1, mouseA_y_1, mouseA_x_2, mouseA_y_2, mouseB_x_1, mouseB_y_1, mouseB_x_2, mouseB_y_2, mice_distance, mice_angle,'VariableNames', header1);
    writetable(T, excelname, 'Sheet', 1);
    
    mouseA_velocity = getVelocity(NumberOfFrames,mouseA_x_1,mouseA_y_1);
    mouseB_velocity = getVelocity(NumberOfFrames,mouseB_x_1,mouseB_y_1);
    header2 = {'mouseA_velocity', 'mouseB_velocity'};
    T = table(mouseA_velocity, mouseB_velocity, 'VariableNames', header2);
    writetable(T, excelname, 'Sheet', 2);
    
    %{
    for i = 1:12
        N = NumberOfFrames - i;
        analyzeOverNFrames(filename,i,N,mouseA_x_1,mouseA_y_1,mouseA_x_2,mouseA_y_2,mouseB_x_1,mouseB_y_1,mouseB_x_2,mouseB_y_2,mouseA_velocity,mouseB_velocity);
    end
    
    mice_distance = getDistanceBetweenMice(NumberOfFrames,mouseA_x_1,mouseA_y_1,mouseB_x_1,mouseB_y_1);
    mice_angle = getAngleBetweenMice(NumberOfFrames,mouseA_x_1,mouseA_y_1,mouseA_x_2,mouseA_y_2,mouseB_x_1,mouseB_y_1,mouseB_x_2,mouseB_y_2);
    mouseA_velocity = getVelocity(NumberOfFrames,mouseA_x_1,mouseA_y_1);
    mouseB_velocity = getVelocity(NumberOfFrames,mouseB_x_1,mouseB_y_1);
    mice_distance_difference = getDifference(NumberOfFrames,mice_distance);
    mice_velocity_difference = getDifference_Velocity(NumberOfFrames,mouseA_velocity, mouseB_velocity);
    mice_angle_difference = getDifference(NumberOfFrames,mice_angle);
    draw3DPlot(mice_distance_difference, mice_velocity_difference, mice_angle_difference);
    %}
end

function outputToExcel(filename, sheetNumber, mice_distance_difference_AB, mice_distance_difference_BA, mice_velocity_difference_AB, mice_velocity_difference_BA, mice_angle_difference_AB, mice_angle_difference_BA, synchrony_AB, synchrony_BA)
    excelname = filename + '.xlsx';
    header = {'mice_distance_difference_AB', 'mice_distance_difference_BA', 'mice_velocity_difference_AB', 'mice_velocity_difference_BA', 'mice_angle_difference_AB', 'mice_angle_difference_BA', 'synchrony_AB', 'synchrony_BA'};
    T = table(mice_distance_difference_AB, mice_distance_difference_BA, mice_velocity_difference_AB, mice_velocity_difference_BA, mice_angle_difference_AB, mice_angle_difference_BA, synchrony_AB, synchrony_BA, 'VariableNames', header);
    writetable(T, excelname, 'Sheet', sheetNumber);
end

function outputToText(filename, N, frames, time_range_AB, time_range_BA)
    txtname = filename + '.txt';
    fileID = fopen(txtname, 'a+');
    for i = 1:(frames-1)
        if time_range_AB(i) ~= 0
            fprintf(fileID, 'AB: frame %d with difference %d\n', N, time_range_AB(i));
        else
            break;
        end
    end
    for i = 1:(frames-1)
        if time_range_BA(i) ~= 0
            fprintf(fileID, 'BA: frame %d with difference %d\n', N, time_range_BA(i));
        else
            break;
        end
    end
    fclose(fileID);
end

function [distanceAB, distanceBA] = getDistanceBetweenMice(gap, frames, mouseA_x, mouseA_y, mouseB_x, mouseB_y)
    distanceAB = zeros(frames, 1);
    distanceBA = zeros(frames, 1);
    for i = 1:frames
        distanceAB(i) = sqrt((mouseA_x(i) - mouseB_x(i+gap))^2 + (mouseA_y(i) - mouseB_y(i+gap))^2);
        distanceBA(i) = sqrt((mouseA_x(i+gap) - mouseB_x(i))^2 + (mouseA_y(i+gap) - mouseB_y(i))^2);
    end
end

function [angleAB, angleBA] = getAngleBetweenMice(gap, frames, mouseA_x_1, mouseA_y_1, mouseA_x_2, mouseA_y_2, mouseB_x_1, mouseB_y_1, mouseB_x_2, mouseB_y_2)
    angleAB = zeros(frames, 1);
    angleBA = zeros(frames, 1);
    for i = 1:frames
        vectorA = [mouseA_x_1(i) - mouseA_x_2(i), mouseA_y_1(i) - mouseA_y_2(i)];
        vectorA_gap = [mouseA_x_1(i+gap) - mouseA_x_2(i+gap), mouseA_y_1(i+gap) - mouseA_y_2(i+gap)];
        vectorB = [mouseB_x_1(i) - mouseB_x_2(i), mouseB_y_1(i) - mouseB_y_2(i)];
        vectorB_gap = [mouseB_x_1(i+gap) - mouseB_x_2(i+gap), mouseB_y_1(i+gap) - mouseB_y_2(i+gap)];
        thetaAB = acos(min(1,max(-1, vectorA(:).' * vectorB_gap(:) / norm(vectorA) / norm(vectorB_gap))));
        thetaBA = acos(min(1,max(-1, vectorA_gap(:).' * vectorB(:) / norm(vectorA_gap) / norm(vectorB))));
        angleAB(i) = thetaAB / pi * 180;
        angleBA(i) = thetaBA / pi * 180;
    end
end

function velocity = getVelocity(frames, mouse_x, mouse_y)
    %velocity per frame = distance per frame
    velocity = zeros(frames-1, 1);
    for i = 1:(frames-1)
        velocity(i) = sqrt((mouse_x(i) - mouse_x(i+1))^2 + (mouse_y(i) - mouse_y(i+1))^2);
    end
end

function [differenceAB, differenceBA] = getDifference(frames, variableAB, variableBA)
    differenceAB = zeros(frames-1, 1);
    differenceBA = zeros(frames-1, 1);
    for i = 1:(frames-1)
        differenceAB(i) = abs(variableAB(i) - variableAB(i+1));
        differenceBA(i) = abs(variableBA(i) - variableBA(i+1));
    end
end

function [differenceAB, differenceBA] = getDifference_Velocity(gap, frames, mouseA_velocity, mouseB_velocity)
    differenceAB = zeros(frames-1, 1);
    differenceBA = zeros(frames-1, 1);
    for i = 1:(frames-1)
        differenceAB(i) = abs(mouseA_velocity(i) - mouseB_velocity(i+gap));
        differenceBA(i) = abs(mouseA_velocity(i+gap) - mouseB_velocity(i));
    end
end

function draw3DPlot(mice_distance_difference, mice_velocity_difference, mice_angle_difference)
    plot3(mice_distance_difference, mice_velocity_difference, mice_angle_difference, '.');
end

function analyzeOverNFrames(filename,N,NumberOfFrames,mouseA_x_1,mouseA_y_1,mouseA_x_2,mouseA_y_2,mouseB_x_1,mouseB_y_1,mouseB_x_2,mouseB_y_2,mouseA_velocity,mouseB_velocity)
    [mice_distance_AB, mice_distance_BA] = getDistanceBetweenMice(N,NumberOfFrames,mouseA_x_1,mouseA_y_1,mouseB_x_1,mouseB_y_1);
    [mice_angle_AB, mice_angle_BA] = getAngleBetweenMice(N,NumberOfFrames,mouseA_x_1,mouseA_y_1,mouseA_x_2,mouseA_y_2,mouseB_x_1,mouseB_y_1,mouseB_x_2,mouseB_y_2);
    [mice_distance_difference_AB, mice_distance_difference_BA] = getDifference(NumberOfFrames,mice_distance_AB,mice_distance_BA);
    [mice_velocity_difference_AB, mice_velocity_difference_BA] = getDifference_Velocity(N,NumberOfFrames,mouseA_velocity, mouseB_velocity);
    [mice_angle_difference_AB, mice_angle_difference_BA] = getDifference(NumberOfFrames,mice_angle_AB,mice_angle_BA);
    [synchrony_AB, synchrony_BA] = findSynchrony(NumberOfFrames,mice_distance_difference_AB, mice_distance_difference_BA, mice_velocity_difference_AB, mice_velocity_difference_BA, mice_angle_difference_AB, mice_angle_difference_BA);
    [time_range_AB, time_range_BA] = findTimeRange(NumberOfFrames,synchrony_AB, synchrony_BA);
    outputToText(filename, N, NumberOfFrames, time_range_AB, time_range_BA);
    outputToExcel(filename, N+3, mice_distance_difference_AB, mice_distance_difference_BA, mice_velocity_difference_AB, mice_velocity_difference_BA, mice_angle_difference_AB, mice_angle_difference_BA, synchrony_AB, synchrony_BA);
end

function [synchronyAB, synchronyBA] = findSynchrony(frames,mice_distance_difference_AB, mice_distance_difference_BA, mice_velocity_difference_AB, mice_velocity_difference_BA, mice_angle_difference_AB, mice_angle_difference_BA)
    synchronyAB = zeros(frames-1, 1);
    synchronyBA = zeros(frames-1, 1);
    count = 1;
    for i = 1:(frames-1)
        if (mice_distance_difference_AB(i) < 5 && mice_velocity_difference_AB(i) < 5 && mice_angle_difference_AB(i) < 5)
            synchronyAB(count) = i;
            count = count + 1;
        end
    end
    count = 1;
    for i = 1:(frames-1)
        if (mice_distance_difference_BA(i) < 5 && mice_velocity_difference_BA(i) < 5 && mice_angle_difference_BA(i) < 5)
            synchronyBA(count) = i;
            count = count + 1;
        end
    end
end

function validity = validateTimeRange(start, frames, synchrony)
    n = 5;
    validity = false;
    if frames - start >= n
        validity = true;
        for i = 1:(n-1)
            validity = validity && (synchrony(start+i) - synchrony(start) == i);
        end
    end
end

function [timeRangeAB, timeRangeBA] = findTimeRange(frames, synchrony_AB, synchrony_BA)
    timeRangeAB = zeros(frames-1, 1);
    timeRangeBA = zeros(frames-1, 1);
    count = 1;
    for i = 1:(frames-1)
        if synchrony_AB(i) ~= 0
            if validateTimeRange(i, frames, synchrony_AB)
                timeRangeAB(count) = synchrony_AB(i);
                count = count + 1;
            end
        else
            break;
        end
    end
    count = 1;
    for i = 1:(frames-1)
        if synchrony_BA(i) ~= 0
            if validateTimeRange(i, frames, synchrony_BA)
                timeRangeBA(count) = synchrony_BA(i);
                count = count + 1;
            end
        else
            break;
        end
    end
end