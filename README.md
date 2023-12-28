A simple CRUD app to learn how different parts of Elixir fit together without using a framework.

Emphasis on the world simple...

To get postgres running:

```Bash
docker compose up
```

To run the actual app:

```Bash
mix deps.get
iex -S mix
```

Send HTTP requests to `http://localhost:4000/whatever_path_you_want`

The request path will be stored in the database, and the path will be reversed and then sent to you in a response.

Pretty simple stuff.

Originally I wanted to maintain TCP connections for an entire HTTP session, however that seems to be what websockets are for...

Connecting to postgres with Elixir was rather more difficult than I expected and lead me down a bit of a rabbit hole with unixodbc and psqlodbc until I found `postgrex` and just used that.

Connect to the database to see if requests are being persisted:

```Bash
docker exec -it backend-postgres bash
psql -U postgres
\d  # Show tables
```
