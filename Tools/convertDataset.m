function dataset = convertDataset(fileName, L)

    % Set parameters
    dataOffset = 12;
    chanLen = L;
    offset = max(dataOffset-ceil(chanLen/2),1);

    % Load file
    datasetMat = load(fileName);

    % Re-arrange dataset
    txSamples = datasetMat.txSamples(1:end-offset);
    analogResidual = datasetMat.analogResidual(offset+1:end) - mean(datasetMat.analogResidual(offset+1:end));

    % Initialize
    inputsComplex = zeros(length(txSamples)-chanLen,chanLen);
    inputs = zeros(length(txSamples)-chanLen,2*chanLen);
    for ii = 1:length(inputs)
        inputsComplex(ii,:) = fliplr(txSamples(ii+1:ii+chanLen)).';
        inputs(ii,:) = [ real(txSamples(ii+1:ii+chanLen))' imag(txSamples(ii+1:ii+chanLen))' ];
    end
    targets = analogResidual(chanLen+1:end);

    % Linear cancellation
    h = pinv(inputsComplex)*targets;
    cancelled = targets - inputsComplex*h;    
    cancellation = 10*log10(mean(abs(targets).^2)/mean(abs(cancelled).^2));
    
    % Normalize
    cancelled = cancelled/sqrt(mean(abs(cancelled).^2));

dataset.inputs_real = inputs;
dataset.inputs_complex = inputsComplex;
dataset.targets = cancelled;
dataset.linearCancellation = cancellation;



