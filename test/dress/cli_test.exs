defmodule CliTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  doctest Dress.Cli

  @subject Dress.Cli
  @path_to_config "./config/default.yml"

  test "main/1 prints help when no args" do
    assert capture_io(fn -> @subject.main([]) end) =~ "Shows this help"
  end

  test "main/1 prings help when -h switch" do
    assert capture_io(fn -> @subject.main(["-h"]) end) =~ "Shows this help"
  end

  test "main/1 prints help when other switches" do
    assert capture_io(fn -> @subject.main(["-h"]) end) =~ "Shows this help"
  end

  test "main/1 runs app when config passed" do
    refute capture_io(fn -> @subject.main(["-c", @path_to_config]) end)
      =~ "Shows this help"
  end

  test "main/1 exits with 255 when wrong config passed" do
    assert catch_exit(capture_io fn -> @subject.main ["-c", "no_such_file.yml"] end)
      == {:shutdown, 255}
  end

  test "main/1 exits with 255 when wrong config name passed" do
    assert catch_exit(capture_io fn -> @subject.main ["no_such_config"] end)
      == {:shutdown, 255}
  end
end
