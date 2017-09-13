defmodule LXD.Containers do
  alias LXD.Client
  alias LXD.Utils

  def all(opts \\ []) do
    raw = opts[:raw] || false
    as_url = opts[:as_url] || false

    fct = fn data ->
      data
      |> Enum.map(fn container ->
        case as_url do
          true -> container
          false -> container |> String.split("/") |> List.last
        end
      end)
    end

    Client.get("/containers")
    |> Utils.handle_lxd_response(raw: raw, type: :sync, fct: fct)
  end

  def create(template, opts \\ []) do
    raw = opts[:raw] || false
    wait = opts[:wait] || nil
    timeout = opts[:timeout] || nil

    result = Client.post("/containers", Poison.encode!(template))
    |> Utils.handle_lxd_response(raw: raw, type: :async)

    case wait do
      nil ->
        result
      false ->
        result
      true ->
        case result do
          {:ok, {_op, data}} -> LXD.Operations.wait(data["id"], raw: raw, timeout: timeout)
          _ -> result
        end
    end
  end

end
