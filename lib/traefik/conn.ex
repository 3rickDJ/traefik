defmodule Traefik.Conn do
  defstruct method: "",
            path: "",
            response: "",
            status: nil,
            params: %{},
            headers: %{},
            content_type: "text/html"

  def status(%__MODULE__{} = conn) do
    "#{conn.status} #{status_reason(conn.status)}"
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      301 => "Moved Permanently",
      303 => "See Other",
      400 => "Bad Request",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }
    |> Map.get(code)
  end
end
