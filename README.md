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
      |> tap(:r1, {:ok, r1})
      |> Enum.map(&(Foo.IntermediateResult.handle(&1)))
      |> tap(:r2, {:ok, r2})
  end
end
```

And the second example

```elixir
def my_function do
  something |> something_else |> tap({:ok, result}, result)
end
```

### Variable Leakage

**PatternTap** makes use of `case` in order to prevent leaking the variables you create. So after using `tap`, you won't have access to the patterns you create. This means if you bind more than one variable in your pattern, you won't have access to it.

Take the following example:

```elixir
my_data = {:data1, :data2} |> tap({d1, d2}, d1)
d2 # => ** (CompileError) ...: function d2/0 undefined
```

Instead you can use `destruct` to destructure the data you want. This does the same thing but with the side effect of keeping the binding you created in your patterns.

```elixir
{:data1, :data2} |> destruct({d1, d2}, d1) |> some_func(d2)
```

### Unmatched results

#### Tap

Because `tap/3` uses `case` you will get a `CaseClauseError` with the data which did not match in the error report.

```elixir
{:error, "reason"} |> tap({:ok, result}, result)
# ** (CaseClauseError) no case clause matching: {:error, "reason"}
```


#### Destruct

Since `destruct/3` uses `=` you will instead get a `MatchError` with the data which did not match in the error report.

```elixir
{:error, "reason"} |> destruct({:ok, result}, result)
# ** (MatchError) no match of right hand side value: {:error, "reason"}
```
