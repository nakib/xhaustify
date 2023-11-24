using Combinatorics
using TruthTables

# Function to use @truthtable with a string expression
truthtable = string_exp -> eval(Meta.parse("@truthtable "*string_exp))

function bottomless_powerset(collection)
    #Create a bottomless powerset from a collection of objects
    
    Set(
        map(Set, collection |> unique |> powerset |> collect)
        |> filter(s -> s != Set{String}()))
end

function entails(A, B)
    #Checks if an alternative is entailed by the prejacent.
    reduce(*, truthtable(A*" → "*B).columns |> last)
end

function unary_op(op, a)
    op*a
end

function binary_op(op, a, b)
    a*op*b
end

function reduce_binary_op(op, s)
    # {"b", "c", "a", ...} -> "(a*b*c*...)"
    
    col = s |> collect |> sort
    if size(col)[1] > 1
        return "("*col[1]*mapreduce(a -> op*a, *, col[2:end])*")"
    else
        return col[1]
    end
end

function excludable_alts(alts, base)
    #If an alternative is not entailed by the prejacent
    #it is excludable.
    
    filter(a -> !entails(reduce_binary_op("∨", base),
                         reduce_binary_op("∨", a)), alts)
end

function Only(base, Xalts; context = "")
    #O(base, excludable_alts_of_base) = base and
    #for every a which is an excludable alt, not a 
    
    base_str = context*reduce_binary_op("∨", base)
    Xalts_str = [reduce_binary_op("∨", x) for x in Xalts] |> sort
    base_str*reduce(*,
                    [binary_op("∧", "", unary_op("¬"*context, x)) for x in Xalts_str])

end
