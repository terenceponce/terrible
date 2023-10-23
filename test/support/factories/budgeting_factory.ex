defmodule Terrible.Factories.BudgetingFactory do
  @moduledoc """
  Test factories for the Budgeting context.
  """

  use ExMachina.Ecto, repo: Terrible.Repo

  alias Terrible.Budgeting.Book
  alias Terrible.Budgeting.BookUser
  alias Terrible.Budgeting.User
  alias Terrible.TestHelpers.DataHelper

  def book_factory do
    %Book{name: "Test Book"}
  end

  def book_user_factory do
    %BookUser{role: :viewer}
  end

  def user_factory do
    %User{
      email: DataHelper.email(),
      hashed_password: Bcrypt.hash_pwd_salt("password")
    }
  end
end
