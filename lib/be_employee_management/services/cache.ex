defmodule Exercise.Services.Cache do
  def get_from_cache(key) do
    cached_value = Cachex.get!(:my_cache, key)

    case cached_value do
      nil -> {:error, nil}
      value -> {:ok, value}
    end
  end

  def put_in_cache(key, val, ttl_in_sec \\ nil) do
    Cachex.put(:my_cache, key, val, ttl: :timer.seconds(ttl_in_sec))
  end
end
