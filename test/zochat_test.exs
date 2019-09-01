defmodule ZochatTest do
  use ExUnit.Case
  doctest Zochat

  test "greets the world" do
    assert Zochat.hello() == :world
  end
end
