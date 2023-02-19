defmodule Traefik.Handler do

  @files_path Path.expand("../../pages", __DIR__)

  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> log()
    |> route()
    |> track()
    |> format_response()
  end

  def parse(request) do
    [method, path, _protocol] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")
    %{ method: method, path: path, response: "" , status: nil}
  end

  def rewrite_path( %{path: "/redirectme" } = conn ) do
    %{ conn | path: "/all" }
  end

  def rewrite_path( conn ), do: conn

  def log(conn), do: IO.inspect( conn, label: "Logger" ) 

  def route(conn) do
    route(conn, conn.method, conn.path)
  end

  def route(conn, "GET", "/hello") do
    %{ conn | status: 200, response: "Hello mellow!😘" }
  end

  def route(conn, "GET", "/world") do
    %{ conn | status: 200, response: "Hello world!🌹" }
  end

  def route(conn, "GET", "/all") do
    %{conn | status: 200, response: "All developers greetings!:👋"}
  end

  def route(conn, "GET", "/about") do
    @files_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conn)
  end

  def route(conn, _method, path) do
    %{ conn | status: 404, response: "'#{path}' not found!!!🤕"}
  end

  def handle_file( {:ok, content}, conn ),
    do: %{ conn | status: 200, response: content }

  def handle_file( {:error, reason}, conn ),
  do: %{ conn | status: 404, response: "File not found for: #{inspect(reason)}"}

  def track( %{ status: 404, path: path } = conn ) do
    IO.inspect("Warn:✊ path #{path} not found", label: "Tracker")
    conn
  end

  def track( conn ), do: conn

  def format_response(conn) do
    """
    HTTP/1.1 #{conn.status} #{status_reason(conn.status)}
    Host: some.com
    User-Agent: telnet
    Content-Length: #{String.length(conn.response)}
    Accept: */*

    #{conn.response}
    """
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
    }[code]
    # |> MAP.get(code)
    end
end

request_1 = """
GET /hello HTTP/1.1
Accept: */*
Connection: keep-alive
User-Agent: telnet


"""

request_2 = """
GET /world HTTP/1.1
Accept: */*
Connection: keep-alive
User-Agent: telnet


"""

request_3 = """
GET /not-found HTTP/1.1
Accept: */*
Connection: keep-alive
User-Agent: telnet


"""

request_4 = """
GET /redirectme HTTP/1.1
Accept: */*
Connection: keep-alive
User-Agent: telnet


"""

request_5 = """
GET /about HTTP/1.1
Accept: */*
Connection: keep-alive
User-Agent: telnet


"""

IO.puts( Traefik.Handler.handle( request_1 ) )
IO.puts( "--------------------" )
IO.puts( Traefik.Handler.handle( request_2 ) )
IO.puts( "--------------------" )
IO.puts( Traefik.Handler.handle( request_3 ) )
IO.puts( "--------------------" )
IO.puts( Traefik.Handler.handle( request_4 ) )
IO.puts( "--------------------" )
IO.puts( Traefik.Handler.handle( request_5 ) )
