function [JCF] = computeJCF(idxtMTX,p,alpha)

    JCF = zeros(size(idxtMTX));
    denomFactor = double(p.numEl*p.na);

    for i = 1:p.nPoints
        kMTX = idxtMTX(:,:,i);
        kMTX2 = abs(kMTX).^alpha;

        weightMTX = abs(sum(kMTX,1).*sum(kMTX,2)).^alpha ./ ...
          (denomFactor.^(alpha-1)*sum(kMTX2,1).*sum(kMTX2,2));

        weightMTX(isnan(weightMTX)) = 0;
        JCF(:,:,i) = weightMTX;
    end

    JCF = idxtMTX.*(JCF);
    JCF = reshape(squeeze(sum(JCF,[1,2])/denomFactor),[p.szZ,p.szX]);
end