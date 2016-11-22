defmodule Dress.Config do

  @dir Path.expand "~/.dress/"
  @ext ".yml"

  def dir, do: @dir

  def load(path) do
    loaded = YamlElixir.read_from_file(path, atoms: true)
    |> Map.get("dress")
    |> Enum.reduce([], fn {_, entry}, acc ->
        [ load_config_entry(entry) | acc ]
      end)

    {:ok, loaded}
  rescue x -> handle_error x
  catch  x -> handle_error x
  end

  def find(name, dir \\ @dir) do
    name = Path.basename name, @ext

    case ls = File.ls dir do
      { :ok, files } ->
        case search_file(name, files) do
          f when is_binary(f) -> { :ok, Path.join [dir, f] }
          _ -> handle_error "'#{name}.yml' not found in '#{dir}'"
        end
      { :error, _ } -> ls
    end
  end

  defp handle_error(x) do
    reason = case x do
      x when is_binary(x)             -> "Config can't be loaded: #{x}"
      %{ message: message }           -> "Config can't be loaded: #{message}"
      { :yamerl_exception, [errors] } -> errors |> elem(2) |> List.to_string
      _                               -> "Unable to load this config"
    end

    { :error, reason }
  end

  defp load_config_entry(entry) when is_map(entry) do
    for { key, val } <- entry, into: %{} do
      key = String.to_atom(key)
      case key do
        :regex -> { key, Regex.compile!(val) }
        _      -> { key, val }
      end
    end
  end

  defp search_file(name, files) do
    Enum.find files, fn f ->
      Path.extname(f) == @ext && name == Path.basename(f, @ext)
    end
  end
end
