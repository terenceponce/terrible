defmodule Terrible.Budgeting do
  @moduledoc """
  The Budgeting context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias Terrible.Budgeting.Book
  alias Terrible.Budgeting.BookUser
  alias Terrible.Budgeting.User
  alias Terrible.Repo

  @doc """
  Returns the list of Books that the given user has access to.

  ## Examples

      iex> list_books(user)
      [%Book{}, ...]

  """
  @spec list_books(Terrible.Budgeting.User.t()) :: [Terrible.Budgeting.Book.t()]
  def list_books(user) do
    Book
    |> join(:inner, [b], bu in assoc(b, :books_users))
    |> where([b, bu], bu.user_id == ^user.id)
    |> Repo.all()
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
  Creates a book and assigns the given user as an admin.

  ## Examples

      iex> create_book(user, %{field: value})
      {:ok, %Book{}}

      iex> create_book(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_book(Terrible.Budgeting.User.t(), map()) ::
          {:ok, Terrible.Budgeting.Book.t()} | {:error, Ecto.Changeset.t()}
  def create_book(user, attrs \\ %{}) do
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

  @doc """
  Gets a single user.

  Returns `nil` if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil
  """
  @spec get_user(integer()) :: Terrible.Budgeting.User.t()
  def get_user(id), do: Repo.get(User, id)
end
