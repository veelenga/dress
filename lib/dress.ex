defmodule Dress do
  @moduledoc """
  Functionality to prepare decorated with ansi symbols strings (via `IO.ANSI`).
  Also it is possible to skip matched strings and replace data.
  """

  @ansi_escape_sequence_reg ~r/\e\[([;\d]+)?m/m

  @doc """
  Sanitizes a string and decorates with ansi escape characters based on
  passed configration.
  """
  @spec process(String.t, List.t) :: String.t
  def process(string, config) when is_binary(string) and is_list(config) do
    string |> sanitize |> decorate(config)
  end

  @doc """
  Removes ansi escape sequence chars from the string.

  ## Example

    iex> Dress.sanitize("Hello, \e[4;35;1mWorld\e[0m \e[0m!\e[0m")
    "Hello, World !"
  """
  @spec sanitize(String.t) :: String.t
  def sanitize(string) when is_binary(string) do
    Regex.replace(@ansi_escape_sequence_reg, string, "")
  end

  @doc """
  Adds ansi escape sequence chars to the string based on input config.

  ## Example

    iex> numbers = %{ regex: ~r/[0-9]+/, color: :yellow }
    iex> letters = %{ regex: ~r/[a-z]+/, color: :green }
    iex> Dress.decorate("99 francs", [letters, numbers])
    "\e[33m99\e[0m \e[32mfrancs\e[0m\e[0m"
  """
  @spec decorate(String.t, List.t) :: String.t
  def decorate(string, config) when is_binary(string) and is_list(config) do
    config
    |> Enum.reduce([string], fn entry, acc ->
        case entry do
          %{ disabled: true }               -> acc
          %{ regex: regex, skip: true }     -> acc |> skip(regex)
          %{ regex: _,     replace: _ }     -> acc |> replace(entry, [])
          %{ regex: regex, color: color }   -> acc |> colorize(regex, [color], [])
          %{ regex: regex, format: format } -> acc |> colorize(regex, format, [])
          %{ regex: regex, colors: colors } -> acc |> colorize(regex, colors, [])
          _                                 -> acc
        end
      end)
    |> IO.ANSI.format
    |> List.to_string
  end

  defmacro is_ansidata(seq) do
    quote do: is_atom(unquote(seq)) or is_list(unquote(seq))
  end

  defp skip([], _), do: []
  defp skip(seq, regex) when is_list(seq) do
    case Enum.any?(seq, fn(x) -> !is_ansidata(x) && Regex.match?(regex, x) end) do
      true -> [:clear_line]
      _    -> seq
    end
  end

  defp replace([], _, acc), do: Enum.reverse acc
  defp replace([h | t], entry, acc) when is_ansidata(h), do: replace t, entry, [h | acc]
  defp replace([h | t], entry = %{ regex: regex, replace: replace }, acc) do
    res = Regex.replace(regex, h, replace, entry[:opts] || [])
    replace t, entry, [res | acc]
  end

  defp colorize([], _, _, acc), do: Enum.reverse acc
  defp colorize([h | t], regex, colors, acc) when is_ansidata(h), do: colorize t, regex, colors, [h | acc]
  defp colorize([h | t], regex, colors, acc) do
    res = regex
    |> Regex.split(h, include_captures: true, trim: true)
    |> Enum.reduce(acc, fn el, acc ->
        if Regex.match?(regex, el) do
          [prev_color(acc), el, colors | acc]
        else
          [el | acc]
        end
      end)

    colorize t, regex, colors, res
  end

  defp prev_color(sequence, default \\ :reset) do
    Enum.find sequence, default, fn(x) -> is_ansidata(x) end
  end
end
