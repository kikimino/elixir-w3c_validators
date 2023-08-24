defmodule W3cValidators do
  @moduledoc """
  Base validators module
  """

  def handle_http_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 400}} ->
        {:error, :http_bad_request}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :http_not_found}

      {:ok, %HTTPoison.Response{status_code: 500}} ->
        {:error, :http_internal_server_error}

      {:error, %HTTPoison.Error{reason: http_reason}} ->
        {:error, http_reason}
    end
  end
end
