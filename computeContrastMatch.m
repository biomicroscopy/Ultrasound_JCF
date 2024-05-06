function [targIm_adj,g] = computeContrastMatch(refIm,targIm,cFactor)

    img=abs(refIm).^cFactor;
    img(isinf(img)) = 0;
    img(isnan(img)) = 0;
    mB=mean(img,'all');
    kB=var(img,[],'all')/mB^2;

    g0=0.05;
    imdat = abs(targIm);
    imdat(isinf(imdat)) = 0;
    imdat(isnan(imdat)) = 0;
    F = @(x) [kB-var(imdat.^x,[],'all')/mean(imdat.^x,'all')^2];
    g=fsolve(F,g0);

    targIm_adj = imdat.^g;
    targIm_adj=targIm_adj/mean(targIm_adj,'all')*mB;
end