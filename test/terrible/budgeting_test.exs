defmodule Terrible.BudgetingTest do
  use Terrible.DataCase, async: true

  import Terrible.Factories.BudgetingFactory

  alias Terrible.Budgeting
  alias Terrible.Budgeting.Book

  describe "books" do
    @invalid_attrs %{name: nil}

    test "list_books/1 returns all books" do
      book = insert(:book)
      user = insert(:user)
      insert(:book_user, book: book, user: user)

      assert Budgeting.list_books(user) == [book]
    end

    test "get_book!/1 returns the book with given id" do
      book = insert(:book)
      assert Budgeting.get_book!(book.id) == book
    end

    test "create_book/1 with valid data creates a book" do
      user = insert(:user)
      valid_attrs = %{name: "Test Book"}

      assert {:ok, %Book{} = book} = Budgeting.create_book(user, valid_attrs)
      assert book.name == "Test Book"
    end

    test "create_book/1 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Budgeting.create_book(user, @invalid_attrs)
    end

    test "update_book/2 with valid data updates the book" do
      book = insert(:book)
      update_attrs = %{name: "Test Book Updated"}

      assert {:ok, %Book{} = book} = Budgeting.update_book(book, update_attrs)
      assert book.name == "Test Book Updated"
    end

    test "update_book/2 with invalid data returns error changeset" do
      book = insert(:book)
      assert {:error, %Ecto.Changeset{}} = Budgeting.update_book(book, @invalid_attrs)
      assert book == Budgeting.get_book!(book.id)
    end

    test "delete_book/1 deletes the book" do
      book = insert(:book)
      assert {:ok, %Book{}} = Budgeting.delete_book(book)
      assert_raise Ecto.NoResultsError, fn -> Budgeting.get_book!(book.id) end
    end

    test "change_book/1 returns a book changeset" do
      book = insert(:book)
      assert %Ecto.Changeset{} = Budgeting.change_book(book)
    end
  end

  describe "users" do
    test "get_user/1 returns the user with the given id when user exists" do
      user = insert(:user)
      assert Budgeting.get_user(user.id) == user
    end

    test "get_user/1 returns nil when user does not exist" do
      assert Budgeting.get_user(1234) == nil
    end
  end
end
