defmodule PentoWeb.WrongLive do
  use PentoWeb, :live_view

  def mount(_params, session, socket) do
    {
      :ok,
      assign(
        socket,
        score: 0,
        message: "Guess a number",
        user: Pento.Accounts.get_user_by_session_token(session["user_token"]),
        session_id: session["live_socket_id"],
        time: time(),
        answer: 1..10 |> Enum.random() |> to_string
      )
    }
  end

  def render(assigns) do
    ~L"""
      <h1>Your score: <%= @score %></h1>
      <h2>
        <%= @message %>
        It's <%= @time %>
      </h2>
      <h2>
        <%= for n <- 1..10 do %>
          <a href="#" phx-click="guess" phx-value-number="<%= n %>"><%= n %></a>
        <% end %>
      </h2>
      <pre>
        <%= @user.email %>
        <%= @session_id %>
      </pre>
    """
  end

  def time() do
    DateTime.utc_now |> to_string
  end

  def handle_event("guess", %{"number" => guess}, socket = %{assigns: %{answer: answer}}) when guess == answer do
    message = "Your guess #{guess}. Was right. Play again"
    score = socket.assigns.score + 1;
    answer = 1..10 |> Enum.random() |> to_string

    IO.puts("answer is #{answer}")
    {
      :noreply,
      assign(
        socket,
        message: message,
        score: score,
        answer: answer,
        time: time())
    }
  end

  def handle_event("guess", %{"number" => guess} = data, socket) do
    IO.inspect data
    message = "Your guess #{guess}. Wrong guess again. "
    score = socket.assigns.score - 1
    {
      :noreply,
      assign(
        socket,
        message: message,
        time: time(),
        score: score
      )
    }
  end
end
