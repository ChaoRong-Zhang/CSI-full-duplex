function results = CPD_regression(opts)
%% init, get values from main

J = opts.I;                                      
f_type = opts.f_type;                            
tol = opts.tol;                                  
max_itr = opts.max_itr;
b = opts.b;

[F_, mu_, mu_smooth_, I] = ndgrid(opts.F, opts.mu, opts.mu_smooth, opts.I); 
comb_param = [F_(:), mu_(:), mu_smooth_(:), I(:)];    

[~, N] = size(opts.inputs_tr);

opts_inner = cell(size(comb_param, 1),1);

for i = 1:length(opts_inner)
    opts_inner{i}.targets_vl = opts.targets_vl;
    opts_inner{i}.targets_te = opts.targets_te;
    opts_inner{i}.tr_ind = opts.tr_ind;
    opts_inner{i}.vl_ind = opts.vl_ind;
    opts_inner{i}.te_ind = opts.te_ind;
end

targets_tr = opts.targets_tr;

%% init, pre-allocate with zeros

X = cell(size(comb_param, 1), 1);
b_out = cell(size(comb_param, 1), 1);
Out = cell(size(comb_param, 1), 1);
I = cell(1,N);

inputs = cell(length(J),1);
inputs_tr = cell(length(J),1);
inputs_vl = cell(length(J),1);
inputs_te = cell(length(J),1);

%% Discretize data

for i=1:length(J)
    [inputs{i}, I{i}, ~] = N_discretize([opts.inputs_tr; opts.inputs_vl; opts.inputs_te], J(i), N, f_type, 'kmeans');
    inputs_tr{i} = inputs{i,1}(opts_inner{1}.tr_ind, :);
    inputs_vl{i} = inputs{i,1}(opts_inner{1}.vl_ind, :);
    inputs_te{i} = inputs{i,1}(opts_inner{1}.te_ind, :);
end

for i = 1:size(comb_param,1)
    opts_inner{i}.inputs_tr = inputs_tr{J == comb_param(i,4)};
    opts_inner{i}.inputs_te = inputs_te{J == comb_param(i,4)};
    opts_inner{i}.inputs_vl = inputs_vl{J == comb_param(i,4)}; 
end

%parfor i=1:size(comb_param,1) % uncomment this line and comment the next one to run using MATLAB's parallel toolbox
for i=1:size(comb_param,1)
    [X{i}, b_out{i}, Out{i}] = csid(opts_inner{i}.inputs_tr, targets_tr, comb_param(i, 1), comb_param(i,4)*ones(1,size(inputs{1},2)), ...
        f_type, opts_inner{i}, 'reg_fro', comb_param(i, 2), 'reg_smooth', comb_param(i, 3), ...
        'max_itr', max_itr, 'tol', tol, 'bias', b, 'printitn', Inf);
end

results.X = X;
results.b_out = b_out;
results.Out = Out;
results.comb_param = comb_param;

end