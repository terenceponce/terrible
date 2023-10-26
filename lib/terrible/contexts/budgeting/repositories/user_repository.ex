defmodule Terrible.Budgeting.Repositories.UserRepository do
  @moduledoc """
  Repository for the User schema in the Budgeting context.
  """

  alias Terrible.Budgeting.Schemas.User
  alias Terrible.Repo

  @doc """
  Gets a single user.

  Returns `nil` if the User does not exist.

  ## Examples

      iex> get(123)
      %User{}

      iex> get(456)
      nil
  """
  @spec get(integer()) :: User.t() | nil
  def get(id), do: Repo.get(User, id)
end
