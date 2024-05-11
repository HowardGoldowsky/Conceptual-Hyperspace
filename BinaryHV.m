classdef BinaryHV < Hypervector 
    % Class for Binary hypervectors. All samples either +1 or -1.
    
    % Required by abstract class Hypervector
    properties
        dimension   
        samples
    end % required properties
    
    % Specific to BinaryHV class
    properties
        
    end
      
    methods
               
        function obj = BinaryHV(op) % Constructor               
            arguments
                op.dimension       (1,1) double = 1000
                op.samples          (:,1) = [] 
            end
       
            obj. dimension =  op.dimension;
            if (isempty(op.samples))
                obj.samples = sign(randn(op.dimension, 1)); % zero-mean Gaussian distribution
            else
                obj.samples = op.samples;
            end
        end % constructor
        
        function obj = normalize(obj)
            % Makes the length of each phasor element equal to 1.
            obj.samples = obj.samples./abs(obj.samples);
        end
        
        function result = bind(v1,v2)
            boundSamples = v1.samples .* v2.samples;
            D = v1.dimension;
            result = BinaryHV('dimension', D, 'samples', boundSamples);
        end
        
        function result = unbind(v1,v2)
            unboundSamples = bind(v1,v2).samples; % unbinding is same as binding for Binary
            D = v1.dimension;
            result = BinaryHV('dimension', D, 'samples', unboundSamples);
        end
        
        function result = similarity(v1,v2)
            D = v1.dimension;
            result = (v1.samples'*v2.samples)/D;
        end
        
        function result = inverse(obj)
            % Swap 1 <==> -1 and vise verse. 
            D = obj.dimension;
            invSamples = ones(D,1);
            invSamples(obj.samples==1) = -1; % replace 1 with -1
            result = BinaryHV('dimension', D, 'samples', invSamples);                
        end    
    end % methods
end % class
