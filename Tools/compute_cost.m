function er = compute_cost(mse, N, X, T, mu, mu_sm)
    er = 0;
    for n = 1:N
        er = er + mu*norm(X.U{n}(:))^2;
        er = er + mu_sm*norm(T{n}*X.U{n},'fro')^2;
    end
    er = er +  mse;
end