module OtimCombinatoria

export DataModel, DataHelper, ExampleAlgorithm, Service, Forecast, Backtest, Resource, Client, EnergisaProjetoDeMercadoForecastingModels, Transformations, Stats, ComponentesVegetativas, MongoUtils

include("Lista 1/LSP.jl")
using .LSP_model

include("Lista 1/TSP.jl")
using .TSP_model


include("Lista 4/MatchingProblem.jl")
using .MatchingProblem_model


end # module
