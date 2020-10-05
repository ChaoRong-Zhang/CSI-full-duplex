function results = polynomialCancellation(inputs_tr, targets_tr, inputs_te, targets_te, L, P)

% Initialize
residual = zeros(length(P), length(targets_te));
cancellation = zeros(length(P),1);

for ii = 1:length(P)
    
    % Prepare training dataset
    pamaxorder = P(ii);
    n_basis_functions = (pamaxorder + 1) / 2 * ((pamaxorder + 1) / 2 + 1);    
    A = zeros(length(inputs_tr), n_basis_functions*L);
    matInd = 0;    
    for jj = 1:2:pamaxorder
        for kk = 0:jj
            xnl = inputs_tr.^kk .* conj(inputs_tr).^(jj-kk);
            A(:, matInd*L+1:(matInd+1)*L) = xnl;
            matInd = matInd + 1;
        end
    end
    
    % Do the training
    h = pinv(A)*targets_tr;
    
    % Do non-linear cancellation
    A = zeros(length(inputs_te), n_basis_functions*L);
    matInd = 0;    
    for jj = 1:2:pamaxorder
        for kk = 0:jj
            xnl = inputs_te.^kk .* conj(inputs_te).^(jj-kk);
            A(:, matInd*L+1:(matInd+1)*L) = xnl;
            matInd = matInd + 1;
        end
    end
    residual(ii,:) = targets_te - A*h;
    
    % Calculate cancellation
    cancellation(ii) = 10*log10(mean(abs(targets_te).^2)/mean(abs(residual(ii,:)).^2));
    
end

% Return results
results.residual = residual;
results.cancellation = cancellation;
results.P = P;
results.L = L;