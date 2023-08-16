using JuMP, HiGHS

module MatchingProblem_model
    using JuMP, HiGHS

    # ------------------------------------------------
    # Matching Problem
    # ------------------------------------------------
    # Parameters:
    # n_nodes: Number of nodes
    # edge_list = List of Edges in the graph
    # ------------------------------------------------
    struct MatchingProblem
        n_nodes::Int64
        edge_list::Array{Tuple{Int64,Int64}}
    end

    # ------------------------------------------------
    # Matching Problem formulated as a JuMP model
    # ------------------------------------------------
    # Parameters:
    # matching: Matching Problem
    # ------------------------------------------------
    # Return: JuMP model
    # ------------------------------------------------
    function model(matching::MatchingProblem)
        n_nodes = matching.n_nodes
        edge_list = matching.edge_list

        m = Model(HiGHS.Optimizer)

        # Variables
        @variable(m, x[e in edge_list], Bin)

        # Constraints
        for v in 1:n_nodes
            @constraint(m, sum(x[e] for e in edge_list if (e[1] == v || e[2] == v)) <= 1)
        end

        # Objective
        @objective(m, Max, sum(x[e] for e in edge_list))

        return m
    end
end

# Number of nodes
n = 20  

# Edge List
edge_list = [
    (11, 3), (11, 7), (11, 8), (11, 10), 
    (12, 4), (12, 8), 
    (13, 2), (13, 5), (13, 7),
    (14, 1), (14, 2), (14, 7), (14, 9),
    (15, 2), (15, 5), (15, 7),
    (16, 1), (16, 4), (16, 5), (16, 7),
    (17, 2), (17, 7),
    (18, 1), (18, 6), (18, 7), (18, 10),
    (19, 2), (19, 5),
    (20, 1), (20, 2), (20, 3), (20, 6), (20, 7), (20, 8), (20, 10)]

# Matching Problem
matching = MatchingProblem_model.MatchingProblem(n, edge_list)

# Model
model = MatchingProblem_model.model(matching)
optimize!(model)

# Print solution
println("Objective value: ", objective_value(model))
