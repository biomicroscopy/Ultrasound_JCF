clearvars
close all

%% Load Data

currentDir = matlab.desktop.editor.getActiveFilename; 
currentDir = regexp(currentDir, filesep, 'split');
dataFilePath = fullfile(currentDir{1:end-1},"Raw Data\");

% dataFile{1} = dataFilePath + "CIRS1.mat";
% dataFile{1} = dataFilePath + "Thigh9LD.mat";
% dataFile{1} = dataFilePath + "Calf9LD_1.mat";
% dataFile{1} = dataFilePath + "Calf9LD_2.mat";
% dataFile{1} = dataFilePath + "Calf9LD_3_45ang.mat";
% filetype = 0;

dataFile{1} = dataFilePath + "Calf45AngMultiPower.mat";
filetype = 1;

[p,RFData] = initData(dataFile{1},filetype);

%% Preprocess data
cRF = hilbert(RFData);

%% Process data

% Define a smaller subregion of image if you don't want to wait to process
% whole image. 

% Example Zoomed in Region for Calf45AngMultiPower Dataset
p2 = computeNewGrid(p,[1,p.szX],[1,p.szZ],p.szX*4,p.szZ*4);
p2 = computeNewGrid(p2,[250,340],[520,660]);

images = memConstrainedBFM(p2,cRF);

%% Plotting
cFactor = 0.25;
[~,g1] = computeContrastMatch(images(1).data,images(2).data,cFactor);
[~,g2] = computeContrastMatch(images(1).data,images(3).data,cFactor);
[~,g4] = computeContrastMatch(images(1).data,images(4).data,cFactor);


figure
plotGammaScaleImage(p2.xCoord*1e3,p2.zCoord*1e3,images(1).data,cFactor);
axis image

figure
plotGammaScaleImage(p2.xCoord*1e3,p2.zCoord*1e3,images(2).data,g1);
axis image

figure
plotGammaScaleImage(p2.xCoord*1e3,p2.zCoord*1e3,images(3).data,g2);
axis image

figure
plotGammaScaleImage(p2.xCoord*1e3,p2.zCoord*1e3,images(4).data,g4);
axis image


%% Helper Functions
function [images] = memConstrainedBFM(pGlobal, cRF)

    % This function is to account for low memory when attempting to
    % beamform without summation along aperture. Breaks pixel grid up into
    % smaller chunks and performs operations on smaller chunks, storing
    % final results. 
    images = repmat(struct("data", zeros(pGlobal.szZ, pGlobal.szX), "name", []), 1, 3);

    % Check if enough memory. If so, apportion chunks accordingly
    [~, sys] = memory;
    memFac = floor(sys.PhysicalMemory.Available / prod([pGlobal.numEl, pGlobal.na, pGlobal.szZ, 8, 2, 4]));
    if memFac > 1
        chnks = 1:memFac:pGlobal.szX;
        chnks2 = [chnks(2:end), pGlobal.szX];
        chnks2(1:end-1) = chnks2(1:end-1) - 1;
    else
        error('Not enough memory to perform even one column of a calculation');
    end

    % Create a waitbar for the outer loop
    hOuterWaitBar = waitbar(0, 'Initializing...');

    for i = 1:length(chnks)
        % Update the outer waitbar
        waitbar(i / length(chnks), hOuterWaitBar, ['Processing chunk ', num2str(i), ' of ', num2str(length(chnks))]);

        % Define sub grid region
        p = computeNewGrid(pGlobal, [chnks(i), chnks2(i)], [1, pGlobal.szZ]);

        % Beamform data
        dstr = "Beamforming data for chunk " + num2str(i) + "/" + num2str(length(chnks));
        disp(dstr);
        idxtMTX = zeros(p.numEl, p.na, p.nPoints);

        % Create a waitbar for the inner loop
        hInnerWaitBar = waitbar(0, 'Beamforming...');

        for k = 1:p.na
            % Update the inner waitbar
            waitbar(k / p.na, hInnerWaitBar, ['Beamforming data for chunk ', num2str(i), ' of ', num2str(length(chnks)), ', step ', num2str(k), ' of ', num2str(p.na)]);
            
            idxtMTX(:, k, :) = ezdasNoSum(cRF(:, :, k), p.TXangle(k), p);
        end

        % Close the inner waitbar
        close(hInnerWaitBar);

        % Compute JCFs
        dstr = "Postprocessing data for chunk " + num2str(i) + "/" + num2str(length(chnks));
        disp(dstr);
        imgSlices = genImages(idxtMTX, p, i, length(chnks));

        for n = 1:length(imgSlices)
            images(n).data(:, chnks(i):(chnks2(i))) = imgSlices(n).data;
        end
        clearvars idxtMTX
    end

    % Close the outer waitbar
    close(hOuterWaitBar);

    % Assign names
    chk = [imgSlices(:).name];
    [images.name] = chk{:};
end

function images = genImages(idxtMTX, p, chunkIdx, totalChunks)

    images = struct("data", [], "name", []); n = 1;

    images(n).data = reshape(squeeze(sum(idxtMTX, [1, 2])), [p.szZ, p.szX]);
    images(n).name = "BMode"; n = n+1;
    
    % JCF
    hJCFWaitBar = waitbar(0, 'Computing JCF...');
    images(n).data = computeJCF(idxtMTX, p, 1, chunkIdx, totalChunks, hJCFWaitBar);
    images(n).name = "JCF_1"; n = n+1;
    images(n).data = computeJCF(idxtMTX, p, 2, chunkIdx, totalChunks, hJCFWaitBar);
    images(n).name = "JCF_2"; n = n+1;
    images(n).data = computeJCF(idxtMTX, p, 4, chunkIdx, totalChunks, hJCFWaitBar);
    images(n).name = "JCF_4"; n = n+1;
    close(hJCFWaitBar);
end