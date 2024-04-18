function plotGammaScaleImage(varargin)
% function to automatically scale and plot image on log based color scale
% accepts two forms of input:
%   plotGammaScaleImage(xCoord,zCoord,img) - plots with labelled axes
%   plotGammaScaleImage(img) - plots with unlabelled axes
% also sets the limits of the colormap based on the variability of the
% values contained in the matrix.

if (nargin == 4)
    ax = gca;
    xCoord = varargin{1};
    zCoord = varargin{2};
    imgData = varargin{3};
    scale = varargin{4};
elseif (nargin == 2)
    ax = gca;
    imgData = varargin{1};
    scale = varargin{2};
elseif (nargin == 3)
    ax = varargin{1};
    imgData = varargin{2};
    scale = varargin{3};
elseif (nargin == 5)
    ax = varargin{1};
    xCoord = varargin{2};
    zCoord = varargin{3};
    imgData = varargin{4};
    scale = varargin{5};
else
    error("Incorrect number of inputs");
end

% scale image and remove infinity or zero values
envelope = abs(imgData).^scale;
scaledImg = (envelope./max(envelope(:)));
scaledImg(isinf(scaledImg)) = 0;
scaledImg(isnan(scaledImg)) = 0;

% figure
colormap gray
if (nargin >= 4)
    imagesc(ax,xCoord,zCoord,scaledImg)
elseif (nargin <= 3)
    imagesc(ax,scaledImg)
end

end