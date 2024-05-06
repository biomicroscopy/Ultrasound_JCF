clearvars
close all

%% Load Data

currentDir = matlab.desktop.editor.getActiveFilename; 
currentDir = regexp(currentDir, filesep, 'split');
dataFilePath = fullfile(currentDir{1:end-1},"Raw Data\");

% dataFile{1} = dataFilePath + "CIRS1.mat";
dataFile{1} = dataFilePath + "Thigh9LD.mat";
dataFile{1} = dataFilePath + "Calf9LD_1.mat";
dataFile{1} = dataFilePath + "Calf9LD_2.mat";
dataFile{1} = dataFilePath + "Calf9LD_3_45ang.mat";

[p,RFData] = initData(dataFile{1});

%% Preprocess data
cRF = hilbert(RFData);

%% Beamform data

ReconFull = zeros(p.numEl,p.na,p.nPoints);
for i = 1:p.na
    ReconFull(:,i,:) = ezdasNoSum(cRF(:,:,i),p.TXangle(i),p);
end

%% Post Process Data
BMode = reshape(squeeze(sum(ReconFull,[1,2])),[p.szZ,p.szX]);

tic; JCF1 = computeJCF(ReconFull,p,1); toc
tic; JCF2 = computeJCF(ReconFull,p,2); toc
tic; JCF4 = computeJCF(ReconFull,p,4); toc

%% Plotting
cFactor = 0.25;
[~,g1] = computeContrastMatch(BMode,JCF1,cFactor);
[~,g2] = computeContrastMatch(BMode,JCF2,cFactor);
[~,g4] = computeContrastMatch(BMode,JCF4,cFactor);


figure
plotGammaScaleImage(p.xCoord*1e3,p.zCoord*1e3,BMode,cFactor);
axis image

figure
plotGammaScaleImage(p.xCoord*1e3,p.zCoord*1e3,JCF1,g1);
axis image

figure
plotGammaScaleImage(p.xCoord*1e3,p.zCoord*1e3,JCF2,g2);
axis image

figure
plotGammaScaleImage(p.xCoord*1e3,p.zCoord*1e3,JCF4,g4);
axis image