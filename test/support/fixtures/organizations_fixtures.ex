defmodule Flusomail.OrganizationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Flusomail.Organizations` context.
  """

  @doc """
  Generate a organization.
  """
  def organization_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        billing_email: "some billing_email",
        name: "some name",
        plan: "some plan",
        settings: %{},
        slug: "some-slug",
        status: "some status"
      })

    {:ok, organization} = Flusomail.Organizations.create_organization(scope, attrs)
    organization
  end

end
