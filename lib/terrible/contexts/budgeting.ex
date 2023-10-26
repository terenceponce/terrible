defmodule Terrible.Budgeting do
  @moduledoc """
  The Budgeting context.
  """

  import Ecto.Query, warn: false

  alias Terrible.Budgeting.Repositories.BookRepository
  alias Terrible.Budgeting.Repositories.UserRepository
  alias Terrible.Budgeting.Schemas.Book
  alias Terrible.Budgeting.Schemas.User

  @doc """
  Returns the list of Books that the given user has access to.

  ## Examples

      iex> list_books(user)
      [%Book{}, ...]

  """
  @spec list_books(User.t()) :: [Book.t()]
  defdelegate list_books(user), to: BookRepository, as: :list

  @doc """
  Gets a single book.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book!(123)
      %Book{}

      iex> get_book!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_book!(integer()) :: Book.t()
  defdelegate get_book!(id), to: BookRepository, as: :get!

  @doc """
  Creates a book and assigns the given user as an admin.

  ## Examples

      iex> create_book(user, %{field: value})
      {:ok, %Book{}}

      iex> create_book(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_book(User.t(), map()) ::
          {:ok, Book.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_book(user, attrs \\ %{}), to: BookRepository, as: :create

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_book(Book.t(), map()) ::
          {:ok, Book.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_book(book, attrs), to: BookRepository, as: :update

  @doc """
  Deletes a book.

  ## Examples

      iex> delete_book(book)
      {:ok, %Book{}}

      iex> delete_book(book)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_book(Book.t()) ::
          {:ok, Book.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_book(book), to: BookRepository, as: :delete

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  @spec change_book(Book.t(), map()) :: Ecto.Changeset.t()
  defdelegate change_book(book, attrs \\ %{}), to: BookRepository, as: :change

  @doc """
  Gets a single user.

  Returns `nil` if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil
  """
  @spec get_user(integer()) :: User.t()
  defdelegate get_user(id), to: UserRepository, as: :get
end
