PatternTap
==========

##### The pipe operator `|>` is an awesome feature of Elixir.

But when your result cannot be directly input into the next function, you have to stop, pattern match out the value you want and start piping again!

It is a common pattern to return data like `{:ok, result}` or `{:error, reason}`. When you want to handle both cases, theres not much you can do except use another function or a `case`. But otherwise you can `use PatternTap`!

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
{:ok, result} = something |> something_else
result
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
something |> something_else |> tap(:result, {:ok, result})
```

### Usage

The `tap/3` macro takes `data, return_variable, pattern` for its three parameters. This takes advantage of Elixir's `binding` call. The variables you create in your pattern will be available even after the tap call. Take this use case for example.

```elixir
[:a] |> tap(:a, [a])  # => Returns :a
IO.puts "#{a}"        # The variable a is available
```

The symbol `:a` passed into `tap` is what variable to return. All other variables will be available after the `tap` call, though `tap` will only return a single variable. This means `tap({:ok, 1}, :r, {e, r})` will return `r` (which has the value 1) but in the next statement, the variable `e` will be available (which has the value `:ok`).
