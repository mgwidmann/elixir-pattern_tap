defmodule PatternTap do

  defmacro __using__(_) do
    quote do
      import PatternTap
    end
  end

  defmacro tap(data, var, pattern) do
    quote do
      unquote(pattern) = unquote(data)
      binding[unquote(var)]
    end
  end

end
