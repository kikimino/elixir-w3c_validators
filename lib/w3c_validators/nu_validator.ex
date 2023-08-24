defmodule W3cValidators.NuValidator do
  @moduledoc """
  W3C HTML markup validator service wrapper
  """
  @markup_validator_uri "https://validator.w3.org/nu/"
  @text_html_utf8 "text/html; charset=utf-8"

  defmodule NuValidatorResult do
    @moduledoc """
    Validator result module for NuValidator
    """
    @derive [Jason.Encoder]
    defstruct [:url, :messages, :language]
  end

  defmodule Message do
    @moduledoc """
    Message module for NuValidatorResult
    """
    @derive [Jason.Encoder]
    defstruct [
      :type,
      :last_line,
      :last_column,
      :first_column,
      :sub_type,
      :message,
      :extract,
      :hilite_start,
      :hilite_length
    ]
  end

  def is_valid(%{messages: messages}) do
    Enum.any?(messages, fn message -> message.type == "error" end) == false
  end

  def validate_uri(nil), do: {:error, :empty_uri}
  def validate_uri(""), do: {:error, :empty_uri}

  def validate_uri([]), do: []

  def validate_uri(uris = [_]) do
    Enum.map(uris, fn uri -> validate_uri(uri) end)
  end

  @doc """
  Validate the markup of an URI

  ## Examples

      iex> W3cValidators.NuValidator.validate_uri("https://www.spkdev.net/")
      {:ok, result}
  """
  @spec validate_uri(String.t()) :: {:ok, term} | {:error, term}
  def validate_uri(uri) do
    url = "#{@markup_validator_uri}?doc=#{uri}&out=json"

    case decode_http_response(HTTPoison.get(url)) do
      {:ok, %{messages: [%{type: "non-document-error"} | _]}} ->
        {:error, :non_document_error}

      term ->
        term
    end
  end

  def validate_text(nil), do: {:ok, nil}

  def validate_text([]), do: []

  def validate_text(texts = [_]) do
    Enum.map(texts, fn text -> validate_text(text) end)
  end

  @doc """
  Validate the markup of a string

  ## Examples

      iex> W3cValidators.NuValidator.validate_text("<html>test</html>")
      {:ok, result}
  """
  @spec validate_text(String.t()) :: {:ok, term} | {:error, term}
  def validate_text(text) do
    headers = ["content-type": @text_html_utf8]
    url = "#{@markup_validator_uri}?out=json"
    decode_http_response(HTTPoison.post(url, text, headers))
  end

  defp decode_http_response(http_response) do
    case W3cValidators.handle_http_response(http_response) do
      {:ok, body} ->
        Jason.decode(body, keys: :atoms)

      term ->
        term
    end
  end
end
