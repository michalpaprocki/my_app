defmodule MyAppWeb.BlogLive do
  use MyAppWeb, :live_view

  def mount(_params, _session, socket) do
    case MyApp.Blog.get_articles_files() do
      :empty -> raise("The markdown file is empty")
      {:ok, socket, layout: {MyAppWeb.Layouts, :root}}
      {:ok, files} ->

        metadata = MyApp.Blog.get_articles_metadata(files)

        {:ok, socket|> assign(:metadata, metadata)}
    end
  end
  def render(assigns) do
    ~H"""
      <div class="flex gap-2 flex-col p-8">
        <%= for meta <- @metadata do %>
          <.link navigate={"/blog/#{meta["title"]}"} class="flex flex-col p-2 bg-sky-700 text-white">
            <span><%= meta["author"] %></span>
            <span><%= meta["title"] %></span>
            <span><%= meta["published"] %></span>
          </.link>
        <% end %>
      </div>
    """
  end
end
