defmodule Terrible.Identity.Emails.ConfirmationInstructionsEmail do
  @moduledoc """
  Deliver instructions to confirm account.
  """

  import Swoosh.Email

  alias Terrible.Identity.Schemas.User

  @spec call(
          User.t(),
          String.t()
        ) :: Swoosh.Email.t()
  def call(user, url) do
    body = message_body(user, url)

    new()
    |> to(user.email)
    |> from({"Terrible", "contact@example.com"})
    |> subject("Confirmation instructions")
    |> text_body(body)
  end

  defp message_body(user, url) do
    """
    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """
  end
end
