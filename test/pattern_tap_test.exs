defmodule PatternTapTest do
  use ExUnit.Case
  use PatternTap

  test "can do simple pattern matching" do
    assert tap(:ok, nil, :ok) == nil
  end

  test "can do list pattern matching" do
    assert tap([:a], :a, [a]) == :a
    assert a == :a
  end

  test "can do tuple pattern matching" do
    assert tap({:b}, :b, {b}) == :b
    assert b == :b
  end

  @data [:a, :b, :c]
  test "can match with the |> operator" do
    assert @data |> Enum.map(&(to_string(&1))) |> tap(:b, [_, b, _]) == "b"
  end

  @data [key: :val, key2: :val2]
  test "can match |> with keyword lists" do
    assert @data |> tap(:v, [_, {:key2, v}]) == :val2
  end

  test "can match typical {:ok, result}" do
    assert {:ok, 1} |> tap(:result, {:ok, result}) == 1
  end
  
end
