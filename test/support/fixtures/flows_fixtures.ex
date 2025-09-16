defmodule Flusomail.FlowsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Flusomail.Flows` context.
  """

  @doc """
  Generate a flow.
  """
  def flow_fixture(attrs \\ %{}) do
    # Create an organization first if not provided
    organization =
      case attrs[:organization_id] do
        nil ->
          scope = Flusomail.AccountsFixtures.user_scope_fixture()
          Flusomail.OrganizationsFixtures.organization_fixture(scope)

        org_id ->
          %{id: org_id}
      end

    # Create a user if not provided
    user =
      case attrs[:created_by_id] do
        nil -> Flusomail.AccountsFixtures.user_fixture()
        user_id -> %{id: user_id}
      end

    attrs =
      Enum.into(attrs, %{
        name: "some name",
        description: "some description",
        state: "draft",
        flow_type: "automation",
        graph: %{"nodes" => [], "edges" => []},
        canvas_state: %{"zoom" => 1, "pan" => %{"x" => 0, "y" => 0}},
        settings: %{},
        stats: %{"total_entered" => 0, "currently_active" => 0, "completed" => 0},
        organization_id: organization.id,
        created_by_id: user.id
      })

    {:ok, flow} = Flusomail.Flows.create_flow(attrs)
    flow
  end
end
