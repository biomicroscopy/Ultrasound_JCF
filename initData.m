function [p,RFData] = initData(dataFile,filetype)

    if (filetype == 0)
        load(dataFile,'Trans','P','Resource','Receive','TW','TX','RcvData');
    
        TXangle = reshape([TX(:).Steer],2,[]);
        TXangle = TXangle(1,:);
        na = length(TXangle);
        RFData = zeros(Receive(1).endSample-Receive(1).startSample+1,Trans.numelements,na);
        
        VSonicsInit;

        for i = 1:na
            RFData(:,:,i) = RcvData{1}(Receive(i).startSample:Receive(i).endSample,ConnMap,1);
        end
    elseif (filetype == 1)
        load(dataFile{1});
        
        TXangle = reshape([TX(:).Steer],2,[]);
        TXangle = TXangle(1,:);
        na = length(TXangle);
        RFdata = RcvData{1};

        VSonicsInit;

        % Account for smaller aperture on tx/rx
        Apod = zeros(1,Trans.numelements);
        ap = TX(1).aperture;
        len = length(TX(1).Apod);
        Apod(ap:(ap+len-1)) = 1;
        Apod = logical(Apod);
        ElemPos = ElemPos(Apod);
        ConnMap = 1:len;
        xCoord = xCoord(Apod);
        numEl = len;
        szX = length(xCoord);

        RFdata = circshift(RFdata,-ap+1,2);

        RFData = zeros(szAcq,numEl,na);
        for i = 1:na
            RFData(:,:,i) = RFdata(Receive(i).startSample:Receive(i).endSample,ConnMap);
        end
    end
    
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


