defmodule Dress.Config do

  @dir "~/.dress/"
  @ext ".yml"

  def default_dir do
    Path.expand @dir
  end

  def load(path) do
    loaded = YamlElixir.read_from_file(path, atoms: true)
    |> Map.get("dress")
    |> Enum.reduce([], fn {_, entry}, acc ->
        [ load_config_entry(entry) | acc ]
      end)

    {:ok, loaded}
  catch
    x -> { :error,
      case x do
        { :yamerl_exception, [errors] } -> elem(errors, 2)
        _ -> "Failed to load config '#{path}'"
      end
    }
  end

  def find(name, dir \\ default_dir) do
    name = Path.basename(name, @ext)

    case ls = File.ls dir do
      { :ok, files } ->
        case search_file(name, files) do
          found when is_binary(found) -> { :ok, Path.join [dir, found] }
          _ -> { :error, "Config file '#{name}.yml' not found in '#{dir}'"}
        end
      { :error, _ } -> ls
    end
  end

  defp load_config_entry(entry) when is_map(entry) do
    for { key, val } <- entry, into: %{} do
      key = String.to_atom(key)
      case key do
        :regex -> { key, val |> Regex.compile |> elem(1) }
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
