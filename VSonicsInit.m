

lambda = Resource.Parameters.speedOfSound/(Trans.frequency*1e6);

% Specify Grid is defined using default definition from Verasonics
% example scripts. Grid can be redefined using computeNewGrid function
PData(1).PDelta = [Trans.spacing, 0, 0.5];
PData(1).Size(1) = ceil((P.endDepth-P.startDepth)/PData(1).PDelta(3)); % startDepth, endDepth and pdelta set PData(1).Size.
PData(1).Size(2) = ceil((Trans.numelements*Trans.spacing)/PData(1).PDelta(1));
PData(1).Size(3) = 1;      % single image page
PData(1).Origin = [-Trans.spacing*(Trans.numelements-1)/2,0,P.startDepth]; % x,y,z of upper lft crnr.

xCoord = (PData(1).Origin(1) + (0:PData(1).Size(2)-1)*PData(1).PDelta(1))*lambda;
zCoord = (PData(1).Origin(3) + (0:PData(1).Size(1)-1)*PData(1).PDelta(3))*lambda;

wvlToM = Resource.Parameters.speedOfSound/(Trans.frequency*1e6);

fs = Receive(1).decimSampleRate*1e6;
pitch = Trans.spacingMm*1e-3;
fc = Trans.frequency*1e6;
c = Resource.Parameters.speedOfSound;
% Compute fnumber as a function of transmit NA if TXangle exists. Otherwise
% set to arbitrary value:
if (exist('TXangle'))
    NA = sin(range(TXangle)/2);
    fnumber = cot(2*asin(NA));
else
    fnumber = 1/0.6;
end

t0 = (-Receive(1).startDepth + TW(1).peak + 2*Trans.lensCorrection)/(Trans.frequency*1e6);
ElemPos = Trans.ElementPos(:,1).'*wvlToM;
numEl = Trans.numelements;
szAcq=Receive(1).endSample-Receive(1).startSample+1;
szX=length(xCoord);
szZ=length(zCoord);
if isfield(Trans,'Connector')
    ConnMap=Trans.Connector.';
else
    ConnMap = double(1:Trans.numelements);
end
