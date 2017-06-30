PatternTap
==========

##### The pipe operator `|>` is an awesome feature of Elixir.

But when your result cannot be directly input into the next function, you have to stop, pattern match out the value you want and start piping again!

It is a common pattern to return data like `{:ok, result}` or `{:error, reason}`. When you want to handle both cases, something like [elixir-pipes](https://github.com/batate/elixir-pipes) may be a better use case for you. But otherwise, for simple destructuring of data and returning it in one line (or to just **let it fail**) you can `use PatternTap`!

#### Not fun way

```elixir
defmodule Foo do
  def get_stuff(input) do
    {:ok, intermediate_result} = input
      |> Enum.map(&(to_string(&1)))
      |> Foo.HardWorker.work
    {:ok, result} = intermediate_result
      |> Enum.map(&(Foo.IntermediateResult.handle(&1)))
    result
  end
end
```

Anytime where the object you want requires pattern matching but you want to either return on one line or continue piping, you can `use PatternTap`!

```elixir
def my_function do
  {:ok, result} = something |> something_else
  result
end
```

#### Pattern Tap

Heres the above example using `PatternTap`

```elixir
defmodule Foo do
  def get_stuff(input) do
    input
      |> Enum.map(&(to_string(&1)))
      |> Foo.HardWorker.work
      |> tap({:ok, r1} ~> r1) # tap({:ok, r1}, r1) is also a supported format
      |> Enum.map(&(Foo.IntermediateResult.handle(&1)))
      |> tap({:ok, r2} ~> r2) # tap({:ok, r2}, r2) is also a supported format
  end
end
```

And the second example

```elixir
# tap({:ok, result}, result) also supported
def my_function do
  something |> something_else |> tap({:ok, result} ~> result)
end
```

### Variable Leakage

**PatternTap** makes use of `case` in order to prevent leaking the variables you create. So after using `tap`, you won't have access to the patterns you create. This means if you bind more than one variable in your pattern, you won't have access to it.

Take the following example:

```elixir
my_data = {:data1, :data2} |> tap({d1, d2} ~> d1)
d2 # => ** (CompileError) ...: function d2/0 undefined
```

Instead you can use `destruct` to destructure the data you want. This does the same thing but with the side effect of keeping the binding you created in your patterns.

```elixir
{:data1, :data2} |> destruct({d1, d2} ~> d1) |> some_func(d2)
```

To simply save a partial result for later use, consider using `leak/2`:

```elixir
iex> [:data1, :data2] |> Enum.reverse |> leak(reversed) |> hd
:data2
iex> reversed
[:data2, :data1]
```

Note that `|> leak(variable_name)` is equivalent to `|> destruct(variable_name ~> variable_name)`.


### Unmatched results

#### Tap

Because `tap/3` uses `case` you will get a `CaseClauseError` with the data which did not match in the error report.

```elixir
{:error, "reason"} |> tap({:ok, result} ~> result)
# ** (CaseClauseError) no case clause matching: {:error, "reason"}
```


#### Destruct

Since `destruct/3` and `leak/2` use `=` you will instead get a `MatchError` with the data which did not match in the error report.

```elixir
{:error, "reason"} |> destruct({:ok, result} ~> result)
# ** (MatchError) no match of right hand side value: {:error, "reason"}
```

#### Leak

`leak(data, variable)` expands to `variable = data`, so in a simple use case,
leak can never fail, though it may override an existing variable:

```elixir
iex> old_var = 5
iex> [1, 2] |> leak(old_var) |> length
2
iex> old_var
[1, 2]
```

Because `leak(data, variable)` expands to `variable = data`, we can do all of our
favorite Elixir pattern-matching tricks here, e.g.:

```elixir
iex> %{a: 1, b: 2} |> leak(%{b: b})
%{a: 1, b: 2}
iex> b
2
```

This flexibility allows `leak` to fail just like `destruct`:

```elixir
iex> %{a: 1, b: 2} |> leak(%{c: c})
** (MatchError) no match of right hand side value: %{a: 1, b: 2}
```
