defmodule TerribleWeb.BookLive.Show do
  use TerribleWeb, :live_view

  alias Terrible.Budgeting

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Book <%= @book.id %>
      <:subtitle>This is a book record from your database.</:subtitle>
      <:actions>
        <.link patch={~p"/books/#{@book}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit book</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Name"><%= @book.name %></:item>
    </.list>

    <.back navigate={~p"/books"}>Back to books</.back>

    <.modal :if={@live_action == :edit} id="book-modal" show on_cancel={JS.patch(~p"/books/#{@book}")}>
      <.live_component
        module={TerribleWeb.BookLive.FormComponent}
        id={@book.id}
        title={@page_title}
        action={@live_action}
        book={@book}
        patch={~p"/books/#{@book}"}
        current_user_id={@current_user.id}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _session, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:book, Budgeting.get_book!(id))}
  end

  defp page_title(:show), do: "Show Book"
  defp page_title(:edit), do: "Edit Book"
end
