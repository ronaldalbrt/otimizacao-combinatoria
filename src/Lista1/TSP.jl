using JuMP, HiGHS

module TSP_model
    using JuMP, HiGHS

    # ------------------------------------------------
    # TSP = Traveling Salesman Problem
    # ------------------------------------------------
    # Parameters:
    # n_nodes = number of nodes
    # adj_matrix = adjacency matrix
    # precedence_restrictions = precedence restrictions
    # ------------------------------------------------
    struct TSP 
        n_nodes::Int64
        adj_matrix::Array{Int64, 2}
        precende_restrictions::Union{Nothing, Array{Tuple{Int64, Int64}}}
    end
    
    # ------------------------------------------------
    # TSP = Traveling Salesman Problem
    # ------------------------------------------------
    # Parameters:
    # n_nodes = number of nodes
    # adj_matrix = adjacency matrix
    # ------------------------------------------------
    # Return: TSP instance
    # ------------------------------------------------
    # O construtor abaixo é utilizado para o caso em que não há 
    # restrições de precedência precedence_restrictions = nothing
    function TSP(n_nodes::Int64, adj_matrix::Array{Int64, 2})
        return TSP(n_nodes, adj_matrix, nothing)
    end

    # ------------------------------------------------
    # Model: Build the JuMP model for the TSP instance
    # ------------------------------------------------
    # Parameters:
    # tsp_instance = TSP instance
    # ------------------------------------------------
    # Return: JuMP model
    # ------------------------------------------------
    function model(tsp_instance::TSP)
        n_nodes = tsp_instance.n_nodes
        adj_matrix = tsp_instance.adj_matrix
        precedence_restrictions = tsp_instance.precende_restrictions

        model = Model(HiGHS.Optimizer)
        # Variáveis de decisão do modelo (x, mtzu)
        @variable(model, x[i = 1:n_nodes, j = 1:n_nodes], Bin)
        @variable(model, 1 <= mtzu[i = 2:n_nodes] <= n_nodes - 1)

        # Restrições do modelo
        @constraint(model, [i = 1:n_nodes], x[i, i] == 0)
        @constraint(model, [i = 1:n_nodes], sum(x[i, :]) == 1)
        @constraint(model, [j = 1:n_nodes], sum(x[:, j]) == 1)

        # Restrições de subciclo pela formulação de Miller-Tucker-Zemlin
        @constraint(model, [ui = 2:n_nodes, uj = 2:n_nodes], mtzu[ui] - mtzu[uj] + n_nodes*x[ui, uj] + (n_nodes - 2)*x[uj, ui] <= n_nodes - 1)

        # Restrições de precedência
        if !isnothing(precedence_restrictions)
            for (uk, ul) in precedence_restrictions
                @constraint(model, mtzu[ul] >= mtzu[uk] + 1)
            end
        end

        # Função objetivo
        @objective(model, Min, sum(adj_matrix .* x))

        return model
    end

end

n_nodes = 8

adj_matrix = [
    0   1   1   999 999   999 999   999;
    1   0   1   2   999   5   999   999;
    1   1   0   2   999   999 4     999;
    999 2   2   0   1     999 999   999;
    999 999 999 1   0     2   2     999;
    999 5   999 999 2     0   1     1;
    999 999 4   999 2     1   0     1;
    999 999 999 999 999   1   1     0;
]

precedence_restrictions = [
    (2, 4)
]

TSP_instance = TSP_model.TSP(n_nodes, adj_matrix, precedence_restrictions)

model = TSP_model.model(TSP_instance)

optimize!(model)

println("Objective value: ", objective_value(model))

println("Optimal solution:")
solution = value.(model[:x])
solution_u = value.(model[:mtzu])
for i in 1:n_nodes
    for j in 1:n_nodes
        print(solution[i, j], " ")
    end
    println()
end

for i in 2:n_nodes
    println("u", i, " = ", solution_u[i])
end