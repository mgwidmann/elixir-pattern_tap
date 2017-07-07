defmodule PatternTap do
  @moduledoc """
  The pipe operator `|>` is an awesome feature of Elixir. Keep using it.

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
    use PatternTap

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
  """

  defmacro __using__(_) do
    quote do
      import PatternTap
    end
  end

  @doc """
  Use within pipes to pull out data inside and continue piping.

  Example:

      iex> use PatternTap
      iex> [1,2,3,4] |> tap([_a, _b | c] ~> c) |> inspect()
      "[3, 4]"
  """
  defmacro tap(data, pattern, return_var) do
    quote do
      case unquote(data) do
        unquote(pattern) -> unquote(return_var)
      end
    end
  end

  @doc false
  defmacro tap(data, {:~>, _, [pattern, var]}) do
    quote do
      tap(unquote(data), unquote(pattern), unquote(var))
    end
  end

  @doc """
  `tap/3` will not leak variable scope, and so any variables created within it are sure
  not to accidentally harm outside bindings by replacing them with values you didn't intend to.

  For that reason, it can only return one value, which means other variables in the binding will
  go unused (and warn you about it). `destruct/3` will act as `tap/3` however leak the variable
  scope outside, allowing you to return one value and then use another.

  Example: (doc test does not like this for some reason, but it works I promise...)

  ```
  use PatternTap
  [1,2,3,4] |> destruct([a, b | c] ~> c) |> Enum.concat([a, b])
  [3,4,1,2]
  ```
  """
  defmacro destruct(data, pattern, return_var) do
    quote do
      unquote(pattern) = unquote(data)
      unquote(return_var)
    end
  end

  @doc false
  defmacro destruct(data, {:~>, _, [pattern, var]}) do
    quote do
      destruct(unquote(data), unquote(pattern), unquote(var))
    end
  end

  @doc """
  Leaks a pipelined value into the surrounding context as a new variable.

  ## Examples:

      iex> "hey" |> String.upcase |> leak(uppercase) |> String.to_atom
      :HEY
      iex> uppercase
      "HEY"
      iex> {:ok, "the result"} |> leak({:ok, result})
      {:ok, "the result"}
      iex> result
      "the result"
  """
  defmacro leak(data, var) do
    quote do
      unquote(var) = unquote(data)
    end
  end
end
