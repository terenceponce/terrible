defmodule Terrible.Factories.IdentityFactory do
  @moduledoc """
  Test factories for the Identity context.
  """

  use ExMachina.Ecto, repo: Terrible.Repo

  alias Terrible.Identity.Schemas.User
  alias Terrible.TestHelpers.DataHelper

  def user_factory do
    %User{
      email: DataHelper.email(),
      hashed_password: Bcrypt.hash_pwd_salt("password")
    }
  end

  def confirmed_user_factory do
    struct!(
      user_factory(),
      %{
        confirmed_at: NaiveDateTime.utc_now()
      }
    )
  end
end
