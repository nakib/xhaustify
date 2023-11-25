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
base = Set(["a", "b", "c"])
#base = Set(["a", "b"])
DA = bottomless_powerset(base)
alts = DA
Xalts = excludable_alts(alts, base)

println("base: \n", base)
println("powerset: \n", DA)
println("excludable_alts: \n", Xalts)

##
O_da = parseformula(Only(base, Xalts, context = "□"))
#check_theory(worlds, edges, no_winner, O_da)
#check_theory(worlds, edges, one_loser, O_da)
#check_theory(worlds, edges, one_winner_var, O_da)
#check_theory(worlds, edges, one_winner_no_var, O_da)
#check_theory(worlds, edges, all_winners, O_da)

#O_da = parseformula(Only(base, Xalts, context = "◊"))

#@XXalts = excludable_alts_of_alt(Xalts)
#@show O_da = parseformula(Only_XDA(base, XXalts, context = "□"))

println("No winner:")
check_theory(worlds, edges, no_winner, O_da)
println("---")

println("One loser:")
check_theory(worlds, edges, one_loser, O_da)
println("---")

println("One winner with variation:")
check_theory(worlds, edges, one_winner_var, O_da)
println("---")

println("One winner with no variation:")
check_theory(worlds, edges, one_winner_no_var, O_da)
println("---")

println("All winners:")
check_theory(worlds, edges, all_winners, O_da)

#=

#Notation (not an exhaustive list...)
# \neg = ¬
# \wedge = ∧
# \vee = ∨
# \to = →
# \bot = ⊥
# \top = ⊤
# \lozenge = ◊ 
# \square = □
# ...


=#
