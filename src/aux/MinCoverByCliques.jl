using JuMP, HiGHS, Combinatorics


edge_list = [
    [1, 2], [2, 3], [3 , 4], [1, 4], [4, 12], [3, 15], [15, 12],
    [4, 14], [14, 13], [13, 10], [13, 11], [11, 10],
    [11, 7], [13, 7], [10, 8], [10, 9],
    [8, 5], [9, 6], [5, 6], [6, 7], [5, 2], [12, 6]
]

n_nodes = 15

model = Model(HiGHS.Optimizer)

@variable(model, w[i = 1:n_nodes], Bin)
@variable(model, x[i = 1:n_nodes, j = 1:n_nodes], Bin)

@constraint(model, [v = 1:n_nodes], sum(x[v, :]) == 1)

for comb in combinations(1:n_nodes, 2)
    if comb ∉ edge_list && reverse(comb) ∉ edge_list
        @constraint(model, [i = 1:n_nodes], w[i] >= x[comb[1], i] + x[comb[2], i])
    end
end

@objective(model, Min, sum(w))

optimize!(model)

println("Objective value: ", objective_value(model))

for i = 1:n_nodes
    for j = 1:n_nodes
        print(value(x[i,j]), " ")
    end
    println()
end