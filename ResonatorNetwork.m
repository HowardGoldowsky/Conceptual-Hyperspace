classdef ResonatorNetwork 
    % Resonator network class. Currently works with only three equivalent-size
    % code books.

    properties
        codeBook
        confidenceThreshold
        boundHV
    end % properties

    methods
        function obj = ResonatorNetwork(codeBook, boundHV, op) % constructor
            arguments
                codeBook(:,:)
                boundHV(1,1)
                op.confidenceThreshold (1,1) double = 0.5
            end
            obj.codeBook = codeBook;
            obj.boundHV = boundHV;
            obj.confidenceThreshold = op.confidenceThreshold;
        end

        function [idxFactorEst, iterationNum] = findFactors(obj)

            % Initializations
            done = false;
            iterationNum = 0;
            codebook = obj.codeBook;
            S = obj.boundHV;
            confidenceThresh = obj.confidenceThreshold;

            % Initialize factors and initialize product to a random binding of one factor from each book.
            x_hat = superimpose(codebook(:,1));
            y_hat = superimpose(codebook(:,2));
            z_hat = superimpose(codebook(:,3));
            
            % Initialize anonymous function. Function returns a PhasorHV with the
            % computed weighted samples. 
            factorUpdate = @(estimate,weight,dimension) PhasorHV('dimension', dimension, 'samples', estimate.samples*weight);
            
            while (~ done)
            
                % track itereation number
                iterationNum = iterationNum + 1;
            
                % first factor estimate by unbinding estimates of other factors from
                % product
                x_hat_temp = unbind(S, bind(y_hat, z_hat));
                y_hat_temp = unbind(S, bind(x_hat, z_hat));
                z_hat_temp = unbind(S, bind(x_hat, y_hat));
            
                % first matrix multiplication projects current noisy estimate to full
                % codebook
                x_hat_temp2 = arrayfun(@(x) similarity(x, x_hat_temp), codebook(:, 1) ); 
                y_hat_temp2 = arrayfun(@(y) similarity(y, y_hat_temp), codebook(:, 2) ); 
                z_hat_temp2 = arrayfun(@(z) similarity(z, z_hat_temp), codebook(:, 3) ); 
            
                x_hat_temp2 = abs(x_hat_temp2);
                y_hat_temp2 = abs(y_hat_temp2);
                z_hat_temp2 = abs(z_hat_temp2);
            
                % Observe confidence levels from the output of first multiplication.
                % Determine if all three confidence levels are above the threshold. If
                % yes, then we are done.
                xConfidence = max(x_hat_temp2);
                yConfidence = max(y_hat_temp2);
                zConfidence = max(z_hat_temp2);
                done = (xConfidence > confidenceThresh) && ...
                    (yConfidence > confidenceThresh) && ...
                    (zConfidence > confidenceThresh);
            
                % With larger codebooks, sometimes there is a tie for the best
                % resonating HV, and we need to randomly break this tie.
                try
                    idxFactorEst = [find(x_hat_temp2==xConfidence) ...
                        find(y_hat_temp2==yConfidence) ...
                        find(z_hat_temp2==zConfidence)];
                catch
                    idx1 = find(x_hat_temp2==xConfidence);
                    idx2 = find(y_hat_temp2==yConfidence);
                    idx3 = find(z_hat_temp2==zConfidence);
                    idxFactorEst = [idx1(1) idx2(1) idx3(1)];
                end
            
                % Second matrix multiplication produces the official estimate update
                % for this iteration. Here we create a weighted mean of the codebook.
            
                % same HV dimension for all codebooks
                dims = arrayfun(@(x) length(x.samples), codebook(:,1)); 
            
                % Create the components of weighted mean.
                x_hat_temp3 = arrayfun(@(a, b, d) factorUpdate(a,b,d), codebook(:, 1), x_hat_temp2, dims, 'UniformOutput', true);
                y_hat_temp3 = arrayfun(@(a, b, d) factorUpdate(a,b,d), codebook(:, 2), y_hat_temp2, dims, 'UniformOutput', true);
                z_hat_temp3 = arrayfun(@(a, b, d) factorUpdate(a,b,d), codebook(:, 3), z_hat_temp2, dims, 'UniformOutput', true);
            
                x_hat = superimpose(x_hat_temp3);
                y_hat = superimpose(y_hat_temp3);
                z_hat = superimpose(z_hat_temp3);
               
             end % while ~ done

        end % findFactors()

    end % methods
end % end class