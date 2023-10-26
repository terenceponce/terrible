defmodule Terrible.Identity.Services.DeliverUserUpdateEmailInstructions do
  @moduledoc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> call(user, current_email, &url(~p"/users/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """

  alias Terrible.Identity.Emails.UpdateEmailInstructionsEmail
  alias Terrible.Identity.Repositories.UserTokenRepository
  alias Terrible.Identity.Schemas.User
  alias Terrible.Mailer

  @spec call(
          User.t(),
          String.t(),
          (String.t() -> String.t())
        ) :: {:ok, Swoosh.Email.t()} | {:error, String.t()}
  def call(user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    with {:ok, encoded_token} <- UserTokenRepository.create_email_token(user, "change:#{current_email}") do
      url = update_email_url_fun.(encoded_token)
      email = UpdateEmailInstructionsEmail.call(user, url)

      with {:ok, _metadata} <- Mailer.deliver(email) do
        {:ok, email}
      end
    else
      {:error, _} ->
        {:error, "Failed to deliver update email instructions."}
    end
  end
end
