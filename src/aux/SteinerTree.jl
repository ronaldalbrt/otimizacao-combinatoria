using JuMP, Gurobi, TSPLIB, Combinatorics

# Definição das instâncias de teste
n_nodes = 6
adj_matrix = [
    0 7 0 0 0 6;
    7 0 1 0 0 5;
    0 1 0 1 3 0;
    0 0 1 0 1 0;
    0 0 3 1 0 10;
    6 5 0 0 10 0;
]
edge_list = [
    (1, 2), (1, 6), (2, 3), (2, 6), (3, 4), (3, 5), (4, 5), (5, 6)
]
costs = [
    7, 6, 1, 5, 1, 3, 1, 10
]
terminal_nodes = [1, 3, 5, 6]

model = Model(Gurobi.Optimizer)

# Variáveis de decisão do modelo (x)
@variable(model, x[i in edge_list], Bin)

# Presença dos nós terminais
for t in terminal_nodes
    @constraint(model, sum(x[i] for i in edge_list if t in i) >= 1)
end

# Restrição de eliminação de subciclos 
for S in collect(powerset(1:n_nodes))
    if length(S) > 1 && length(S) <= n_nodes
        @constraint(model, sum(x[i] for i in edge_list if i[1] in S && i[2] in S) <= length(S) - 1)
    end
end

@objective(model, Min, costs' * x)

optimize!(model)
