function [Recon] = ezdasNoSum(SIG,TXangle,p)

[X,Z] = meshgrid(p.xCoord,p.zCoord);
X = X(:); Z = Z(:);

% transmit and recieve distances
dTX = (sign(TXangle)*p.L/2 + X).*sin(TXangle) + Z*cos(TXangle);
dRX = hypot(X-p.ElemPos,Z);

% two-way travel times
tau = (dTX + dRX)/p.c + p.t0;

% fast-time indices
idxt = tau*p.fs + 1;

% boolean vectors
I = idxt>=1 & idxt<= p.szAcq-1;
Iaperture = abs(X-p.ElemPos)<=(Z/2/p.fnumber);
I = (I&Iaperture).';
I = I(:);

% linear indices
idx = (idxt + (0:p.numEl-1)*p.szAcq).';
idx = idx(:);
idx = idx(I);

idxf = floor(idx);
idx = idxf-idx;

% DAS matrix

% since 'I' was linearized, its row indices correspond to the linear pixel
% index. The row dimension of the sparse matrix corresponds to the linear
% pixel index, so this is essentially defining that portion.
[i,~] = find(I);    
s = [idx+1;-idx]; % (for linear interpolation)

M = sparse([i;i],[idxf;idxf+1],s,numel(X)*p.numEl,p.szAcq*p.numEl);

% DAS beamforming
Recon = reshape(M*SIG(:),[p.numEl,1,p.nPoints]);

end

