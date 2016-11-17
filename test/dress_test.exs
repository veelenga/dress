defmodule DressTest do
  use ExUnit.Case, async: true

  doctest Dress

  @letters  %{ regex: ~r/[a-z]+/, color: :green }
  @numbers  %{ regex: ~r/[0-9]+/, color: :yellow }

  @subject Dress

  def format(sequence) do
    IO.ANSI.format(sequence) |> List.to_string
  end

  test "process/2 blank string" do
    assert @subject.process("", [@letters]) == ""
  end

  test "process/2 blank config" do
    assert @subject.process("Groot", []) == "Groot"
  end

  test "process/2 with sanitize" do
    assert @subject.process("hello, \e[4;35;1mworld\e[0m \e[0m!\e[0m", [@letters])
      == format [:green, "hello", :reset, ", ", :green, "world", :reset, " !"]
  end

  test "process/2 nil string" do
    assert_raise FunctionClauseError, fn -> @subject.process(nil, [@letters]) end
  end

  test "process/2 nil config" do
    assert_raise FunctionClauseError, fn -> @subject.process("superman", nil) end
  end

  test "sanitize/1 blank string" do
    assert @subject.sanitize("") == ""
  end

  test "sanitize/1 messy string" do
    assert @subject.sanitize("Hello, \e[4;35;1mWorld\e[0m \e[0m!\e[0m")
      == "Hello, World !"
  end

  test "sanitize/1 clean string" do
    assert @subject.sanitize("elixir \n rocks") == "elixir \n rocks"
  end

  test "decorate/2 empty string" do
    assert @subject.decorate("", [@letters]) == ""
  end

  test "decorate/2 blank config" do
    assert @subject.decorate("lorem ipsum", []) == "lorem ipsum"
  end

  test "decorate/2 colorizing string" do
    assert @subject.decorate("99 francs", [@letters, @numbers])
      == format [:yellow, "99", :reset, " ", :green, "francs", :reset]
  end

  test "decorate/2 when multiple colors" do
    assert @subject.decorate("10 900", [%{ regex: ~r/1/, colors: [:red, :bright] }])
      == format [:red, :bright, "1", :reset, "0 900"]
  end

  test "decorate/2 when regexes interact" do
    assert @subject.decorate("route 66", [@letters, %{ regex: ~r/o/, color: :white }])
      == format [:green, "r", :white, "o", :green, "ute", :reset, " 66"]
  end

  test "decorate/2 when disabled" do
    assert @subject.decorate("13 colonies", [ Map.put(@letters, :disabled, true) ])
      == "13 colonies"
  end

  test "decorate/2 when replace" do
    assert @subject.decorate(
      "username='scala'&password='s3cr3t'", [%{ regex: ~r/password='(.*)'/, replace: "password='[FILTERED]'" }]
    ) == "username='scala'&password='[FILTERED]'"
  end

  test "decorate/2 when replace with replacement pattern" do
    assert @subject.decorate("bob+alice", [%{regex: ~r/(bob)\+(alice)/, replace: "\\2+\\1"}])
      == "alice+bob"
  end

  test "decorate/2 when replace with color" do
    assert @subject.decorate("12 foot ninja", [%{regex: ~r/[0-9]+/, replace: "_"}, @numbers])
      == "_ foot ninja"
  end

  test "decorate/2 when color with replace" do
    assert @subject.decorate("12 foot ninja", [@numbers, %{regex: ~r/[0-9]+/, replace: "_"}])
      == format [:yellow, "_", :reset, " foot ninja"]
  end

  test "decorate/2 skips line" do
    assert @subject.decorate("13 crazy fists", [%{regex: ~r/[0-9]+/, skip: true}])
      == format [:clear_line]
  end

  test "decorate/2 does not skip line when does not match" do
    assert @subject.decorate("lostprophets", [%{regex: ~r/[0-9]+/, skip: true}])
      == "lostprophets"
  end
end
