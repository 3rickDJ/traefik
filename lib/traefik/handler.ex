defmodule Traefik.Handler do

  @files_path Path.expand("../../pages", __DIR__)

  import Traefik.Plugs, only: [rewrite_path: 1, log: 1, track: 1]
  import Traefik.Parser, only: [parse: 1]
  alias Traefik.Conn, as: Conn

  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> log()
    |> route()
    |> track()
    |> format_response()
  end

  def route(%Conn{ method: "GET", path: "/hello" } = conn ) do
    %{ conn | status: 200, response: "Hello mellow!😘" }
  end

  def route(%Conn{method: "GET", path: "/world"} = conn ) do
    %{ conn | status: 200, response: "Hello world!🌹" }
  end

  def route(%Conn{method: "GET", path: "/all"} = conn ) do
    %{conn | status: 200, response: "All developers greetings!:👋"}
  end

  def route(%Conn{method: "POST", path: "/new", params: params} = conn ) do
    %{conn
      | status: 201,
      response: "A new element created: #{params["name"]} from #{params["company"]}"
    }
  end

  def route(%Conn{method: "GET", path: "/about"} = conn ) do
    @files_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conn)
  end

  def route(%Conn{method: _method, path: path} = conn ) do
    %{ conn | status: 404, response: "'#{path}' not found!!!🤕"}
  end

  def handle_file( {:ok, content}, %Conn{} = conn ),
    do: %{ conn | status: 200, response: content }

  def handle_file( {:error, reason}, %Conn{} = conn ),
  do: %{ conn | status: 404, response: "File not found for: #{inspect(reason)}"}

  def format_response(%Conn{} = conn) do
    """
    HTTP/1.1 #{Conn.status(conn)}
    Host: some.com
    User-Agent: telnet
    Content-Length: #{String.length(conn.response)}
    Accept: */*

    #{conn.response}
    """
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

request_6 = """
POST /new HTTP/1.1
Accept: */*
Connection: keep-alive
Content-Type: application/x-www-form-urlencoded
User-Agent: telnet

name=Erick&company=MakingDevs
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
IO.puts( "--------------------" )
IO.puts( Traefik.Handler.handle( request_6 ) )
