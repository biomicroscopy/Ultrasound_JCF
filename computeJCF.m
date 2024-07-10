function [JCF] = computeJCF(idxtMTX, p, alpha, chunkIdx, totalChunks, hJCFWaitBar)

    JCF = zeros(size(idxtMTX));
    denomFactor = double(p.numEl * p.na);

    for i = 1:p.nPoints
        % Update the JCF waitbar
        waitbar(i / p.nPoints, hJCFWaitBar, ['Computing JCF for chunk ', num2str(chunkIdx), ' of ', num2str(totalChunks), ', alpha ', num2str(alpha), ', point ', num2str(i), ' of ', num2str(p.nPoints)]);
        
        kMTX = idxtMTX(:, :, i);
        kMTX2 = abs(kMTX).^alpha;

        weightMTX = abs(sum(kMTX, 1) .* sum(kMTX, 2)).^alpha ./ ...
            (denomFactor.^(alpha-1) * sum(kMTX2, 1) .* sum(kMTX2, 2));

        weightMTX(isnan(weightMTX)) = 0;
        JCF(:, :, i) = weightMTX;
    end

    JCF = idxtMTX .* (JCF);
    JCF = reshape(squeeze(sum(JCF, [1, 2]) / denomFactor), [p.szZ, p.szX]);
end