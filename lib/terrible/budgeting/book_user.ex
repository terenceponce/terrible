defmodule Terrible.Budgeting.BookUser do
  @moduledoc """
  BookUser represents the relationship between a Book and a User.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Terrible.Budgeting.Book
  alias Terrible.Budgeting.User

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer() | nil,
          role: atom() | nil,
          book_id: integer() | nil,
          user_id: integer() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "books_users" do
    field :role, Ecto.Enum, values: [:admin, :editor, :viewer], default: :viewer

    belongs_to :book, Book
    belongs_to :user, User

    timestamps()
  end

  @doc false
  @spec changeset(Terrible.Budgeting.BookUser.t(), map()) :: Ecto.Changeset.t()
  def changeset(book_user, attrs) do
    book_user
    |> cast(attrs, [:role, :book_id, :user_id])
    |> validate_required([:book_id, :user_id])
  end
end
