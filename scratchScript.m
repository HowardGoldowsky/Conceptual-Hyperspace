% Script from scratch

numBasis = 3;
maxRange = 10;
resolution = 0.5;
standDev = 100*pi;

[codebook, codebookRange, basesSet] = buildCodebook(numBasis, maxRange, resolution, standDev);

PURPLE = bind(basesSet(1).encode(6.2), bind(basesSet(2).encode(-6.2), basesSet(3).encode(5.3))); 
BLUE = bind(basesSet(1).encode(0), bind(basesSet(2).encode(-10), basesSet(3).encode(5))); 
ORANGE = bind(basesSet(1).encode(6.7), bind(basesSet(2).encode(5.7), basesSet(3).encode(10))); 

% Execute parallelogram Method
X = bind(unbind(ORANGE, PURPLE),BLUE);

RN = ResonatorNetwork(codebook, X); % constructor
[idxFactorEst, iterationNum] = RN.findFactors
