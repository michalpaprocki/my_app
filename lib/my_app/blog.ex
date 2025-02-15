defmodule MyApp.Blog do
  @doc """
  Reads markdown files and returns their titles and paths as a list of tuples.
  """
  def get_articles_titles_and_paths() do
    case get_articles_files() do
      :empty ->
        {:error, "No files found"}

      {:ok, files} ->
        Enum.map(files, fn f -> {get_articles_title(f), f} end)
    end
  end
  @doc """
  Reads markdown files from `content/md` directory and returns their paths.
  """
  def get_articles_files() do
    files = Path.wildcard("content/md/**/*.md")
    if length(files) == 0 do
      :empty
    else
      {:ok, files}
    end
  end

  @doc """
    Takes in a markdown file path, reads it's contents and extracts title.
  """
  def get_articles_title(path) do
    case read_md(path) do
      {:error, msg} ->
        {:error, msg}

      md ->
        extract_title(md)
    end
  end

  @doc """
  Runs a regex against provided markdown file and returns it's title, provided the file contains a YAML-like metadata.
  """
  def extract_title(md) do
    title = Regex.run(~r/(?<=title: ).*/, md)
    case title do
      [] -> nil
      _ -> hd(title)
    end
  end

  @doc """
  Reads contents of a markdown file.
  """
  def read_md(path) do
    case File.read(path) do
      {:ok, md} -> md
      _ -> {:error, "Cannot read md file"}
    end
  end
    @doc """
  This function takes `path` to and `markdown` file itself. Then runs a regex expression against the file that extracts the metadata from between the hyphens("---") and filters out all non-word characters. It prepares and converts metadata key-value pairs into a map.
  """
  def extract_metadata(path, md) do
    indices = Regex.run(~r/---([\s\S]*?)---/, md, return: :index)
    if indices == nil do
      {:error, "markdown file is missing a valid metadata section"}
    else
      unfiltered_metadata =
        String.split(
          String.slice(md, (elem(hd(indices), 0) + 3)..(elem(hd(indices), 1) - 3)),
          ~r/[\n]/
        )

      filtered_meta = Enum.filter(unfiltered_metadata, fn x -> String.match?(x, ~r/\w+/) end)
      key_value_pairs = Enum.map(filtered_meta, fn f -> String.split(f, ~r/:/) end)
      map = Enum.into(key_value_pairs, %{}, fn [a, b] -> {String.trim(a), String.trim(b)} end)
      MyApp.ArticleTracker.save_article(map["title"], path)
      Map.replace(map, "tags", Enum.map(String.split(map["tags"], ","), fn x -> String.trim(x) end))
    end
  end

  @doc """
   Reads and returns metadata of a markdown file from `path` .
  """
  def get_markdown_metadata(path) do
    case read_md(path) do
      {:error, msg} ->
        {:error, msg}
      md ->
        extract_metadata(path, md)
    end
  end

  @doc """
  Converts a string to a datetime.
  """
  def convert_map_string_to_date(map) do
      map
      |> Enum.map(fn x -> Map.replace(x, "published", Date.from_iso8601!(x["published"])) end)
  end

  @doc """
  Takes a list of markdown files and extracts metadata, then sorts them by date of publication.
  """
  def get_articles_metadata(files) do
    Enum.sort(
      convert_map_string_to_date(
        Enum.map(files, fn f -> get_markdown_metadata(f) end)
      ),
      fn am1, am2 -> Date.compare(am1["published"], am2["published"]) != :lt end
    )
  end

  @doc """
  Takes an article's title and returns its contents.
  """
  def get_article_by_title(title) do
    article_path = MyApp.ArticleTracker.get_articles_path(title)

    case article_path do
      :not_found ->
        {:error, "No article titled #{title} found"}

      :empty ->
        {:error, "No content found in article titled #{title}"}

      _ ->
        get_markdown_article(article_path)
    end
  end

  @doc """
  Takes in a path and returns article's content.
  """
  def get_markdown_article(path) do
    case read_md(path) do
      {:error, msg} ->
        {:error, msg}

      md ->
        extract_article(md)
    end
  end

  @doc """
  Runs a refgex agains a markdown file and returns everythin after first "#"(h1) tag.
  """
  def extract_article(md) do
    article = Regex.run(~r/(?=#).[\s\S]*/, md)

    case article do
      nil ->
        {:error, "Article has no content"}

      _ ->
        article
    end
  end
end
