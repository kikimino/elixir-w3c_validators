defmodule W3cValidators.CssValidator do
  @moduledoc """
  W3C CSS validator service wrapper
  """
  @css_validator_uri "https://jigsaw.w3.org/css-validator/validator"

  defmodule ErrorResult do
    @moduledoc """
    ErrorResult module for CssValidation
    """
    @derive [Jason.Encoder]
    defstruct [:context, :line, :message, :source, :type]
  end

  defmodule CssResult do
    @moduledoc """
    CssResult module for CssValidation
    """
    @derive [Jason.Encoder]
    defstruct [:errorcount, :warningcount]
  end

  defmodule Message do
    @moduledoc """
    Message module
    """
    @derive [Jason.Encoder]
    defstruct [:source, :message, :line, :type, :level]
  end

  defmodule CssValidation do
    @moduledoc """
    CssValidation module for CssValidatorResult
    """
    @derive [Jason.Encoder]
    defstruct [
      :uri,
      :checkedby,
      :csslevel,
      :date,
      :timestamp,
      :validity,
      :result,
      :warnings,
      :errors
    ]
  end

  defmodule CssValidatorResult do
    @moduledoc """
    CssValidatorResult module
    """
    @derive [Jason.Encoder]
    defstruct [:cssvalidation]
  end

  def is_valid(%{cssvalidation: %{result: %{errorcount: 0}}}) do
    true
  end

  def is_valid(%{cssvalidation: %{result: _}}) do
    false
  end

  def is_valid(%{cssvalidation: %{errors: errors}}) do
    case errors do
      nil ->
        true

      err ->
        Enum.any?(err) == false
    end
  end

  def validate_uri(nil), do: {:error, :empty_uri}
  def validate_uri(""), do: {:error, :empty_uri}

  def validate_uri([]), do: []

  def validate_uri(uris = [_]) do
    Enum.map(uris, fn uri -> validate_uri(uri) end)
  end

  @doc """
  Validate the CSS of an URI

  ## Examples

      iex> W3cValidators.CssValidator.validate_uri("https://www.spkdev.net/assets/main.css")
      {:ok, result}
  """
  @spec validate_uri(String.t()) :: {:ok, term} | {:error, term}
  def validate_uri(uri) do
    url = "#{@css_validator_uri}?uri=#{uri}&output=json"
    decode_http_response(HTTPoison.get(url))
  end

  def validate_text(nil), do: {:ok, nil}

  def validate_text([]), do: []

  def validate_text(texts = [_]) do
    Enum.map(texts, fn text -> validate_text(text) end)
  end

  @doc """
  Validate the CSS of a string

  ## Examples

      iex> W3cValidators.NuValidator.validate_text("tbody th { width: 42% }")
      {:ok, result}
  """
  @spec validate_text(String.t()) :: {:ok, term} | {:error, term}
  def validate_text(text) do
    decode_http_response(
      HTTPoison.post(
        @css_validator_uri,
        {:multipart, [{"text", text}, {"output", "json"}]}
      )
    )
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
