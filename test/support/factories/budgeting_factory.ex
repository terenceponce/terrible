defmodule Terrible.Factories.BudgetingFactory do
  @moduledoc """
  Test factories for the Budgeting context.
  """

  use ExMachina.Ecto, repo: Terrible.Repo

  alias Terrible.Budgeting.Book

  def book_factory do
    %Book{name: "Test Book"}
  end
end
