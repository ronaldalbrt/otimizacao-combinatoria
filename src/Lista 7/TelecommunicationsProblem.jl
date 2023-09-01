using JuMP, HiGHS

module TelecommunicationsProblem_model
    using JuMP, HiGHS

    # ------------------------------------------------
    # Telecommunications Problem
    # ------------------------------------------------
    # Parameters:
    # edges: List of edges
    # demands: List of demands
    # ------------------------------------------------
    struct TelecommunicationsProblem
        edges::Array{Tuple{Int64, Int64}}
        demands::Array{Int64}
    end


    # ------------------------------------------------
    # Telecommunications Problem formulated as a JuMP model
    # ------------------------------------------------
    # Parameters:
    # telecommunications: Telecommunications Problem
    # ------------------------------------------------
    # Return: JuMP model
    # ------------------------------------------------
    function model(telecommunications::TelecommunicationsProblem)
        edges = telecommunications.edges
        demands = telecommunications.demands

        n_edges = length(edges)

        m = Model(HiGHS.Optimizer)
        @variable(m, 0 <= x[1:n_edges], Int)
        @variable(m, 0 <= y[1:n_edges], Int)

        for edge in 1:length(edges)
            @constraint(m, x[edge] + 24*y[edge] == demands[edge])
        end

        @objective(m, Min, sum(x) + sum(10 .* y))
        return m
    end
end


edges = [
    (2, 1),
    (3, 1),
    (3, 2),
    (4, 2),
    (5, 3),
    (4, 5)
]

demands = [
    12,
    51,
    53,
    51,
    32,
    91
]

telecommunications = TelecommunicationsProblem_model.TelecommunicationsProblem(edges, demands)
m = TelecommunicationsProblem_model.model(telecommunications)
optimize!(m)


obj_value = objective_value(m)
println("obj_value = ", obj_value)

x = value.(m[:x])
y = value.(m[:y])
println("x = ", x)
println("y = ", y)

