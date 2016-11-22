defmodule ConfigTest do
  use ExUnit.Case, async: true

  doctest Dress.Config

  @config_dir Path.expand "./test/fixtures/configs/"
  @valid      Path.join [@config_dir, "valid.yml"]
  @invalid    Path.join [@config_dir, "invalid_regex.yml"]

  @subject Dress.Config

  test "dir/0 returns path to dir" do
    assert File.dir?(@subject.dir)
  end

  test "load/1 loads config when it is valid" do
    {status, loaded} = @subject.load(@valid)
    assert status == :ok
    assert is_list loaded
  end

  test "load/1 does not load file when it does not exist" do
    { error, reason } = @subject.load Path.join [@config_dir, "no_such_file.yml"]
    assert error == :error
    assert reason |> String.contains?("no such file or directory")
  end

  test "load/1 does not load file when it is not valid" do
    { error, reason } = @subject.load @invalid
    assert error == :error
    assert reason == "Config can't be loaded: nothing to repeat at position 0"
  end

  test "find/1 finds config in directory by name" do
    assert @subject.find('valid', @config_dir) == { :ok, @valid }
  end

  test "find/1 finds config even with extensions" do
    assert @subject.find('valid.yml', @config_dir) == { :ok, @valid }
  end

  test "find/1 does not find config if it does not exist" do
    { error, reason } = @subject.find('no_such_file', @config_dir)
    assert error == :error
    assert reason |> String.contains?("Config can't be loaded")
  end
end
