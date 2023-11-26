using SoleLogics
using Graphs

include("../src/generate_exp.jl")

function check_theory(worlds, edges, scenario, implicature)
    fr = SoleLogics.ExplicitCrispUniModalFrame(worlds, Graphs.SimpleDiGraph(edges))
    @show K = KripkeStructure(fr, scenario)
    @show implicature
    @show check(implicature, K, worlds[1])
    println("==============================") 
end

worlds = SoleLogics.World.(1:4)

edges = Edge.([(1,2), (1,3), (1,4)])

a, b, c = Atom.(["a", "b", "c"])

no_winner = Dict([
    worlds[1] => TruthDict(["a" => true, "b" => true, "c" => true]),
    worlds[2] => TruthDict(["a" => true, "b" => false, "c" => false]),
    worlds[3] => TruthDict(["a" => false, "b" => true, "c" => false]),
    worlds[4] => TruthDict(["a" => false, "b" => false, "c" => true]),
])

one_loser = Dict([
    worlds[1] => TruthDict(["a" => true, "b" => true, "c" => true]),
    worlds[2] => TruthDict(["a" => false, "b" => true, "c" => false]),
    worlds[3] => TruthDict(["a" => false, "b" => false, "c" => true]),
    worlds[4] => TruthDict(["a" => false, "b" => true, "c" => true]),
])

one_winner_var = Dict([
    worlds[1] => TruthDict(["a" => true, "b" => true, "c" => true]),
    worlds[2] => TruthDict(["a" => true, "b" => true, "c" => false]),
    worlds[3] => TruthDict(["a" => true, "b" => false, "c" => true]),
    worlds[4] => TruthDict(["a" => true, "b" => true, "c" => true]),
])

one_winner_no_var = Dict([
    worlds[1] => TruthDict(["a" => true, "b" => true, "c" => true]),
    worlds[2] => TruthDict(["a" => true, "b" => false, "c" => false]),
    worlds[3] => TruthDict(["a" => true, "b" => false, "c" => false]),
    worlds[4] => TruthDict(["a" => true, "b" => false, "c" => false]),
])

all_winners = Dict([
    worlds[1] => TruthDict(["a" => true, "b" => true, "c" => true]),
    worlds[2] => TruthDict(["a" => true, "b" => true, "c" => true]),
    worlds[3] => TruthDict(["a" => true, "b" => true, "c" => true]),
    worlds[4] => TruthDict(["a" => true, "b" => true, "c" => true]),
])

##
context = "◊" #"□"
base = Set(["a", "b", "c"])
PS = bottomless_powerset(base)

#split PS into singleton (sg) vs non-singleton classes
sg = Set{Set{String}}()
nsg = Set{Set{String}}()
for elem in PS
    if(length(elem) == 1)
        push!(sg, elem)
    else
        push!(nsg, elem)
    end
end

trips = Set{Set{String}}()
for elem in PS
    if(length(elem) > 2)
        push!(trips, elem)
    end
end
#@show trips

#@show SA_sg
#@show nsg

#println("base: \n", base)
#println("domain alts: \n", nsg)

#Scalar
Xalts_SA = excludable_alts(nsg, base, "∧")
#Xalts_SA = excludable_alts(trips, base, "∧")
#println("SA excludable alts: \n", Xalts_SA)
SA_formula = Only(base, Xalts_SA, "∧", context = context)

#println("SA_formula:", SA_formula)

#Domain
#Xalts_DA = excludable_alts(nsg, base, "∨")
Xalts_DA = excludable_alts(sg, base, "∨")
#println("DA excludable alts: \n", Xalts_DA)
#Preexhaustification:
XXalts_DA = excludable_alts_of_alt(Xalts_DA, "∨")
#println("preexhaustified DA: \n", XXalts_DA)
DA_formula = Only_XDA(base, XXalts_DA, context = context)

#println("DA_formula:", DA_formula)

O_sada = parseformula(SA_formula * "∧ (" * DA_formula * ")")

println("No winner:")
check_theory(worlds, edges, no_winner, O_sada)
println("---")

println("One loser:")
check_theory(worlds, edges, one_loser, O_sada)
println("---")

println("One winner with variation:")
check_theory(worlds, edges, one_winner_var, O_sada)
println("---")

println("One winner with no variation:")
check_theory(worlds, edges, one_winner_no_var, O_sada)
println("---")

println("All winners:")
check_theory(worlds, edges, all_winners, O_sada)
