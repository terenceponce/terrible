defmodule TerribleWeb.BookLiveTest do
  use TerribleWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Terrible.Factories.BudgetingFactory

  @create_attrs %{name: "Test Book"}
  @update_attrs %{name: "Test Book Updated"}
  @invalid_attrs %{name: nil}

  defp create_book(_context) do
    %{book: insert(:book)}
  end

  defp create_user(%{book: book}) do
    user = insert(:user)
    insert(:book_user, role: :admin, book: book, user: user)

    %{user: user}
  end

  describe "Index" do
    setup [:create_book, :create_user]

    test "lists all books", %{conn: conn, book: book, user: user} do
      {:ok, _index_live, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/books")

      assert html =~ "Listing Books"
      assert html =~ book.name
    end

    test "saves new book", %{conn: conn, user: user} do
      {:ok, index_live, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/books")

      assert index_live |> element("a", "New Book") |> render_click() =~
               "New Book"

      assert_patch(index_live, ~p"/books/new")

      assert index_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#book-form", book: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/books")

      html = render(index_live)
      assert html =~ "Book created successfully"
      assert html =~ "Test Book"
    end

    test "updates book in listing", %{conn: conn, book: book, user: user} do
      {:ok, index_live, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/books")

      assert index_live |> element("#books-#{book.id} a", "Edit") |> render_click() =~
               "Edit Book"

      assert_patch(index_live, ~p"/books/#{book}/edit")

      assert index_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#book-form", book: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/books")

      html = render(index_live)
      assert html =~ "Book updated successfully"
      assert html =~ "Test Book Updated"
    end

    test "deletes book in listing", %{conn: conn, book: book, user: user} do
      {:ok, index_live, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/books")

      assert index_live |> element("#books-#{book.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#books-#{book.id}")
    end
  end

  describe "Show" do
    setup [:create_book, :create_user]

    test "displays book", %{conn: conn, book: book, user: user} do
      {:ok, _show_live, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/books/#{book}")

      assert html =~ "Show Book"
      assert html =~ book.name
    end

    test "updates book within modal", %{conn: conn, book: book, user: user} do
      {:ok, show_live, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/books/#{book}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Book"

      assert_patch(show_live, ~p"/books/#{book}/show/edit")

      assert show_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#book-form", book: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/books/#{book}")

      html = render(show_live)
      assert html =~ "Book updated successfully"
      assert html =~ "Test Book Updated"
    end
  end
end
