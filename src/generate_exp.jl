using Combinatorics
using TruthTables

# Function to use @truthtable with a string expression.
function truthtable(exp::String)
    eval(Meta.parse("@truthtable "*exp))
end

function bottomless_powerset(collection::Set{String})
    # Create a bottomless powerset from a collection of objects.
    
    Set(
        map(Set, collection |> unique |> powerset |> collect)
        |> filter(s -> s != Set{String}()))
end

function entails(A::String, B::String)::Bool
    # Checks if an alternative is entailed by the prejacent.
    
    reduce(*, truthtable(A*" → "*B).columns |> last)
end

function unary_op(op::String, a::String)
    # Apply a unary operation.
    
    op*a
end

function binary_op(op::String, a::String, b::String)
    # Apply a binary operation.
    
    a*op*b
end

function reduce_binary_op(op::String, s::Set{String})
    # Reduce with respect to a binary operation.
    # {"b", "c", "a", ...} -> "(a*b*c*...)"
    
    col = s |> collect |> sort
    if size(col)[1] == 1
        return col[1]
    end
    return "("*col[1]*mapreduce(a -> op*a, *, col[2:end])*")"
end

function excludable_alts(alts::Set{Set{String}}, base::Set{String})
    # Generate the excludable alternatives.
    # If an alternative is not entailed by the prejacent,
    # it is excludable.
    
    filter(a -> !entails(reduce_binary_op("∨", base),
                         reduce_binary_op("∨", a)), alts)
end

function excludable_alts_of_alt(Xalts::Set{Set{String}})
    # Define the set of alts to be excluded during the preexhaustification
    # of a domain alternative.
    
    XXalts = Dict()
    for x in Xalts
        gather = Set{Set{String}}()
        for y in Xalts
            if(length(x) == length(y) && x != y)
                push!(gather, y)
            end
        end
        XXalts[x] = excludable_alts(gather, x)
    end
    return XXalts
end

function Only_XDA(base::Set{String}, XXalts; context = "")
    # Create the syntax for Only interpreted relative to the XDA.
    
    base_str = context*reduce_binary_op("∨", base)
    
    exp_str = []
    for key in keys(XXalts)
        push!(exp_str, "("*Only(key, XXalts[key], context = context)*")")
    end

    base_str*reduce(*,
                    [binary_op("∧", "", unary_op("¬", x)) for x in sort(exp_str)])
end

function Only(base::Set{String}, Xalts::Set{Set{String}}; context = "")
    # Apply the Only operation.
    # O(base, excludable_alts_of_base) = base and
    # for every a which is an excludable alt, not a 
    
    base_str = context*reduce_binary_op("∨", base)
    Xalts_str = [reduce_binary_op("∨", x) for x in Xalts] |> sort
    base_str*reduce(*,
                    [binary_op("∧", "", unary_op("¬"*context, x)) for x in Xalts_str])

end
