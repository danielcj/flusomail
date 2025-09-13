defmodule Flusomail.Templates do
  @moduledoc """
  The Templates context.
  """

  import Ecto.Query, warn: false
  alias Flusomail.Repo

  alias Flusomail.Templates.Template

  @doc """
  Returns the list of templates for an organization.

  ## Examples

      iex> list_templates(org_id)
      [%Template{}, ...]

  """
  def list_templates(organization_id) do
    Template
    |> where([t], t.organization_id == ^organization_id)
    |> order_by([t], [desc: t.inserted_at])
    |> Repo.all()
  end

  @doc """
  Returns the list of active templates for an organization.

  ## Examples

      iex> list_active_templates(org_id)
      [%Template{}, ...]

  """
  def list_active_templates(organization_id) do
    Template
    |> where([t], t.organization_id == ^organization_id and t.is_active == true)
    |> order_by([t], [desc: t.inserted_at])
    |> Repo.all()
  end

  @doc """
  Returns the list of templates for an organization by category.

  ## Examples

      iex> list_templates_by_category(org_id, "promotional")
      [%Template{}, ...]

  """
  def list_templates_by_category(organization_id, category) do
    Template
    |> where([t], t.organization_id == ^organization_id and t.category == ^category)
    |> where([t], t.is_active == true)
    |> order_by([t], [desc: t.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets a single template.

  Raises `Ecto.NoResultsError` if the Template does not exist.

  ## Examples

      iex> get_template!(id, org_id)
      %Template{}

      iex> get_template!("invalid", org_id)
      ** (Ecto.NoResultsError)

  """
  def get_template!(id, organization_id) do
    Template
    |> where([t], t.id == ^id and t.organization_id == ^organization_id)
    |> Repo.one!()
  end

  @doc """
  Gets a single template by name.

  ## Examples

      iex> get_template_by_name("welcome-email", org_id)
      %Template{}

      iex> get_template_by_name("invalid", org_id)
      nil

  """
  def get_template_by_name(name, organization_id) do
    Template
    |> where([t], t.name == ^name and t.organization_id == ^organization_id)
    |> Repo.one()
  end

  @doc """
  Creates a template.

  ## Examples

      iex> create_template(%{field: value})
      {:ok, %Template{}}

      iex> create_template(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_template(attrs \\ %{}) do
    %Template{}
    |> Template.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a template.

  ## Examples

      iex> update_template(template, %{field: new_value})
      {:ok, %Template{}}

      iex> update_template(template, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_template(%Template{} = template, attrs) do
    template
    |> Template.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a template.

  ## Examples

      iex> delete_template(template)
      {:ok, %Template{}}

      iex> delete_template(template)
      {:error, %Ecto.Changeset{}}

  """
  def delete_template(%Template{} = template) do
    Repo.delete(template)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking template changes.

  ## Examples

      iex> change_template(template)
      %Ecto.Changeset{data: %Template{}}

  """
  def change_template(%Template{} = template, attrs \\ %{}) do
    Template.changeset(template, attrs)
  end

  @doc """
  Duplicates a template with a new name.

  ## Examples

      iex> duplicate_template(template, "new-name")
      {:ok, %Template{}}

  """
  def duplicate_template(%Template{} = template, new_name) do
    attrs = %{
      name: new_name,
      subject: template.subject,
      html_content: template.html_content,
      text_content: template.text_content,
      category: template.category,
      description: template.description,
      variables: template.variables,
      organization_id: template.organization_id,
      created_by_id: template.created_by_id
    }

    create_template(attrs)
  end
end