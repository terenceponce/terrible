defmodule Terrible.Budgeting.Repositories.BookRepositoryTest do
  use Terrible.DataCase, async: true

  import Terrible.Factories.BudgetingFactory

  alias Terrible.Budgeting.Repositories.BookRepository
  alias Terrible.Budgeting.Schemas.Book

  @invalid_attrs %{name: nil}

  test "list/1 returns all Books" do
    book = insert(:book)
    user = insert(:user)
    insert(:book_user, book: book, user: user)

    assert BookRepository.list(user) == [book]
  end

  test "get!/1 returns a Book with the given ID" do
    book = insert(:book)
    assert BookRepository.get!(book.id) == book
  end

  test "create/1 with valid data creates a Book" do
    user = insert(:user)
    valid_attrs = %{name: "Test Book"}

    assert {:ok, %Book{} = book} = BookRepository.create(user, valid_attrs)
    assert book.name == "Test Book"
  end

  test "create/1 with invalid data returns error changeset" do
    user = insert(:user)
    assert {:error, %Ecto.Changeset{}} = BookRepository.create(user, @invalid_attrs)
  end

  test "update/2 with valid data updates the given Book" do
    book = insert(:book)
    update_attrs = %{name: "Test Book Updated"}

    assert {:ok, %Book{} = book} = BookRepository.update(book, update_attrs)
    assert book.name == "Test Book Updated"
  end

  test "update/2 with invalid data returns error changeset" do
    book = insert(:book)
    assert {:error, %Ecto.Changeset{}} = BookRepository.update(book, @invalid_attrs)
    assert book == BookRepository.get!(book.id)
  end

  test "delete/1 deletes the given Book" do
    book = insert(:book)
    assert {:ok, %Book{}} = BookRepository.delete(book)
    assert_raise Ecto.NoResultsError, fn -> BookRepository.get!(book.id) end
  end

  test "change/1 returns a book changeset" do
    book = insert(:book)
    assert %Ecto.Changeset{} = BookRepository.change(book)
  end
end
