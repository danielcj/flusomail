defmodule Flusomail.Contacts do
  @moduledoc """
  The Contacts context for managing email contacts.
  """

  import Ecto.Query, warn: false
  alias Flusomail.Repo

  alias Flusomail.Contacts.Contact

  @doc """
  Returns the list of contacts for an organization or solo user.

  ## Examples

      iex> list_contacts(organization_id)
      [%Contact{}, ...]

  """
  def list_contacts(organization_id) do
    query =
      if is_nil(organization_id) do
        Contact |> where([c], is_nil(c.organization_id))
      else
        Contact |> where([c], c.organization_id == ^organization_id)
      end

    query
    |> order_by([c], [c.name, c.email])
    |> Repo.all()
  end

  @doc """
  Gets a single contact.

  Raises `Ecto.NoResultsError` if the Contact does not exist.

  ## Examples

      iex> get_contact!(123)
      %Contact{}

      iex> get_contact!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contact!(id), do: Repo.get!(Contact, id)

  @doc """
  Gets a single contact for an organization or solo user.
  """
  def get_contact!(organization_id, id) do
    query =
      if is_nil(organization_id) do
        Contact |> where([c], c.id == ^id and is_nil(c.organization_id))
      else
        Contact |> where([c], c.id == ^id and c.organization_id == ^organization_id)
      end

    Repo.one!(query)
  end

  @doc """
  Creates a contact.

  ## Examples

      iex> create_contact(%{field: value})
      {:ok, %Contact{}}

      iex> create_contact(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact(attrs \\ %{}) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contact.

  ## Examples

      iex> update_contact(contact, %{field: new_value})
      {:ok, %Contact{}}

      iex> update_contact(contact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact(%Contact{} = contact, attrs) do
    contact
    |> Contact.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contact.

  ## Examples

      iex> delete_contact(contact)
      {:ok, %Contact{}}

      iex> delete_contact(contact)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact(%Contact{} = contact) do
    Repo.delete(contact)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact changes.

  ## Examples

      iex> change_contact(contact)
      %Ecto.Changeset{data: %Contact{}}

  """
  def change_contact(%Contact{} = contact, attrs \\ %{}) do
    Contact.changeset(contact, attrs)
  end

  @doc """
  Returns the count of contacts for an organization or solo user.
  """
  def count_contacts(organization_id) do
    query =
      if is_nil(organization_id) do
        Contact |> where([c], is_nil(c.organization_id))
      else
        Contact |> where([c], c.organization_id == ^organization_id)
      end

    Repo.aggregate(query, :count, :id)
  end
end
