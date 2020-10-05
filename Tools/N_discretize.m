function [inputs, I, partition] = N_discretize(inputs, d_int, N, f_type, d_type)

fprintf('K-means clustering \n')
I = zeros(1, N);
partition = cell(N, 1);
switch d_type
    case 'kmeans'
        for n=1:N
            ind_non_nan = ~isnan(inputs(:, n));
            if ~f_type(n)
                n_uniq = length(unique(inputs(ind_non_nan, n)));
                if n_uniq > d_int
                    [~, C] = kmeans(inputs(ind_non_nan, n), d_int, 'Replicates', 10, 'MaxIter', 1000);
                    [partition{n}, ~, ~] = lloyds(inputs(ind_non_nan, n), sort(C, 'ascend'));
                    inputs(ind_non_nan, n) = quantiz(inputs(ind_non_nan, n), partition{n}) + 1;
                else
                    inputs(ind_non_nan ,n) = knnsearch(sort(unique(inputs(ind_non_nan, n)), 'ascend'), inputs(ind_non_nan, n));
                end
            end
            I(n) = length(unique(inputs(ind_non_nan, n)));
        end
end
fprintf('K-means clustering done \n')
end