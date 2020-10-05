    function analyzeResultsCPD(fileName)

load(fileName);

best_canc = zeros(length(results.Out),1);
best_canc_test = zeros(length(results.Out),1);

for ii = 1:length(results.Out)
    best_canc(ii) = results.Out{ii}.best_canc;
    best_canc_test(ii) = results.Out{ii}.best_canc_test;
end

%% Cancellation as a function of the rank
F = results.opts.F(1:end);
for ii = 1:length(F)
    inds_F = find(results.comb_param(:,1)==F(ii));
    ind_F_max = find(best_canc(inds_F) == max(best_canc(inds_F)), 1, 'first');
    canc_F(ii) = best_canc_test(inds_F(ind_F_max));
end

%% Cancellation as a function of the discretization
I = results.opts.I;
for ii = 1:length(I)
    inds_I = find(results.comb_param(:,4)==I(ii));
    ind_I_max = find(best_canc(inds_I) == max(best_canc(inds_I)), 1, 'first');
    canc_I(ii) = best_canc_test(inds_I(ind_I_max));
end

%% Cancellation as a function of the discretization for all ranks
for ii = 1:length(I)
    inds_I = find(results.comb_param(:,4)==I(ii));
    combs_param_I = results.comb_param(inds_I,:);
    best_canc_I = best_canc(inds_I);
    best_canc_test_I = best_canc_test(inds_I);
    for jj = 1:length(F)
        ind_I_F = find(combs_param_I(:,1)==F(jj));
        combs_param_I_F = combs_param_I(ind_I_F,:);
        best_canc_I_F = best_canc_I(ind_I_F);
        best_canc_test_I_F = best_canc_test_I(ind_I_F);
        ind_I_F_max = find(best_canc_I_F == max(best_canc_I_F), 1, 'first');
        canc_I_F(ii,jj) = best_canc_test_I_F(ind_I_F_max);
    end
end
figure(1)
for jj = 1:length(F)
    plot(log2(I), canc_I_F(:,jj), 'o-')
    hold on
end
hold off
xlabel('Quantization (bits)')
ylabel('Cancellation (dB)')
for ii = 1:length(F)
    legendStr{ii} = sprintf('F = %d', F(ii));
end
legend(legendStr, 'Location', 'Best');
% Write to file
dlmwrite("results/"+fileName(1:end-4)+"_canc.dat", [ log2(I') canc_I_F ], ' ');

%% Complexities
L = results.opts.L;
for jj = 1:length(F)
    adds(jj) = F(jj)*(10*L-3) + 7*L - 4;
    mults(jj) = (6*F(jj)+1)*L - 3;        
end
for ii = 1:length(I)
    for jj = 1:length(F)
        mem(ii,jj) = 2*(F(jj)*2*L*I(ii) + L);
    end
end
figure(2)
subplot(1,2,1)
plot(adds, canc_F, 'o-')
hold on
plot(mults, canc_F, 'ro-')
legend('Additions', 'Multiplications', 'Location', 'Best')
xlabel('Operations')
ylabel('Cancellation (dB)')
subplot(1,2,2)
semilogx(mem, canc_I_F, 'o-')
xlabel('Memory')
ylabel('Cancellation (dB)')
for ii = 1:length(F)
    legendStr{ii} = sprintf('F = %d', F(ii));
end
legend(legendStr, 'Location', 'Best');
% Write to file
dlmwrite("results/"+fileName(1:end-4)+"_adds.dat", [ adds' canc_F' ], ' ');
dlmwrite("results/"+fileName(1:end-4)+"_mults.dat", [ mults' canc_F' ], ' ');
toWrite = [];
for ii = 1:size(mem,2)
    toWrite = [ toWrite mem(:,ii) canc_I_F(:,ii) ];
end
dlmwrite("results/"+fileName(1:end-4)+"_mem.dat", toWrite, ' ');
