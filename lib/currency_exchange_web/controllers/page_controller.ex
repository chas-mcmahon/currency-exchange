defmodule CurrencyExchangeWeb.PageController do
  use CurrencyExchangeWeb, :controller

  def exchange(conn, %{"from" => from, "to" => to, "amount" => amount} = params) do
    with {:ok, resp} <- fetch_currency_info(),
         {:ok, rates} <- extract_exchange_rates(resp, from, to),
         {:ok, converted_amount} <- convert(rates, from, to, amount) do
      json(conn, %{currency: to, amount: Money.to_string(converted_amount, symbol: false)})
    else
      {:error, reason} -> json(conn, %{error: reason})
    end
  end

  def exchange(conn, params) do
    json(conn, %{error: "Currency exchange request missing info"})
  end

  defp fetch_currency_info() do
    with {:ok, %{body: body}} <- HTTPoison.get(fixer_latest_codes_url()),
         {:ok, resp} <- Jason.decode(body),
         :ok <- validate_api_request_success(resp) do
      {:ok, resp}
    else
      _ -> {:error, "Failed to fetch currency exchange info"}
    end
  end

  defp fixer_latest_codes_url() do
    "http://data.fixer.io/api/latest?access_key=#{fixer_api_key()}"
  end

  defp fixer_api_key do
    Application.get_env(:currency_exchange, :fixer_api_key)
  end

  defp validate_api_request_success(resp) do
    case resp do
      %{"success" => true} -> :ok
      %{"success" => false} -> :error
    end
  end

  defp extract_exchange_rates(%{"rates" => rates}, from, to) do
    case validate_currency_codes_available(rates, from, to) do
      :ok -> {:ok, rates}
      :error -> {:error, "One or more currency exchange rates to perform conversion is not available"}
    end
  end

  defp validate_currency_codes_available(rates, from, to) do
    with from_code when not is_nil(from_code) <- Map.get(rates, from),
         to_code when not is_nil(to_code) <- Map.get(rates, to) do
      :ok
    else
      _ -> :error
    end
  end

  defp convert(rates, from, to, amount) do
    from_rate = Map.get(rates, from)
    to_rate = Map.get(rates, to)

    converted_amount =
      amount
      |> Money.parse!(from)
      |> Money.multiply((to_rate / from_rate))
      |> (&(Money.new(&1.amount, to))).()

    {:ok, converted_amount}
  end
end
