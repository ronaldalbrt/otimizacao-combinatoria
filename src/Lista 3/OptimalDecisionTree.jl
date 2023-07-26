using JuMP, Gurobi

struct Node
    idx::Int64
    left::Union{Nothing, Int64}
    right::Union{Nothing, Int64}
end

struct BinaryTree
    max_depth::Int64
    nodes::Array{Node, 1}
end

function BinaryTree(max_depth::Int64)
    nodes = []
    for i = 1:(2^(max_depth + 1) - 1)
        if i <= (2^(max_depth + 1) - 1)÷2
            push!(nodes, Node(i, 2*i, 2*i + 1))
        else
            push!(nodes, Node(i, nothing, nothing))
        end
    end
    return BinaryTree(max_depth, nodes)
end

function dfs(node::Node, root::Node, bin_tree::BinaryTree)
    if node == root
        return [root]
    elseif isnothing(root.left) && isnothing(root.right)
        return nothing
    else 
        result_left = dfs(node, bin_tree.nodes[root.left], bin_tree)
        result_right = dfs(node, bin_tree.nodes[root.right], bin_tree)

        if !isnothing(result_right)
            path = push!(result_right, root)
            return path
        elseif !isnothing(result_left)
            path = push!(result_left, root)
            return path
        end
    end
end

function left_ancestors(node::Node, bin_tree::BinaryTree)
    root = bin_tree.nodes[1]
    path = dfs(node, root, bin_tree)

    left_ancestors = []
    for i in 2:length(path) - 1   

        if path[i + 1].left == path[i].idx
            push!(left_ancestors, path[i])
        end
    
    end

    return left_ancestors
end

function right_ancestors(node::Node, bin_tree::BinaryTree)
    root = bin_tree.nodes[1]
    path = dfs(node, root, bin_tree)

    right_ancestors = []
    for i in 2:length(path) - 1   

        if path[i + 1].right == path[i].idx
            push!(right_ancestors, path[i])
        end
    
    end

    return right_ancestors
end


n_features = 3
classes = [0, 1]
n = 8
X = [
    0 0 0;
    0 0 1;
    0 1 0;
    0 1 1;
    1 0 0;
    1 0 1;
    1 1 0;
    1 1 1;
]

y = [
    0;
    1;
    1;
    1;
    1;
    1;
    1;
    0;
]

max_depth = 1
N_min = 1

branch_nodes = (2^(max_depth + 1) - 1)÷2
leaf_nodes = (2^(max_depth + 1) - 1)÷2 + 1
bin_tree = BinaryTree(max_depth)

Y = [y[i] == class ? 1 : -1 for i = 1:n, class in classes]

model = Model(Gurobi.Optimizer)

@variable(model, a[1:n_features, 1:branch_nodes], Bin)
@variable(model, d[1:branch_nodes], Bin)
@variable(model, z[1:n, 1:leaf_nodes], Bin)
@variable(model, l[1:leaf_nodes], Bin)
@variable(model, c[1:length(classes), 1:leaf_nodes], Bin)
@variable(model, 0 <= L[1:leaf_nodes])

@constraint(model, [t = 1:branch_nodes], sum(a[:, t]) == d[t])

@constraint(model, [t = 2:branch_nodes], d[t] <= d[t ÷ 2])

@constraint(model, [i = 1:n, t = 1:leaf_nodes], z[i, t] <= l[t])
@constraint(model, [t = 1:leaf_nodes], sum(z[:, t]) >= N_min * l[t])
@constraint(model, [i = 1:n], sum(z[i, :]) == 1)

for t = 1:leaf_nodes
    l_ancestors = left_ancestors(bin_tree.nodes[t], bin_tree)
    r_ancestors = right_ancestors(bin_tree.nodes[t], bin_tree)

    for i = 1:n
        for l_ancestor in l_ancestors
            @constraint(model, sum(a[j, l_ancestor.idx]*X[i, j] for j = 1:n_features) == (1 - z[i, t]))
        end

        for r_ancestor in r_ancestors
            @constraint(model, sum(a[j, r_ancestor.idx]*X[i, j] for j = 1:n_features) == z[i, t])
        end
    end
end

@constraint(model, [t = 1:leaf_nodes], sum(c[:, t]) == l[t])

@constraint(model, [t = 1:leaf_nodes, class = 1:length(classes)], L[t] >= sum(z[:, t]) - ((1 .+ Y[:, class])'*z[:, t])/2 - n*(1 - c[class, t]))
@constraint(model, [t = 1:leaf_nodes, class = 1:length(classes)], L[t] <= sum(z[:, t]) - ((1 .+ Y[:, class])'*z[:, t])/2 + n*c[class, t])

@objective(model, Min, sum(L))

optimize!(model)

println(objective_value(model))

println(value.(z))
println(value.(a))