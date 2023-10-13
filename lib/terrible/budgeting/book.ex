defmodule Terrible.Budgeting.Book do
  @moduledoc """
  Books represent a user's budget.

  This is where all transactions, categories, and everything
  that's related to budgeting is connected to.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer() | nil,
          name: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "books" do
    field :name, :string

    timestamps()
  end

  @doc false
  @spec changeset(Terrible.Budgeting.Book.t(), map()) :: Ecto.Changeset.t()
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
