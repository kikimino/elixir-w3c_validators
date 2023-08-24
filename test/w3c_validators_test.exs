defmodule W3cValidatorsTest do
  use ExUnit.Case
  doctest W3cValidators

  test "NuValidator.validate_text string" do
    {:ok, result} = W3cValidators.NuValidator.validate_text("test")
    assert length(result.messages) == 3
    refute W3cValidators.NuValidator.is_valid(result)
    message = hd(result.messages)
    assert message.extract == "test"
    assert message.type == "error"
    assert is_binary(message.message)
  end

  test "NuValidator.validate_text empty list" do
    [] = W3cValidators.NuValidator.validate_text([])
  end

  test "NuValidator.validate_text lists" do
    [{:ok, result}] = W3cValidators.NuValidator.validate_text(["test"])
    assert length(result.messages) == 3
  end

  test "NuValidator.validate_uri uri" do
    {:ok, result} =
      W3cValidators.NuValidator.validate_uri("https://www.spkdev.net/")

    assert result.url == "https://www.spkdev.net/"
    assert length(result.messages) >= 0
    assert W3cValidators.NuValidator.is_valid(result)
    message = hd(result.messages)
    assert message.type == "info"
    assert is_binary(message.message)
  end

  test "NuValidator.validate_uri missing scheme" do
    {:error, :non_document_error} =
      W3cValidators.NuValidator.validate_uri("plop")
  end

  test "NuValidator.validate_uri not found uri" do
    {:error, :non_document_error} =
      W3cValidators.NuValidator.validate_uri(
        "https://www.spkdev.net/assets/main.css"
      )
  end

  test "NuValidator.validate_uri empty string" do
    {:error, :empty_uri} = W3cValidators.NuValidator.validate_uri("")
  end

  test "NuValidator.validate_uri empty lists" do
    [] = W3cValidators.NuValidator.validate_uri([])
  end

  test "NuValidator.validate_uri lists" do
    [{:ok, result}] =
      W3cValidators.NuValidator.validate_uri(["https://www.spkdev.net/"])

    assert result.url == "https://www.spkdev.net/"
    assert length(result.messages) >= 0
    assert W3cValidators.NuValidator.is_valid(result)
  end

  test "CssValidator.validate_uri uri" do
    {:ok, result} =
      W3cValidators.CssValidator.validate_uri(
        "https://www.spkdev.net/css/main.css"
      )

    assert result.cssvalidation.csslevel == "css3"
    assert result.cssvalidation.validity
    assert W3cValidators.CssValidator.is_valid(result)
  end

  test "CssValidator.validate_uri not found uri" do
    {:error, :http_internal_server_error} =
      W3cValidators.CssValidator.validate_uri(
        "https://www.spkdev.net/assets/main.css"
      )
  end

  test "CssValidator.validate_uri empty string" do
    {:error, :empty_uri} = W3cValidators.CssValidator.validate_uri("")
  end

  test "CssValidator.validate_uri empty lists" do
    [] = W3cValidators.CssValidator.validate_uri([])
  end

  test "CssValidator.validate_uri lists" do
    [{:ok, result}] =
      W3cValidators.CssValidator.validate_uri([
        "https://www.spkdev.net/css/main.css"
      ])

    assert result.cssvalidation.csslevel == "css3"
    assert result.cssvalidation.validity
    assert W3cValidators.CssValidator.is_valid(result)
  end

  test "CssValidator.validate_text text ok" do
    {:ok, result} =
      W3cValidators.CssValidator.validate_text("tbody th{width: 25%}")

    assert result.cssvalidation.csslevel == "css3"
    assert result.cssvalidation.validity
    assert W3cValidators.CssValidator.is_valid(result)
  end

  test "CssValidator.validate_text text nok" do
    {:ok, result} =
      W3cValidators.CssValidator.validate_text("tbody th{width: /* 25%} */")

    assert result.cssvalidation.csslevel == "css3"
    assert result.cssvalidation.validity == false
    assert W3cValidators.CssValidator.is_valid(result) == false
    assert length(result.cssvalidation.errors) == 2
    assert result.cssvalidation.result.errorcount == 2
    error = hd(result.cssvalidation.errors)
    assert error.message == "Parse Error"
  end
end
