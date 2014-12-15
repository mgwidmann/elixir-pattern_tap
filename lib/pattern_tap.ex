defmodule PatternTap do

  defmacro __using__(_) do
    quote do
      import PatternTap
    end
  end

  defmacro tap(data, pattern, var) do
    quote do
      unquote(pattern) = unquote(data)
      unquote(var)
    end
  end

end
