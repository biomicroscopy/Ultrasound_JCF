function [p,RFData] = initData(dataFile)
    load(dataFile,'Trans','P','Resource','Receive','TW','TX','RcvData');

    TXangle = reshape([TX(:).Steer],2,[]);
    TXangle = TXangle(1,:);
    na = length(TXangle);
    RFData = zeros(Receive(1).endSample-Receive(1).startSample+1,Trans.numelements,na);
    if isfield(Trans,'Connector')
        ConnMap=Trans.Connector.';
    else
        ConnMap = double(1:Trans.numelements);
    end
    for i = 1:na
        RFData(:,:,i) = RcvData{1}(Receive(i).startSample:Receive(i).endSample,ConnMap,1);
    end

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

    % xCoord = ((-Trans.numelements/2):(Trans.numelements/2)-1)*Trans.spacingMm*1e-3;
    % zCoord = (P.startDepth:0.5:P.endDepth)*Resource.Parameters.speedOfSound/(Trans.frequency*1e6);

    wvlToM = Resource.Parameters.speedOfSound/(Trans.frequency*1e6);

    fs = Receive(1).decimSampleRate*1e6;
    pitch = Trans.spacingMm*1e-3;
    fc = Trans.frequency*1e6;
    c = Resource.Parameters.speedOfSound;
    fnumber = 0.6;

    t0 = (-Receive(1).startDepth + TW(1).peak + 2*Trans.lensCorrection)/(Trans.frequency*1e6);
    ElemPos = Trans.ElementPos(:,1).'*wvlToM;
    numEl = Trans.numelements;
    szAcq=Receive(1).endSample-Receive(1).startSample+1;
    szX=length(xCoord);
    szZ=length(zCoord);
    
    p = struct('fs',fs,...
            'pitch', pitch,...
            'fc', fc,...
            'c', c,...
            'fnumber', fnumber,...
            't0',t0,...
            'TXangle',TXangle,...
            'ElemPos',ElemPos,...
            'xCoord',xCoord,...
            'zCoord',zCoord,...
            'numEl',numEl,...
            'szAcq',szAcq,...
            'szX',szX,...
            'szZ',szZ,...
            'na',na);
        
    p.nPoints = p.szX*p.szZ;
    p.L = p.ElemPos(end)-p.ElemPos(1);
end