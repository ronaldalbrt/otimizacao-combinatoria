using JuMP, HiGHS
module LSP_model
    using JuMP, HiGHS

    # ------------------------------------------------
    # LSP = Lot Sizing Problem
    # ------------------------------------------------
    # Parameters:
    # n_periods = number of periods
    # d = demand
    # p = production cost
    # h = inventory cost
    # f = fixed cost
    # M = maximum production capacity
    # ------------------------------------------------
    struct LSP
        n_periods::Int64
        d::Array{Int64, 1}
        p::Array{Int64, 1}
        h::Array{Int64, 1}
        f::Array{Int64, 1}
        M::Int64
    end

    # ------------------------------------------------
    # Model: Build the JuMP model for the LSP instance
    # ------------------------------------------------
    # Parameters:
    # lsp_instance = LSP instance
    # ------------------------------------------------
    # Return: JuMP model
    # ------------------------------------------------
    function model(lsp_instance::LSP)
        n_periods = lsp_instance.n_periods

        d = lsp_instance.d
        p = lsp_instance.p
        h = lsp_instance.h
        f = lsp_instance.f
        M = lsp_instance.M

        model = Model(HiGHS.Optimizer)
        # Variáveis de decisão do modelo (y, s, x)
        @variable(model, 0 <= y[t = 1:n_periods])
        @variable(model, 0 <= s[t = 1:n_periods])
        @variable(model, x[t = 1:n_periods], Bin)

        # Restrições do modelo

        # Restrições de demanda
        # A quantidade produzida mais os produtos em estoque devem atender
        # a demanda do período
        for t in 1:n_periods
            if t == 1
                @constraint(model, y[t] == d[t] + s[t])
            else
                @constraint(model,s[t - 1] + y[t] == s[t] + d[t])
            end    
        end

        # Restrições de capacidade
        # A quantidade produzida não pode ultrapassar a capacidade de produção
        for t in 1:n_periods
            @constraint(model, y[t] <= x[t]*M)
        end

        # Função objetivo
        # Minimizar o custo de produção, estoque e fixo
        @objective(model, Min, sum(p .* y + h .* s + f .* x))

        return model
    end
end

# Número de periodos da instância 
n_periods = 6

# Demanda (d), custo de produção (p), custo de estoque (h) e custo fixo (f)
d = [6, 7, 4, 6, 3, 8]
p = [3, 4, 3, 4, 4, 5]
h = [1, 1, 1, 1, 1, 1]
f = [12, 15, 30, 23, 19, 45]

# Capacidade de produção
M = 10

# Construindo a instância do problema e otimizando o modelo gerado
lsp_instance = LSP_model.LSP(n_periods, d, p, h, f, M)
model = LSP_model.model(lsp_instance)
optimize!(model)

# Imprimindo os resultados otimizados
println("Objective value: ", objective_value(model))
x = value.(model[:x])
y = value.(model[:y])
s = value.(model[:s])

for t in 1:n_periods
    println("x[$t] = ", value(x[t]))
    println("y[$t] = ", value(y[t]))
    println("s[$t] = ", value(s[t]))
end

