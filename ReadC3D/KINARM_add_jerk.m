function dataOut = KINARM_add_jerk(dataIn)
%KINARM_ADD_JERK Calculate linkage and hand jerk.
% DATA_OUT = KINARM_ADD_JERK(DATA_IN) calculates the joint and hand jerk.
%	These data are added as new fields to the DATA_IN structure. 
%
%	The input structure DATA_IN	is in one forms, based on exam_load:
%   data = exam_load;
%   dataNew = KINARM_add_jerk(data)
%     OR
%   dataNew.c3d = KINARM_add_jerk(data(ii).c3d)
%
% This function calculates jerk (the derivative of acceleration) for both
% the angular kinematics and the end-point (i.e. Hand X and Y). This
% function should be called BEFORE filtering the data.
%
% Methods: to avoid quantization error, angular velocity and acceleration
% are first re-calculated using a difference equation with a 10 ms time
% bin. Angular jerk is then calculated in a similar manner (10 ms time bin).
%
% All calculations use central difference formulas to avoid any delays/lag. 
% Because difference calculations effectively low-pass filter the data, the 
% jerk data produced by this script with its 10 ms bins will be attenuated 
% at higher frequencies. The impact is effectively the same as a 3rd order 
% filter with an overall 3 dB cutoff frequency of ~26 Hz (note: 3rd order, 
% because there are 3 difference calculations).  
%
% Jerk at the end-point is then calculated from all of these re-calculated
% kinematics
%
%	The new fields are in units of m/s^3, and are in a global
%	coordinate system (as per Right_HandX, Left_HandY etc) and are:  
% 		.Right_L1Jrk
% 		.Right_L2Jrk
% 		.Right_HandYJrk
% 		.Right_HandXJrk
% 		.Left_L1Jrk
% 		.Left_L2Jrk
% 		.Left_HandYJrk
% 		.Left_HandXJrk

	dataOut = dataIn;
    if isempty(dataIn)
        return;
    end

    if isfield(dataIn, 'c3d')
        for jj = 1:length(dataOut)
            dataOut(jj).c3d = dataset_jerk(dataIn(jj).c3d);
        	dataOut(jj).c3d = ReorderFieldNames(dataIn(jj).c3d, dataOut(jj).c3d );
            dataOut(jj).c3d = record_analysis(dataOut(jj).c3d);
            
            was_method_run(dataOut(jj).c3d, 'filter_double_pass', false);
            disp( ['Finished adding KINARM jerk to ' dataIn(jj).filename{:}] );
        end
    else
        dataOut = dataset_jerk(dataIn);
    	dataOut = ReorderFieldNames(dataIn, dataOut);
        dataOut = record_analysis(dataOut);
        was_method_run(dataOut, 'filter_double_pass', false);
        disp( 'Finished adding KINARM jerk' );
    end
end

function dataOut = dataset_jerk(c3d)

    dataOut = c3d;
    dataTrialOne = c3d(1);
    sampleFreq = dataTrialOne.ANALOG.RATE;

    dt = 0.010;		% As per DEX-4059, jerk should be calculated using difference calculations and a 10 ms time step.
    n = round(sampleFreq * dt);

    for trial = 1:length(dataOut)
        for jj = 1:2

            if jj == 1
                side = 'RIGHT';
                side2 = 'Right';
            else 
                side = 'LEFT';
                side2 = 'Left';
            end	

            % NOTE: the following two if statements handle legacy data in
            % which not all fields were saved. 
            if ~isfield(dataTrialOne, [side '_KINARM']) || ~isfield(dataTrialOne.([side '_KINARM']), 'VERSION')
                continue
            end

            if isfield(dataTrialOne, [side2 '_HandX']) && (~isfield(dataTrialOne, [side2 '_KINARM']) || dataTrialOne.([side '_KINARM']).IS_PRESENT)
                % Check the version of the KINARM
                version = dataTrialOne.([side '_KINARM']).VERSION;
                if strncmp('KINARM_EP', version, 9)
                    % KINARM End-Point robot
                    L1 = dataTrialOne.([side '_KINARM']).L1_L;
                    L2 = dataTrialOne.([side '_KINARM']).L2_L;
                    L2PtrOffset = 0;
                elseif strncmp('KINARM_H', version, 8) || strncmp('KINARM_M', version, 8)
                    % KINARM Exoskeleton robot
                    L1 = dataTrialOne.CALIBRATION.([side '_L1']);
                    L2 = dataTrialOne.CALIBRATION.([side '_L2']);
                    L2PtrOffset = dataTrialOne.CALIBRATION.([side '_PTR_ANTERIOR']);
                    if strcmp(side, 'LEFT')
                        % L2PtrOffset is in global coordinates, not local, so change sign
                        % as compared to the right hand.
                        L2PtrOffset = -L2PtrOffset;
                    end
                else
                    % unidentified robot
                    error(['unidentified ' side ' KINARM robot type']);
                end

                L1Ang = dataOut(trial).([side2 '_L1Ang']);
                L2Ang = dataOut(trial).([side2 '_L2Ang']);

                % Re-calcluate angular velocities and accelerations
                % using central difference equations. Calculate angular
                % jerk the same way 
                L1Vel = calcDiff(L1Ang, dt, n);
                L2Vel = calcDiff(L2Ang, dt, n);
                L1Acc = calcDiff(L1Vel, dt, n);
                L2Acc = calcDiff(L2Vel, dt, n);
                L1Jrk = calcDiff(L1Acc, dt, n);
                L2Jrk = calcDiff(L2Acc, dt, n);

                % Calculate hand jerk from the re-calculated angulare kinematics
                sinL1 = sin(L1Ang);
                cosL1 = cos(L1Ang);
                sinL2 = sin(L2Ang);
                cosL2 = cos(L2Ang);
                sinL2ptr = cosL2;
                cosL2ptr = -sinL2;

                hjx = -L1 * (-sinL1.*L1Vel.^3 + 3*cosL1.*L1Vel.*L1Acc + sinL1.*L1Jrk)...
                     - L2 * (-sinL2.*L2Vel.^3 + 3*cosL2.*L2Vel.*L2Acc + sinL2.*L2Jrk)...
                     - L2PtrOffset * (-sinL2ptr.*L2Vel.^3 + 3*cosL2ptr.*L2Vel.*L2Acc + sinL2ptr.*L2Jrk);
                hjy =  L1 * (-cosL1.*L1Vel.^3 - 3*sinL1.*L1Vel.*L1Acc + cosL1.*L1Jrk)...
                     + L2 * (-cosL2.*L2Vel.^3 - 3*sinL2.*L2Vel.*L2Acc + cosL2.*L2Jrk)...
                     + L2PtrOffset * (-cosL2ptr.*L2Vel.^3 - 3*sinL2ptr.*L2Vel.*L2Acc + cosL2ptr.*L2Jrk);				

                % Save the data into the output data structure
                dataOut(trial).([side2 '_L1Jrk']) = L1Jrk;
                dataOut(trial).([side2 '_L2Jrk']) = L2Jrk;
                dataOut(trial).([side2 '_HandXJrk']) = hjx;
                dataOut(trial).([side2 '_HandYJrk']) = hjy;
            end
        end
    end
