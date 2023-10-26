defmodule Terrible.Identity.Services.DeliverUserConfirmationInstructions do
  @moduledoc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """

  alias Terrible.Identity.Emails.ConfirmationInstructionsEmail
  alias Terrible.Identity.Repositories.UserTokenRepository
  alias Terrible.Identity.Schemas.User
  alias Terrible.Mailer
  
  @spec call(
          User.t(),
          (String.t() -> String.t())
        ) :: {:ok, Swoosh.Email.t()} | {:error, term()}
  def call(user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      with {:ok, encoded_token} <- UserTokenRepository.create_email_token(user, "confirm") do
        url = confirmation_url_fun.(encoded_token)
        email = ConfirmationInstructionsEmail.call(user, url)

        with {:ok, _metadata} <- Mailer.deliver(email) do
          {:ok, email}
        end
      else
        {:error, _} ->
          {:error, "Failed to deliver confirmation instructions."}
      end
    end
  end
end
