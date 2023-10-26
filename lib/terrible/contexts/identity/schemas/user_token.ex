defmodule Terrible.Identity.Schemas.UserToken do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Terrible.Identity.Schemas.UserToken

  @hash_algorithm :sha256
  @rand_size 32

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the email may take over the account.
  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  @change_email_validity_in_days 7
  @session_validity_in_days 60

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer() | nil,
          token: binary() | nil,
          context: String.t() | nil,
          sent_to: String.t() | nil,
          user_id: integer() | nil,
          inserted_at: NaiveDateTime.t() | nil
        }

  schema "users_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    belongs_to :user, Terrible.Identity.Schemas.User

    timestamps(updated_at: false)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(user_token, attrs) do
    user_token
    |> cast(attrs, [:token, :context, :user_id, :sent_to])
    |> validate_required([:token, :context, :user_id])
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The token is valid if it matches the value in the database and it has
  not expired (after @session_validity_in_days).
  """
  @spec verify_session_token_query(binary()) :: {:ok, Ecto.Query.t()}
  def verify_session_token_query(token) do
    query =
      from token in token_and_context_query(token, "session"),
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: user

    {:ok, query}
  end

  @doc """
  Builds a token and its hash to be delivered to the user's email.

  The non-hashed token is sent to the user email while the
  hashed part is stored in the database. The original token cannot be reconstructed,
  which means anyone with read-only access to the database cannot directly use
  the token in the application to gain access. Furthermore, if the user changes
  their email in the system, the tokens sent to the previous email are no longer
  valid.

  Users can easily adapt the existing code to provide other types of delivery methods,
  for example, by phone numbers.
  """
  @spec build_email_token(Terrible.Identity.Schemas.User.t(), String.t()) :: {String.t(), t()}
  def build_email_token(user, context) do
    build_hashed_token(user, context, user.email)
  end

  defp build_hashed_token(user, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %UserToken{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       user_id: user.id
     }}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The given token is valid if it matches its hashed counterpart in the
  database and the user email has not changed. This function also checks
  if the token is being used within a certain period, depending on the
  context. The default contexts supported by this function are either
  "confirm", for account confirmation emails, and "reset_password",
  for resetting the password. For verifying requests to change the email,
  see `verify_change_email_token_query/2`.
  """
  @spec verify_email_token_query(binary(), String.t()) :: {:ok, Ecto.Query.t()} | :error
  def verify_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in token_and_context_query(hashed_token, context),
            join: user in assoc(token, :user),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == user.email,
            select: user

        {:ok, query}

      :error ->
        :error
    end
  end

  defp days_for_context("confirm"), do: @confirm_validity_in_days
  defp days_for_context("reset_password"), do: @reset_password_validity_in_days

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  This is used to validate requests to change the user
  email. It is different from `verify_email_token_query/2` precisely because
  `verify_email_token_query/2` validates the email has not changed, which is
  the starting point by this function.

  The given token is valid if it matches its hashed counterpart in the
  database and if it has not expired (after @change_email_validity_in_days).
  The context must always start with "change:".
  """
  @spec verify_change_email_token_query(binary(), String.t()) :: {:ok, Ecto.Query.t()} | :error
  def verify_change_email_token_query(token, "change:" <> _type = context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from token in token_and_context_query(hashed_token, context),
            where: token.inserted_at > ago(@change_email_validity_in_days, "day")

        {:ok, query}

      :error ->
        :error
    end
  end

  @doc """
  Returns the token struct for the given token value and context.
  """
  @spec token_and_context_query(binary(), String.t()) :: Ecto.Query.t()
  def token_and_context_query(token, context) do
    from UserToken, where: [token: ^token, context: ^context]
  end

  @doc """
  Gets all tokens for the given user for the given contexts.
  """
  @spec user_and_contexts_query(Terrible.Identity.Schemas.User.t(), [atom()]) :: Ecto.Query.t()
  def user_and_contexts_query(user, :all) do
    from t in UserToken, where: t.user_id == ^user.id
  end

  @spec user_and_contexts_query(Terrible.Identity.Schemas.User.t(), [atom()]) :: Ecto.Query.t()
  def user_and_contexts_query(user, [_ | _] = contexts) do
    from t in UserToken, where: t.user_id == ^user.id and t.context in ^contexts
  end
end