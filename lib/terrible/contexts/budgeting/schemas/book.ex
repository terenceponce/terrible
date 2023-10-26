defmodule Terrible.Budgeting.Schemas.Book do
  @moduledoc """
  Books represent a user's budget.

  This is where all transactions, categories, and everything
  that's related to budgeting is connected to.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Terrible.Budgeting.Schemas.BookUser
  alias Terrible.Budgeting.Schemas.User

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer() | nil,
          name: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "books" do
    field :name, :string

    has_many :books_users, BookUser
    many_to_many :users, User, join_through: BookUser

    timestamps()
  end

  @doc false
  @spec changeset(Terrible.Budgeting.Schemas.Book.t(), map()) :: Ecto.Changeset.t()
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
