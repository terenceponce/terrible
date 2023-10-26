defmodule Terrible.Budgeting.Repositories.BookRepository do
  @moduledoc """
  Repository for the Book schema.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias Terrible.Budgeting.Schemas.Book
  alias Terrible.Budgeting.Schemas.BookUser
  alias Terrible.Budgeting.Schemas.User
  alias Terrible.Repo

  @doc """
  Returns the list of Books that the given user has access to.

  ## Examples

      iex> list(user)
      [%Book{}, ...]

  """
  @spec list(User.t()) :: [Book.t()]
  def list(user) do
    Book
    |> join(:inner, [b], bu in assoc(b, :books_users))
    |> where([b, bu], bu.user_id == ^user.id)
    |> Repo.all()
  end

  @doc """
  Gets a single book.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get!(123)
      %Book{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get!(integer()) :: Book.t()
  def get!(id), do: Repo.get!(Book, id)

  @doc """
  Creates a book and assigns the given user as an admin.

  ## Examples

      iex> create(user, %{field: value})
      {:ok, %Book{}}

      iex> create(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create(User.t(), map()) ::
          {:ok, Book.t()} | {:error, Ecto.Changeset.t()}
  def create(user, attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:book, Book.changeset(%Book{}, attrs))
    |> Multi.insert(:book_user, fn %{book: book} ->
      BookUser.changeset(%BookUser{}, %{role: :admin, book_id: book.id, user_id: user.id})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{book: book}} -> {:ok, book}
      {:error, :book, changeset, _current_changes} -> {:error, changeset}
    end
  end

  @doc """
  Updates a book.

  ## Examples

      iex> update(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update(Book.t(), map()) ::
          {:ok, Book.t()} | {:error, Ecto.Changeset.t()}
  def update(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a book.

  ## Examples

      iex> delete(book)
      {:ok, %Book{}}

      iex> delete(book)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete(Book.t()) ::
          {:ok, Book.t()} | {:error, Ecto.Changeset.t()}
  def delete(%Book{} = book) do
    Repo.delete(book)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking Book changes.

  ## Examples

      iex> change(book)
      %Ecto.Changeset{data: %Book{}}

  """
  @spec change(Book.t(), map()) :: Ecto.Changeset.t()
  def change(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end
end
