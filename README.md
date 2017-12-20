# Carrier

This is an unofficial Elixir client for the excellent
[SmartyStreets](https://smartystreets.com/) address verification service.

It's fairly bare-bones because all we need it for is verifying and standardizing
addresses, however it might get beefed up in the future. There's a ton of data
provided by SmartyStreets in addition to the verification process, and some of
it might be pretty useful to have (such as geo-coding, timezone data, etc.).

It is essentially just a `GenServer` that handles the minutiae of communicating
with the SmartyStreets API.

## Installation

### Add carrier to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:carrier, "~> 1.0.0"}]
end
```

### Add configuration to `config.exs`:

```elixir
config :carrier,
  smarty_streets_id: "your auth-id here",
  smarty_streets_token: "your auth-token here"
```

## Usage

### Validating one address

A pretty well-formed and complete address to query:

```elixir
iex> Carrier.verify_one {"1 Infinite Loop", "Cupertino", "CA", "95014"}
{:valid, {"1 Infinite Loop", "Cupertino", "CA", "95014-2083"}}
```

Note that the addresses are also standardized (to follow USPS guidelines):

```elixir
iex> Carrier.verify_one {"1 infinite loop", "cupertino", "ca", "95014"}
{:valid, {"1 Infinite Loop", "Cupertino", "CA", "95014-2083"}}

iex> Carrier.verify_one {"1096 Rainer Dr, Suite 1001", "", "", "32714"}
{:valid, {"1096 Rainer Dr Ste 1001", "Altamonte Springs", "FL", "32714-3855"}}
```

You can supply empty strings for fields you don't know:

```elixir
iex> Carrier.verify_one {"1 Infinite Loop", "", "", "95014"}
{:valid, {"1 Infinite Loop", "Cupertino", "CA", "95014-2083"}}

iex> Carrier.verify_one {"1 Infinite Loop", "Cupertino", "", "95014"}
{:valid, {"1 Infinite Loop", "Cupertino", "CA", "95014-2083"}}

iex> Carrier.verify_one {"1 Infinite Loop", "Cupertino", "CA", ""}
{:valid, {"1 Infinite Loop", "Cupertino", "CA", "95014-2083"}}
```

If an address is invalid, we'll let you know and provide the original back:

```elixir
iex> Carrier.verify_one {"123 Fake St", "Anytown", "FL", "12345"}
{:invalid, {"123 Fake St", "Anytown", "FL", "12345"}}
```

### Validating a list of addresses

```elixir
iex> Carrier.verify_many [{"1 Infinite Loop", "", "", "95014"},
...>                      {"1096 Rainer Dr, Suite 1001", "", "", "32714"}]
[valid: {"1 Infinite Loop", "Cupertino", "CA", "95014-2083"},
 valid: {"1096 Rainer Dr Ste 1001", "Altamonte Springs", "FL", "32714-3855"}]
```
