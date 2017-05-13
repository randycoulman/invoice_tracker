defmodule ConfigTest do
  @moduledoc false

  use ExUnit.Case
  alias InvoiceTracker.Config

  describe "with an empty file" do
    test "returns an empty map" do
      {:ok, io} = StringIO.open("")
      assert Config.read(io) == %{}
    end
  end

  describe "with single value" do
    test "returns a map with the value" do
      {:ok, io} = StringIO.open("key=value")
      assert Config.read(io) == %{key: "value"}
    end

    test "trims keys and values" do
      {:ok, io} = StringIO.open("  \t  key   =\t   \t  value    \t ")
      assert Config.read(io) == %{key: "value"}
    end

    test "allows values containing equals signs" do
      {:ok, io} = StringIO.open("key= value = foo = bar")
      assert Config.read(io) == %{key: "value = foo = bar"}
    end
  end

  describe "with multiple values" do
    test "returns a map with all keys and values" do
      {:ok, io} = StringIO.open("key1 = value1\nkey2 = value2")
      assert Config.read(io) == %{key1: "value1", key2: "value2"}
    end

    test "ignores blank lines" do
      {:ok, io} = StringIO.open("\n\nkey1 = value1\n\nkey2 = value2\n\n")
      assert Config.read(io) == %{key1: "value1", key2: "value2"}
    end
  end
end
