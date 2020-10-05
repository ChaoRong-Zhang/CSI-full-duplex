%% Initialize

clc
clearvars
close all
rng(42)                                                
addpath('tensor_toolbox-v3.1')                          
addpath('Datasets')
addpath('Results')

%%% CPD settings
% Discretization steps
I = [ 2^2 2^3 2^4 2^5 2^6 2^7 ];
% Tensor rank
F = [ 1 2 3 4 5 ];
% Regularization (tensor values and smoothness)
mu = [ 1e-6 1e-5 1e-4 1e-3 ];
mu_smooth = [ 1e-4 1e-3 1e-2 1e-1 ];
% Maximum iterations
max_itr = 200;
% Tolerance
tol = 1e-6;
% Bias term
b = 0;

%%% Polynomial settings
P = [ 3 5 7 9 11 ];

%%% General settings
% Channel length
L = 2;
% Data split 
p_vl = 0.1;
p_te = 0.1;

%% Load and prepare dataset
fileName = './Datasets/signal-20MHz_sampled-80MHz_txAmp-8_circulator_passive-50dB_iq-0.mat';
dataset = convertDataset(fileName, L);  % Read dataset
                                                
inputs_cpd = dataset.inputs_real;
targets_cpd = dataset.targets;
inputs_poly = dataset.inputs_complex;
targets_poly = dataset.targets;
f_type = zeros(1,size(inputs_cpd,2));                    % All inputs are ordinal
[n_samples, N] = size(inputs_cpd);                       % Number of samples is saved in n_samples
                                       
% Split into training, validation, and test sets

indices = zeros(n_samples,1);
indices(1:floor(n_samples*(1-p_vl-p_te))) = 0;
indices(ceil(n_samples*(1-p_vl-p_te)):floor(n_samples*(1-p_vl))) = 1;
indices(ceil(n_samples*(1-p_vl)):end) = 2;
                                                        
% Add data to structure
opts.tr_ind = find(indices==0);                     % Get positions of train data
opts.vl_ind = find(indices==1);                     % Get positions of validation data
opts.te_ind = find(indices==2);                     % Get positions of test data
opts.inputs_tr = inputs_cpd(opts.tr_ind, :);         
opts.targets_tr = targets_cpd(opts.tr_ind,:);        
opts.inputs_vl = inputs_cpd(opts.vl_ind, :);         
opts.targets_vl = targets_cpd(opts.vl_ind,:);        
opts.inputs_te = inputs_cpd(opts.te_ind, :);         
opts.targets_te = targets_cpd(opts.te_ind,:);        

%% Perform training and cancellation

% Run CSID cancellation
opts.f_type = f_type;
opts.I = I;
opts.F = F;
opts.mu = mu;
opts.mu_smooth = mu_smooth;
opts.max_itr = max_itr;
opts.tol = tol;
opts.b = b;
opts.L = L;
results = CPD_regression(opts);
results.opts = opts;
results.fileName = fileName;
results.linearCancellation = dataset.linearCancellation;
mkdir('Results')
save(sprintf('Results/results_CPD_L%d.mat', L), 'results')

% Run polynomial cancellation
inputs_tr = inputs_poly(opts.tr_ind, :);         
targets_tr = targets_poly(opts.tr_ind,:);        
inputs_te = inputs_poly(opts.te_ind, :);         
targets_te = targets_poly(opts.te_ind,:);        
results = polynomialCancellation(inputs_tr, targets_tr, inputs_te, targets_te, L, P);
results.fileName = fileName;
results.linearCancellation = dataset.linearCancellation;
mkdir('Results')
save(sprintf('Results/results_poly_L%d.mat', L), 'results')
