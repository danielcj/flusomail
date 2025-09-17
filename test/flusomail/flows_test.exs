defmodule Flusomail.FlowsTest do
  use Flusomail.DataCase

  alias Flusomail.Flows

  describe "flows" do
    alias Flusomail.Flows.Flow

    import Flusomail.AccountsFixtures
    import Flusomail.OrganizationsFixtures
    import Flusomail.FlowsFixtures

    @invalid_attrs %{name: nil, flow_type: nil, organization_id: nil}

    test "list_flows/1 returns all flows for organization" do
      scope1 = user_scope_fixture()
      scope2 = user_scope_fixture()
      organization1 = organization_fixture(scope1)
      organization2 = organization_fixture(scope2)

      flow1 = flow_fixture(%{organization_id: organization1.id})
      flow2 = flow_fixture(%{organization_id: organization2.id})

      assert Flows.list_flows(organization1.id) == [flow1]
      assert Flows.list_flows(organization2.id) == [flow2]
    end

    test "list_flows/1 returns flows for solo users (nil organization_id)" do
      user = user_fixture()
      flow1 = flow_fixture(%{organization_id: nil, created_by_id: user.id})
      flow2 = flow_fixture(%{organization_id: nil, created_by_id: user.id})

      # Create a flow for an organization to ensure it's not returned
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      _org_flow = flow_fixture(%{organization_id: organization.id})

      flows = Flows.list_flows(nil)
      assert length(flows) == 2
      assert flow1 in flows
      assert flow2 in flows
      assert Enum.all?(flows, fn f -> f.organization_id == nil end)
    end

    test "get_flow!/1 returns the flow with given id" do
      flow = flow_fixture()
      assert Flows.get_flow!(flow.id) == flow
    end

    test "get_flow!/2 returns the flow with given id for organization" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      organization = organization_fixture(scope)
      flow = flow_fixture(%{organization_id: organization.id})
      other_org = organization_fixture(other_scope)

      assert Flows.get_flow!(organization.id, flow.id) == flow

      assert_raise Ecto.NoResultsError, fn ->
        Flows.get_flow!(other_org.id, flow.id)
      end
    end

    test "get_flow!/2 returns the flow with given id for solo users (nil organization_id)" do
      user = user_fixture()
      flow = flow_fixture(%{organization_id: nil, created_by_id: user.id})

      # Create a flow for an organization to ensure it's not accessible
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      org_flow = flow_fixture(%{organization_id: organization.id})

      assert Flows.get_flow!(nil, flow.id) == flow

      assert_raise Ecto.NoResultsError, fn ->
        Flows.get_flow!(nil, org_flow.id)
      end
    end

    test "create_flow/1 with valid data creates a flow" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      user = user_fixture()

      valid_attrs = %{
        name: "Test Flow",
        description: "A test flow",
        flow_type: "automation",
        organization_id: organization.id,
        created_by_id: user.id
      }

      assert {:ok, %Flow{} = flow} = Flows.create_flow(valid_attrs)
      assert flow.name == "Test Flow"
      assert flow.description == "A test flow"
      assert flow.flow_type == "automation"
      assert flow.state == "draft"
      assert flow.organization_id == organization.id
      assert flow.created_by_id == user.id
    end

    test "create_flow/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Flows.create_flow(@invalid_attrs)
    end

    test "update_flow/2 with valid data updates the flow" do
      flow = flow_fixture()

      update_attrs = %{
        name: "Updated Flow",
        description: "Updated description",
        flow_type: "campaign"
      }

      assert {:ok, %Flow{} = updated_flow} = Flows.update_flow(flow, update_attrs)
      assert updated_flow.name == "Updated Flow"
      assert updated_flow.description == "Updated description"
      assert updated_flow.flow_type == "campaign"
    end

    test "update_flow/2 with invalid data returns error changeset" do
      flow = flow_fixture()
      assert {:error, %Ecto.Changeset{}} = Flows.update_flow(flow, @invalid_attrs)
      assert flow == Flows.get_flow!(flow.id)
    end

    test "delete_flow/1 deletes the flow" do
      flow = flow_fixture()
      assert {:ok, %Flow{}} = Flows.delete_flow(flow)
      assert_raise Ecto.NoResultsError, fn -> Flows.get_flow!(flow.id) end
    end

    test "change_flow/1 returns a flow changeset" do
      flow = flow_fixture()
      assert %Ecto.Changeset{} = Flows.change_flow(flow)
    end

    test "activate_flow/1 activates a draft flow" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      user = user_fixture()

      # Create a valid flow with trigger node
      valid_graph = %{
        "nodes" => [%{"id" => "trigger_1", "type" => "trigger", "data" => %{}}],
        "edges" => []
      }

      flow =
        flow_fixture(%{
          organization_id: organization.id,
          created_by_id: user.id,
          graph: valid_graph
        })

      assert {:ok, %Flow{} = activated_flow} = Flows.activate_flow(flow)
      assert activated_flow.state == "active"
      assert activated_flow.activated_at != nil
    end

    test "activate_flow/1 fails for flow without trigger" do
      flow = flow_fixture(%{graph: %{"nodes" => [], "edges" => []}})
      assert {:error, %Ecto.Changeset{}} = Flows.activate_flow(flow)
    end

    test "pause_flow/1 pauses an active flow" do
      flow = flow_fixture(%{state: "active"})
      assert {:ok, %Flow{} = paused_flow} = Flows.pause_flow(flow)
      assert paused_flow.state == "paused"
      assert paused_flow.paused_at != nil
    end

    test "duplicate_flow/2 creates a copy of the flow" do
      flow = flow_fixture()
      new_name = "#{flow.name} Copy"

      assert {:ok, %Flow{} = duplicated_flow} = Flows.duplicate_flow(flow, new_name)
      assert duplicated_flow.name == new_name
      assert duplicated_flow.id != flow.id
      assert duplicated_flow.state == "draft"
      assert duplicated_flow.graph == flow.graph
    end
  end
end
