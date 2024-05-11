classdef (Abstract) Hypervector 
    
    % Abstract hypervector class. Constructor builds a generic hypervector
    % of all zeros of the specified dimension.
    
    properties (Abstract)
        dimension           (1,1) double
        samples
    end % properties
    
    methods
        
        function    obj = Hypervector()     % Constructor
        
        end
        
        function result = superimpose(vectors)   
            % Create a superposition of an array of PhasorHV objects and return an object of
            % class PhasorHV. Assumes all HV have the same dimension.
            % TODO: Make this function more dynamic by examining the
            % incoming type of HV and outputting the same type. e.g. this
            % should be generic for Boolean and Binary HV as well. 
            % There is also the question of should we normalize the output,
            % because the deVine & Bruza paper says that the "meaning" of the superposiiton
            % should be just the angle of the sample sums, not the sums
            % themselves. I personally think this is the correct approach,
            % and so this normalization has been done.
            N = length(vectors);
            D = vectors(1).dimension;
            x = reshape([vectors.samples].',N,D);   % MATLAB's (.') notation does not take the conjugate when taking the transpose.
            superpos = sum(x).';                              % MATLAB's (.') notation does not take the conjugate when taking the transpose.
            switch(class(vectors(1)))                       % test for object type
                case 'PhasorHV'
                    result = PhasorHV('dimension', D, 'samples', superpos);
                    result = result.normalize();
                case 'BinaryHV'
                    processedSuperpos = sign(superpos + rand(D,1)*0.1);                          % add small random number to change any zeros 
                    result = BinaryHV('dimension', D, 'samples', processedSuperpos);
            end % switch
        end                
    end % methods
    
end

