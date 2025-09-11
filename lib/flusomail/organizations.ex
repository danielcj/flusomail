defmodule Flusomail.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias Flusomail.Repo

  alias Flusomail.Organizations.Organization
  alias Flusomail.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any organization changes.

  The broadcasted messages match the pattern:

    * {:created, %Organization{}}
    * {:updated, %Organization{}}
    * {:deleted, %Organization{}}

  """
  def subscribe_organizations(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Flusomail.PubSub, "user:#{key}:organizations")
  end

  defp broadcast_organization(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Flusomail.PubSub, "user:#{key}:organizations", message)
  end

  @doc """
  Returns the list of organizations.

  ## Examples

      iex> list_organizations(scope)
      [%Organization{}, ...]

  """
  def list_organizations(%Scope{} = scope) do
    Repo.all_by(Organization, user_id: scope.user.id)
  end

  @doc """
  Returns the list of organizations for a specific user.
  """
  def list_user_organizations(user) do
    from(ou in Flusomail.Organizations.OrganizationUser,
      where: ou.user_id == ^user.id,
      join: o in Organization,
      on: o.id == ou.organization_id,
      select: o
    )
    |> Repo.all()
  end

  @doc """
  Checks if an organization exists with the given domain and returns the verification status.
  
  Returns:
  - {:available} if no organization has this domain
  - {:exists_unverified, organization} if organization exists but domain is not verified
  - {:exists_verified, organization} if organization exists and domain is verified
  """
  def check_domain_availability(domain) do
    query = from(d in Flusomail.Organizations.Domain,
      where: d.name == ^domain,
      join: o in Organization,
      on: o.id == d.organization_id,
      select: {o, d}
    )
    
    case Repo.one(query) do
      nil -> {:available}
      {org, domain_record} ->
        if domain_record.verified_at do
          {:exists_verified, org}
        else
          {:exists_unverified, org}
        end
    end
  end

  @doc """
  Gets a single organization.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization!(scope, 123)
      %Organization{}

      iex> get_organization!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_organization!(%Scope{} = scope, id) do
    Repo.get_by!(Organization, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a organization.

  ## Examples

      iex> create_organization(scope, %{field: value})
      {:ok, %Organization{}}

      iex> create_organization(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_organization(%Scope{} = scope, attrs) do
    with {:ok, organization = %Organization{}} <-
           %Organization{}
           |> Organization.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_organization(scope, {:created, organization})
      {:ok, organization}
    end
  end

  @doc """
  Updates a organization.

  ## Examples

      iex> update_organization(scope, organization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_organization(scope, organization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_organization(%Scope{} = scope, %Organization{} = organization, attrs) do
    true = organization.user_id == scope.user.id

    with {:ok, organization = %Organization{}} <-
           organization
           |> Organization.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_organization(scope, {:updated, organization})
      {:ok, organization}
    end
  end

  @doc """
  Deletes a organization.

  ## Examples

      iex> delete_organization(scope, organization)
      {:ok, %Organization{}}

      iex> delete_organization(scope, organization)
      {:error, %Ecto.Changeset{}}

  """
  def delete_organization(%Scope{} = scope, %Organization{} = organization) do
    true = organization.user_id == scope.user.id

    with {:ok, organization = %Organization{}} <-
           Repo.delete(organization) do
      broadcast_organization(scope, {:deleted, organization})
      {:ok, organization}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.

  ## Examples

      iex> change_organization(scope, organization)
      %Ecto.Changeset{data: %Organization{}}

  """
  def change_organization(%Scope{} = scope, %Organization{} = organization, attrs \\ %{}) do
    true = organization.user_id == scope.user.id

    Organization.changeset(organization, attrs, scope)
  end

end