end

function diffOut = calcDiff(dataIn, dt, n)
	% Estimate derivatives using central differences.
	% Central difference formulat is used to avoid adding any delays to the
	% estimates. 
	% Data are reflected at the start and the end.
	
    if n >= length(dataIn)
        diffOut = zeros(length(dataIn), 1) * nan;
        return
    end
    
	n1 = ceil(n/2);
	n2 = n - n1;
	try
	diffOut = [nan(n1, 1); (dataIn((n+1):end) - dataIn(1:(end-n)) ); nan(n2, 1)] ./ dt;
	catch
% 	diffOut = [nan(n1, 1); (dataIn((n+1):end) - dataIn(1:(end-n)) )'; nan(n2, 1)] ./ dt;
	end
	    
	% replace the beginning and end NaNs with reflected versions
	% NOTE: nans can occur from the input dt, as well as from the explicit
	% inclusion above.
	idxnan = isnan(diffOut);
	idx1 = find(~idxnan, 1);
	idx2 = find(~idxnan, 1, 'last');
	
	dataToReflect = diffOut(idx1:(2*idx1 - 1));
	reflectedData = flipud(-(dataToReflect - dataToReflect(1)) + dataToReflect(1) );
	diffOut(1:idx1) = reflectedData;

	dataToReflect = diffOut((2 * idx2 - end):idx2);
	reflectedData = flipud(-(dataToReflect - dataToReflect(end)) + dataToReflect(end) );
	diffOut(idx2:end) = reflectedData;
end

function dataOut = ReorderFieldNames(dataIn, dataOut)
	%re-order the fieldnames so that the hand velocity, acceleration and
	%commanded forces are with the hand position at the beginning of the field
	%list 
	origNames = fieldnames(dataIn);
	tempNames = fieldnames(dataOut);
	rightNames = {'Right_HandXJrk'; 'Right_HandYJrk'; 'Right_L1Jrk'; 'Right_L2Jrk';};
	leftNames = {'Left_HandXJrk'; 'Left_HandYJrk'; 'Left_L1Jrk'; 'Left_L2Jrk';};

	%check to see if any right-handed or left-handed fields were added to the
	%output data structure
	addedRightToOutput = false;
	addedLeftToOutput = false;
	for ii = 1:length(rightNames)
		if isempty( strmatch(rightNames{ii}, origNames, 'exact') ) && ~isempty( strmatch(rightNames{ii}, tempNames, 'exact') )
			addedRightToOutput = true;
		end
		if isempty( strmatch(leftNames{ii}, origNames, 'exact') ) && ~isempty( strmatch(leftNames{ii}, tempNames, 'exact') )
			addedLeftToOutput = true;
		end
	end

	if addedRightToOutput
		% remove all of the new fields from the original list
		for ii = 1:length(rightNames)
			index = strmatch(rightNames{ii}, origNames, 'exact');
			if ~isempty(index)
				origNames(index) = [];
			end
		end
		% place the new fields right after the HandY field
		index = strmatch('Right_HandY', origNames, 'exact');
		newNames = cat(1, origNames(1:index), rightNames, origNames(index+1:length(origNames)));
	else
		newNames = origNames;
	end

	if addedLeftToOutput
		% remove all of the new fields from the original list
		for ii = 1:length(leftNames)
			index = strmatch(leftNames{ii}, origNames, 'exact');
			if ~isempty(index)
				origNames(index) = [];
			end
		end
		% place the new fields right after the HandY field
		index = strmatch('Left_HandY', newNames, 'exact');
		newNames = cat(1, newNames(1:index), leftNames, newNames(index+1:length(newNames)));
	end
	dataOut = orderfields(dataOut, newNames);
end