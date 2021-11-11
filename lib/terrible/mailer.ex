defmodule Terrible.Mailer do
  @moduledoc """
  Mailer class required to use Swoosh for sending emails
  """

  use Swoosh.Mailer, otp_app: :terrible
end
