defmodule Terrible.Budgeting do
  @moduledoc """
  The Budgeting context.
  """

  import Ecto.Query, warn: false
  alias Terrible.Repo

  alias Terrible.Budgeting.Book

  @doc """
  Returns the list of books.

  ## Examples

      iex> list_books()
      [%Book{}, ...]

  """
  @spec list_books() :: [Terrible.Budgeting.Book.t()]
  def list_books do
    Repo.all(Book)
  end

  @doc """
  Gets a single book.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book!(123)
      %Book{}

      iex> get_book!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_book!(integer()) :: Terrible.Budgeting.Book.t()
  def get_book!(id), do: Repo.get!(Book, id)

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(%{field: value})
      {:ok, %Book{}}

      iex> create_book(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_book(map()) :: {:ok, Terrible.Budgeting.Book.t()} | {:error, Ecto.Changeset.t()}
  def create_book(attrs \\ %{}) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_book(Terrible.Budgeting.Book.t(), map()) ::
          {:ok, Terrible.Budgeting.Book.t()} | {:error, Ecto.Changeset.t()}
  def update_book(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a book.

  ## Examples

      iex> delete_book(book)
      {:ok, %Book{}}

      iex> delete_book(book)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_book(Terrible.Budgeting.Book.t()) ::
          {:ok, Terrible.Budgeting.Book.t()} | {:error, Ecto.Changeset.t()}
  def delete_book(%Book{} = book) do
    Repo.delete(book)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  @spec change_book(Terrible.Budgeting.Book.t(), map()) :: Ecto.Changeset.t()
  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end
end
