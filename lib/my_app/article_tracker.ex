defmodule MyApp.ArticleTracker do
  use GenServer

  @moduledoc """
  A GenServer module responsible for keeping track of article titles and file paths.
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: ArticleTracker)
  end

  def init(_) do
    :ets.new(:articles_data, [:protected, :set, :named_table])

    IO.puts("\nPrepping #{"ArticleTracker..."}\n")

    case MyApp.Blog.get_articles_titles_and_paths() do
      {:error, _msg} ->
        IO.puts("\nStarting ArticleTracker without stored values\n ")

      data ->
        Enum.map(data, fn d -> :ets.insert(:articles_data, d) end)
        IO.puts("\nStarting ArticleTracker\n")
    end
    {:ok, %{:table => :articles_data}}
  end
  def save_article(title, path) do
    GenServer.call(ArticleTracker, {:save, {title, path}})
  end

  def get_articles_path(title) do
    GenServer.call(ArticleTracker, {:read, {title}})
  end

  def get_all() do
    GenServer.call(ArticleTracker, {:all})
  end

  def handle_call({:save, {title, path}}, _from, state) do
    result = :ets.insert(state.table, {title, path})
    {:reply, result, state}
  end

  def handle_call({:read, {title}}, _from, state) do
    result = :ets.match(state.table, {title, :"$1"})

    case result do
      [] ->
        {:reply, :not_found, state}

      _ ->
        {:reply, hd(hd(result)), state}
    end
  end

  def handle_call({:all}, _from, state) do
    result = :ets.match_object(state.table, {:"$1", :"$2"})

    case result do
      [] ->
        {:reply, :empty, state}

      _ ->
        {:reply, result, state}
    end
  end
end
