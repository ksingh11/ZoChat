defmodule Zochat.UserLib do
    @moduledoc """
        user related functions
    """
    def get_user_subscribed_groups(user_id) do
        # Get user subscription group from db, update to redis-cache
        _cache_key = "user:grps:#{user_id}"
        _cache_ttl = 18_000
        []
    end

    def user_clear_cache_group(user_id) do
        # clear redis cache for user groups
        _cache_key = "user:grps:#{user_id}"
        get_user_subscribed_groups(user_id)
        {:ok}
    end
end
