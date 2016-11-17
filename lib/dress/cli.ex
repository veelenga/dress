defmodule Dress.Cli do
  @moduledoc """
  Incapsulates logic to run the application from command line.
  """

  def main(argv) do
    Application.put_env(:elixir, :ansi_enabled, true)

    { parsed, args, _ } =
      OptionParser.parse argv,
        switches: [config: :string], aliases: [c: :config]

    case { parsed, args } do
      { [config: config], _ } -> config |> start
      { [], [config] }        -> config |> find_config |> start
      _                       -> show_help
    end
  catch
    e -> handle_error e
  end

  defp start(path_to_config) do
    case Dress.Config.load path_to_config do
      { :ok, config }    -> handle_stream config
      { :error, reason } -> handle_error reason
    end
  end

  defp find_config(name) do
    case Dress.Config.find name do
      { :ok, found }     -> found
      { :error, reason } -> handle_error reason
    end
  end

  defp handle_stream(config) do
    IO.stream(:stdio, :line)
    |> Enum.each(fn line -> Dress.process(line, config) |> IO.write end)
  end

  defp handle_error(error, exit_code \\ 255) do
    case error do
      %{ message: message } -> IO.puts message
      e when is_binary(e)   -> IO.puts error
      _                     -> IO.inspect error
    end
    exit { :shutdown, exit_code }
  end

  defp show_help do
    [
      :red, "D", IO.ANSI.color(5, 2, 0), "R", :yellow, "E", :green, "S", IO.ANSI.color(0, 3, 5), "S",
      :reset, " up your std out!\n",
      """
      \t-h          Shows this help
      \t-c config   Path to config file
      \tconfig      Config filename in #{Dress.Config.default_dir} folder omitting extension

      Examples:
      \t$ tail -f log/development.log | dress rails
      \t$ netstat | dress -c config/networking.yml
      """
    ]
    |> IO.ANSI.format
    |> IO.write
  end
end
