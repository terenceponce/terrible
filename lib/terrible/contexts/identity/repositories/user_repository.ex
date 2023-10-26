defmodule Terrible.Identity.Repositories.UserRepository do
  @moduledoc """
  Repository for the User schema in the Identity context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias Terrible.Identity.Constants
  alias Terrible.Identity.Schemas.User
  alias Terrible.Identity.Schemas.UserToken
  alias Terrible.Repo

  @doc """
  Gets a User by email.

  ## Examples

      iex> get_by_email("foo@example.com")
      %User{}

      iex> get_by_email("unknown@example.com")
      nil

  """
  @spec get_by_email(String.t()) :: User.t() | nil
  def get_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a User by email and password.

  ## Examples

      iex> get_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  @spec get_by_email_and_password(String.t(), String.t()) :: User.t() | nil
  def get_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = get_by_email(email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a user with the given signed token.
  """
  @spec get_by_session_token(binary()) :: User.t() | nil
  def get_by_session_token(token) do
    UserToken
    |> join(:inner, [user_token], user in assoc(user_token, :user))
    |> where([user_token], user_token.token == ^token)
    |> where([user_token], user_token.context == "session")
    |> where([user_token], user_token.inserted_at > ago(^session_validity_in_days(), "day"))
    |> select([_user_token, user], user)
    |> Repo.one()
  end

  defp session_validity_in_days, do: Constants.session_validity_in_days()

  @doc """
  Gets a single User.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get!(123)
      %User{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get!(integer()) :: User.t()
  def get!(id), do: Repo.get!(User, id)

  @doc """
  Registers a User.

  ## Examples

      iex> register(%{field: value})
      {:ok, %User{}}

      iex> register(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec register(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def register(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_registration(User.t(), map() | nil) :: Ecto.Changeset.t()
  def change_registration(user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_email(User.t(), map() | nil) :: Ecto.Changeset.t()
  def change_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  @spec apply_email(User.t(), String.t(), map()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def apply_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  @spec update_email(User.t(), String.t()) :: :ok | :error
  def update_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <-
           user
           |> email_multi(email, context)
           |> Repo.transaction() do
      :ok
    else
      _any -> :error
    end
  end

  defp email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Multi.new()
    |> Multi.update(:user, changeset)
    |> Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, [context]))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_password(User.t(), map() | nil) :: Ecto.Changeset.t()
  def change_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_password(User.t(), String.t(), map()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Multi.new()
    |> Multi.update(:user, changeset)
    |> Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _multi_name} -> {:error, changeset}
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  @spec confirm(binary()) :: {:ok, User.t()} | :error
  def confirm(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <-
           user
           |> confirm_user_multi()
           |> Repo.transaction() do
      {:ok, user}
    else
      _any -> :error
    end
  end

  defp confirm_user_multi(user) do
    Multi.new()
    |> Multi.update(:user, User.confirm_changeset(user))
    |> Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
  end
end
