defmodule PatternTap do

  defmacro __using__(_) do
    quote do
      import PatternTap
    end
  end

  defmacro tap(data, pattern, var) do
    quote do
      case unquote(data) do
        unquote(pattern) -> unquote(var)
      end
    end
  end

  defmacro tap(data, {:~>, _, [pattern, var]}) do
    quote do
      tap(unquote(data), unquote(pattern), unquote(var))
    end
  end

  defmacro destruct(data, pattern, var) do
    quote do
      unquote(pattern) = unquote(data)
      unquote(var)
    end
  end

  defmacro destruct(data, {:~>, _, [pattern, var]}) do
    quote do
      destruct(unquote(data), unquote(pattern), unquote(var))
    end
  end

  @doc """
  leaks a pipelined value into the surrounding context as a new variable.

  ## Examples:

    iex> "hey" |> String.upcase |> leak(uppercase) |> String.to_atom 
    :HEY
    ...> uppercase
    "HEY"
  """
  defmacro leak(data, var) do
    quote do
      unquote(var) = unquote(data)
    end
  end
end
