defmodule Terrible.Identity do
  @moduledoc """
  The Identity context.
  """

  import Ecto.Query, warn: false

  alias Terrible.Identity.Repositories.UserRepository
  alias Terrible.Identity.Repositories.UserTokenRepository
  alias Terrible.Identity.Schemas.User
  alias Terrible.Identity.Schemas.UserNotifier
  alias Terrible.Identity.Schemas.UserToken
  alias Terrible.Identity.Services.DeliverUserConfirmationInstructions
  alias Terrible.Identity.Services.DeliverUserUpdateEmailInstructions
  alias Terrible.Repo

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  @spec get_user_by_email(String.t()) :: User.t() | nil
  defdelegate get_user_by_email(email), to: UserRepository, as: :get_by_email

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  @spec get_user_by_email_and_password(String.t(), String.t()) :: User.t() | nil
  defdelegate get_user_by_email_and_password(email, password), to: UserRepository, as: :get_by_email_and_password

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(integer()) :: User.t()
  defdelegate get_user!(id), to: UserRepository, as: :get!

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec register_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate register_user(attrs), to: UserRepository, as: :register

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_user_registration(User.t(), map() | nil) :: Ecto.Changeset.t()
  defdelegate change_user_registration(user, attrs \\ %{}), to: UserRepository, as: :change_registration

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_user_email(User.t(), map() | nil) :: Ecto.Changeset.t()
  defdelegate change_user_email(user, attrs \\ %{}), to: UserRepository, as: :change_email

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  @spec apply_user_email(Terrible.Identity.Schemas.User.t(), String.t(), map()) ::
          {:ok, Terrible.Identity.Schemas.User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate apply_user_email(user, password, attrs), to: UserRepository, as: :apply_email

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  @spec update_user_email(User.t(), String.t()) :: :ok | :error
  defdelegate update_user_email(user, token), to: UserRepository, as: :update_email

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """
  @spec deliver_user_update_email_instructions(
          User.t(),
          String.t(),
          (String.t() -> String.t())
        ) :: {:ok, Swoosh.Email.t()} | {:error, String.t()}
  def deliver_user_update_email_instructions(user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    DeliverUserUpdateEmailInstructions.call(user, current_email, update_email_url_fun)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_user_password(User.t(), map() | nil) :: Ecto.Changeset.t()
  defdelegate change_user_password(user, attrs \\ %{}), to: UserRepository, as: :change_password

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_user_password(User.t(), String.t(), map()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_user_password(user, password, attrs), to: UserRepository, as: :update_password

  ## Session

  @doc """
  Generates a session token.
  """
  @spec generate_user_session_token(User.t()) :: binary()
  defdelegate generate_user_session_token(user), to: UserTokenRepository, as: :create_session_token

  @doc """
  Gets the user with the given signed token.
  """
  @spec get_user_by_session_token(binary()) :: User.t() | nil
  defdelegate get_user_by_session_token(token), to: UserRepository, as: :get_by_session_token

  @doc """
  Deletes the signed token with the given context.
  """
  @spec delete_user_session_token(binary()) :: :ok
  defdelegate delete_user_session_token(token), to: UserTokenRepository, as: :delete_session

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  @spec deliver_user_confirmation_instructions(
          User.t(),
          (String.t() -> String.t())
        ) :: {:ok, Swoosh.Email.t()} | {:error, term()}
  def deliver_user_confirmation_instructions(user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    DeliverUserConfirmationInstructions.call(user, confirmation_url_fun)
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  @spec confirm_user(binary()) :: {:ok, Terrible.Identity.Schemas.User.t()} | :error
  def confirm_user(token) do
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
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  @spec deliver_user_reset_password_instructions(
          Terrible.Identity.Schemas.User.t(),
          (String.t() -> String.t())
        ) :: {:ok, Swoosh.Email.t()}
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  @spec get_user_by_reset_password_token(binary()) :: Terrible.Identity.Schemas.User.t() | nil
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _any -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  @spec reset_user_password(Terrible.Identity.Schemas.User.t(), map()) ::
          {:ok, Terrible.Identity.Schemas.User.t()} | {:error, Ecto.Changeset.t()}
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _multi_name} -> {:error, changeset}
    end
  end
end