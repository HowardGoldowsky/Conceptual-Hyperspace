% function to build a codebook

function [codebook, codebookRange, basesSet] = buildCodebook(numBasis, maxRange, resolution, standDev)

    % Build code book from the basis
    codebookRange = -maxRange : resolution : maxRange;                 % range of each code book
    numHV = length(codebookRange);
    
    % initialize codebook
    codebook(numHV,numBasis) = PhasorHV;
    basesSet(numBasis,1) = PhasorHV;
    
    for i = 1:numBasis
        basesSet(i) = PhasorHV('dimension',10000,'standDev',standDev,'distribution','normal');
    end
    
    % Same basis for each code book but different FPE for each HV within each codebook
    for i = 1:numBasis
            for j = 1:numHV
                % Fresh FPE for each HV in the codebook. Linearly seperate each
                % location within conceptual space. FPE each HV with its
                % posiiton number.
                codebook(j,i) = basesSet(i).encode(codebookRange(j));
            end % for j
    
    end % for i

end