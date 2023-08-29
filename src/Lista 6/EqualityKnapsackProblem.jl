using JuMP, HiGHS

module EqualityKnapsackProblem_model
    using JuMP, HiGHS

    # ------------------------------------------------
    # Equality Knapsack Problem
    # ------------------------------------------------
    # Parameters:
    # n_itens: Number of itens
    # itens_weights: Weights of the itens
    # itens_values: Values of the itens
    # capacity: Capacity of the knapsack
    # ------------------------------------------------
    struct EqualityKnapsackProblem
        n_itens::Int64
        itens_weights::Array{Int64}
        itens_values::Array{Int64}
        capacity::Int64
    end

    # ------------------------------------------------
    # Equality Knapsack Problem formulated as a JuMP model
    # ------------------------------------------------
    # Parameters:
    # equality_knapsack: Equality Knapsack Problem
    # ------------------------------------------------
    # Return: JuMP model
    # ------------------------------------------------
    function model(equality_knapsack::EqualityKnapsackProblem)
        n = equality_knapsack.n_itens
        a = equality_knapsack.itens_weights
        b = equality_knapsack.capacity
        c = equality_knapsack.itens_values

        m = Model(HiGHS.Optimizer)
        @variable(m, 0 <= x[1:n], Int)

        @constraint(m, a'*x == b)
        @objective(m, Max, c'*x)

        return m
    end
end


n = 6
a = [12228, 36679, 36682, 48908, 61139, 73365]
b = 89716837

c = [1, 1, 1, 1, 1, 1] 

equality_knapsack = EqualityKnapsackProblem_model.EqualityKnapsackProblem(n, a, c, b)

m = EqualityKnapsackProblem_model.model(equality_knapsack)
optimize!(m)

x = value.(m[:x])
println("x = ", x)