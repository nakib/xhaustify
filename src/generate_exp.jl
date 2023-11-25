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
    if size(col)[1] > 1
        return "("*col[1]*mapreduce(a -> op*a, *, col[2:end])*")"
    else
        return col[1]
    end
end

function excludable_alts(alts::Set{Set{String}}, base::Set{String})
    # Generate the excludable alternatives.
    # If an alternative is not entailed by the prejacent,
    # it is excludable.
    
    filter(a -> !entails(reduce_binary_op("∨", base),
                         reduce_binary_op("∨", a)), alts)
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
