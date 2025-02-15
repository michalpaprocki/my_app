
defmodule MyAppWeb.ArticleLive do

  use MyAppWeb, :live_view

  def mount(params, _session, socket) do
   %{"title" => title} = params
   article = MyApp.Blog.get_article_by_title(title)

    case article do
      {:error, msg} ->

        {:ok, socket |> assign(:error, msg)}
      article ->
        {:ok, socket |> assign(:article, hd(article))}
    end
  end

  def render(%{:error => _msg} = assigns) do
    ~H"""
      <article class="prose flex items-center flex-col">
        <h1 class="bold text-3xl py-10">Error</h1>
        <p class="semi-bold text-xl"><%= @error %></p>
      </article>
    """
  end
  def render(assigns) do
    ~H"""
      <article id="article" phx-hook="HandleCopy" class="prose-pre:z-0 prose max-w-max py-10 prose-code:before:hidden prose-code:after:hidden p-2 prose-h2:my-0 prose-h2:pb-8 prose-h2:pt-20 prose-h3:my-0 prose-h3:pb-8 prose-h3:pt-20">
        <%= Phoenix.HTML.raw(Earmark.as_html!(@article)) %>
      </article>
    """
  end
end
