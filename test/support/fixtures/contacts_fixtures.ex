defmodule Flusomail.ContactsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Flusomail.Contacts` context.
  """

  import Flusomail.AccountsFixtures
  import Flusomail.OrganizationsFixtures

  @doc """
  Generate a contact.
  """
  def contact_fixture(attrs \\ %{}) do
    # Create default organization and user if not provided
    {organization_id, created_by_id} =
      case {Map.get(attrs, :organization_id), Map.get(attrs, :created_by_id)} do
        {nil, nil} ->
          scope = user_scope_fixture()
          organization = organization_fixture(scope)
          {organization.id, scope.user.id}

        {org_id, nil} when is_binary(org_id) ->
          user = user_fixture()
          {org_id, user.id}

        {org_id, user_id} ->
          {org_id, user_id}
      end

    attrs =
      attrs
      |> Enum.into(%{
        email: "test#{System.unique_integer([:positive])}@example.com",
        organization_id: organization_id,
        created_by_id: created_by_id
      })
      |> Map.put_new(:name, "Contact #{System.unique_integer([:positive])}")

    {:ok, contact} = Flusomail.Contacts.create_contact(attrs)
    contact
  end
end
