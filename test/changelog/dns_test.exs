defmodule Changelog.DnsTest do
  use ExUnit.Case, async: true
  alias Changelog.Dns

  describe "aaaa/1" do
    test "returns empty list when passed empty string or nil" do
      assert Dns.aaaa("") == {:ok, []}
      assert Dns.aaaa(nil) == {:ok, []}
    end

    test "returns error for non-existent domain" do
      assert {:error, _reason} = Dns.aaaa("non-existent-domain-12345.invalid")
    end

    test "handles valid IPv6 resolution" do
      # Using google.com as it typically has AAAA records
      case Dns.aaaa("google.com") do
        {:ok, addresses} ->
          assert is_list(addresses)
          assert length(addresses) > 0

          # Verify all addresses look like IPv6
          Enum.each(addresses, fn addr ->
            assert is_binary(addr)
            assert String.contains?(addr, ":")
          end)

        {:error, :not_found} ->
          # Some test environments might not have IPv6 connectivity
          :ok

        {:error, _reason} ->
          # DNS resolution can fail in test environments
          :ok
      end
    end
  end
end
