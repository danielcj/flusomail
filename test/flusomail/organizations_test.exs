defmodule Flusomail.OrganizationsTest do
  use Flusomail.DataCase

  alias Flusomail.Organizations

  describe "organizations" do
    alias Flusomail.Organizations.Organization

    import Flusomail.AccountsFixtures, only: [user_scope_fixture: 0]
    import Flusomail.OrganizationsFixtures

    @invalid_attrs %{
      name: nil,
      status: nil,
      plan: nil,
      slug: nil,
      settings: nil,
      billing_email: nil
    }

    test "list_organizations/1 returns all scoped organizations" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      organization = organization_fixture(scope)
      other_organization = organization_fixture(other_scope)
      assert Organizations.list_organizations(scope) == [organization]
      assert Organizations.list_organizations(other_scope) == [other_organization]
    end

    test "get_organization!/2 returns the organization with given id" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      other_scope = user_scope_fixture()
      assert Organizations.get_organization!(scope, organization.id) == organization

      assert_raise Ecto.NoResultsError, fn ->
        Organizations.get_organization!(other_scope, organization.id)
      end
    end

    test "create_organization/2 with valid data creates a organization" do
      valid_attrs = %{
        name: "some name",
        status: "some status",
        plan: "some plan",
        slug: "some-slug",
        settings: %{},
        billing_email: "some billing_email"
      }

      scope = user_scope_fixture()

      assert {:ok, %Organization{} = organization} =
               Organizations.create_organization(scope, valid_attrs)

      assert organization.name == "some name"
      assert organization.status == "some status"
      assert organization.plan == "some plan"
      assert organization.slug == "some-slug"
      assert organization.settings == %{}
      assert organization.billing_email == "some billing_email"
      assert organization.user_id == scope.user.id
    end

    test "create_organization/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Organizations.create_organization(scope, @invalid_attrs)
    end

    test "update_organization/3 with valid data updates the organization" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)

      update_attrs = %{
        name: "some updated name",
        status: "some updated status",
        plan: "some updated plan",
        slug: "some-updated-slug",
        settings: %{},
        billing_email: "some updated billing_email"
      }

      assert {:ok, %Organization{} = organization} =
               Organizations.update_organization(scope, organization, update_attrs)

      assert organization.name == "some updated name"
      assert organization.status == "some updated status"
      assert organization.plan == "some updated plan"
      assert organization.slug == "some-updated-slug"
      assert organization.settings == %{}
      assert organization.billing_email == "some updated billing_email"
    end

    test "update_organization/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      organization = organization_fixture(scope)

      assert_raise MatchError, fn ->
        Organizations.update_organization(other_scope, organization, %{})
      end
    end

    test "update_organization/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Organizations.update_organization(scope, organization, @invalid_attrs)

      assert organization == Organizations.get_organization!(scope, organization.id)
    end

    test "delete_organization/2 deletes the organization" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      assert {:ok, %Organization{}} = Organizations.delete_organization(scope, organization)

      assert_raise Ecto.NoResultsError, fn ->
        Organizations.get_organization!(scope, organization.id)
      end
    end

    test "delete_organization/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      organization = organization_fixture(scope)

      assert_raise MatchError, fn ->
        Organizations.delete_organization(other_scope, organization)
      end
    end

    test "change_organization/2 returns a organization changeset" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      assert %Ecto.Changeset{} = Organizations.change_organization(scope, organization)
    end
  end
end
