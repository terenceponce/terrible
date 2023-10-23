defmodule Terrible.Budgeting.User do
  @moduledoc """
  User for the Budgeting context.
  """

  use Ecto.Schema

  alias Terrible.Budgeting.Book
  alias Terrible.Budgeting.BookUser

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer() | nil,
          email: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "users" do
    field :email, :string

    # Not actually needed, but is needed for creating test factories
    field :hashed_password, :string, redact: true

    many_to_many :books, Book, join_through: BookUser

    timestamps()
  end
end
