defmodule Terrible.Identity.Repositories.UserTokenRepository do
  @moduledoc """
  Repository for the UserToken schema.
  """

  import Ecto.Query, warn: false

  alias Terrible.Identity.Constants
  alias Terrible.Identity.Schemas.User
  alias Terrible.Identity.Schemas.UserToken
  alias Terrible.Repo

  @doc """
  Builds a UserToken and its hash to be used to deliver to the user's email as part
  of the registration process.

  The non-hashed token is sent to the user email while the
  hashed part is stored in the database. The original token cannot be reconstructed,
  which means anyone with read-only access to the database cannot directly use
  the token in the application to gain access. Furthermore, if the user changes
  their email in the system, the tokens sent to the previous email are no longer
  valid.

  Users can easily adapt the existing code to provide other types of delivery methods,
  for example, by phone numbers.
  """
  @spec create_email_token(User.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def create_email_token(user, context) do
    token = :crypto.strong_rand_bytes(Constants.rand_size())
    hashed_token = :crypto.hash(Constants.hash_algorithm(), token)
    attrs = %{
      token: hashed_token,
      context: context,
      sent_to: user.email,
      user_id: user.id
    }

    case create(attrs) do
      {:ok, _} ->
        {:ok, Base.url_encode64(token, padding: false)}
      {:error, _} ->
        {:error, "Failed to create user token."}
    end
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.

  The reason why we store session tokens in the database, even
  though Phoenix already provides a session cookie, is because
  Phoenix' default session cookies are not persisted, they are
  simply signed and potentially encrypted. This means they are
  valid indefinitely, unless you change the signing/encryption
  salt.

  Therefore, storing them allows individual user
  sessions to be expired. The token system can also be extended
  to store additional data, such as the device used for logging in.
  You could then use this information to display all valid sessions
  and devices in the UI and allow users to explicitly expire any
  session they deem invalid.
  """
  @spec create_session_token(User.t()) :: binary()
  def create_session_token(user) do
    token = :crypto.strong_rand_bytes(Constants.rand_size())
    attrs = %{
      token: token,
      context: "session",
      user_id: user.id
    }

    case create(attrs) do
      {:ok, _} ->
        token
      {:error, _} ->
        raise "Failed to create session token."
    end
  end

  defp create(attrs) do
    %UserToken{}
    |> UserToken.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes the given session token
  """
  @spec delete_session(binary()) :: :ok
  def delete_session(token) do
    UserToken
    |> where([user_token], user_token.token == ^token)
    |> where([user_token], user_token.context == "session")
    |> Repo.delete_all()

    :ok
  end
end
