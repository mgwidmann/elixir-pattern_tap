defmodule PatternTapTest do
  use ExUnit.Case
  use PatternTap
  doctest PatternTap
  test "can do simple pattern matching" do
    assert tap(:ok, :ok, nil) == nil
    assert tap(:ok, :ok ~> nil) == nil
    assert destruct(:ok, :ok, nil) == nil
    assert destruct(:ok, :ok ~> nil) == nil
  end

  test "can do list pattern matching" do
    assert tap([:a], [a], a) == :a
    assert tap([:a], [a] ~> a) == :a
    assert destruct([:a], [a], a) == :a
    assert destruct([:a], [a] ~> a) == :a
  end

  test "variables are not available after" do
    tap([:foo], [f], f)
    assert binding[:f] == nil
    tap([:foo], [f] ~> f)
    assert binding[:f] == nil
  end

  test "can do tuple pattern matching" do
    assert tap({:b}, {b}, b) == :b
    assert tap({:b}, {b} ~> b) == :b
    assert destruct({:b}, {b}, b) == :b
    assert destruct({:b}, {b} ~> b) == :b
  end

  @data [:a, :b, :c]
  test "can match with the |> operator" do
    assert @data |> Enum.map(&(to_string(&1))) |> tap([_, b, _], b) == "b"
    assert @data |> Enum.map(&(to_string(&1))) |> tap([_, b, _] ~> b) == "b"
    assert @data |> Enum.map(&(to_string(&1))) |> destruct([_, b, _], b) == "b"
    assert @data |> Enum.map(&(to_string(&1))) |> destruct([_, b, _] ~> b) == "b"
  end

  @data [key: :val, key2: :val2]
  test "can match |> with keyword lists" do
    assert @data |> tap([_, {:key2, v}], v) == :val2
    assert @data |> tap([_, {:key2, v}] ~> v) == :val2
    assert @data |> destruct([_, {:key2, v}], v) == :val2
    assert @data |> destruct([_, {:key2, v}] ~> v) == :val2
  end

  test "can match typical {:ok, result}" do
    assert {:ok, 1} |> tap({:ok, result}, result) == 1
    assert {:ok, 1} |> tap({:ok, result} ~> result) == 1
    assert {:ok, 1} |> destruct({:ok, result}, result) == 1
    assert {:ok, 1} |> destruct({:ok, result} ~> result) == 1
  end

  test "failure matches result in the correct error message" do
    assert_raise CaseClauseError, "no case clause matching: {:error, \"reason\"}", fn ->
      {:error, "reason"} |> tap({:ok, result}, result)
    end
    assert_raise CaseClauseError, "no case clause matching: {:error, \"reason\"}", fn ->
      {:error, "reason"} |> tap({:ok, result} ~> result)
    end
    assert_raise MatchError, "no match of right hand side value: {:error, \"reason\"}", fn ->
      {:error, "reason"} |> destruct({:ok, result}, result)
    end
    assert_raise MatchError, "no match of right hand side value: {:error, \"reason\"}", fn ->
      {:error, "reason"} |> destruct({:ok, result} ~> result)
    end
  end

  test "destruct keeps variables around" do
    destruct({:a, :b}, {a, b}, a)
    destruct({:a, :b}, {a, b} ~> a)
    assert a == :a
    assert b == :b
  end

  describe "leak" do
    test "creates a new variable" do
      [1, 2] |> Enum.reverse |> leak(backwards)
      assert backwards == [2, 1]
    end

    test "supports internal pattern matches" do
      [1, 2] |> Enum.reverse |> leak([h|t])
      assert h == 2
      assert t == [1]
    end
  end
end
