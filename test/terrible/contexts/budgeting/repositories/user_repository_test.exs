defmodule Terrible.Budgeting.Repositories.UserRepositoryTest do
  use Terrible.DataCase, async: true
  
  import Terrible.Factories.BudgetingFactory

  alias Terrible.Budgeting.Repositories.UserRepository

  test "get/1 returns a User with the given id when user exists" do
    user = insert(:user)
    assert UserRepository.get(user.id) == user
  end

  test "get_user/1 returns nil when user does not exist" do
    assert UserRepository.get(1234) == nil
  end
end
