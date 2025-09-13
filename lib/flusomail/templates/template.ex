defmodule Flusomail.Templates.Template do
  use Ecto.Schema
  import Ecto.Changeset

  alias Flusomail.Organizations.Organization
  alias Flusomail.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "templates" do
    field :name, :string
    field :subject, :string
    field :html_content, :string
    field :text_content, :string
    field :category, :string
    field :description, :string
    field :variables, :map, default: %{}
    field :is_active, :boolean, default: true

    belongs_to :organization, Organization
    belongs_to :created_by, User

    timestamps(type: :utc_datetime)
  end

  @categories [
    "welcome",
    "promotional",
    "transactional",
    "newsletter",
    "abandoned_cart",
    "confirmation",
    "notification",
    "other"
  ]

  @doc """
  Returns the list of available template categories.
  """
  def categories, do: @categories

  @doc false
  def changeset(template, attrs) do
    template
    |> cast(attrs, [
      :name,
      :subject,
      :html_content,
      :text_content,
      :category,
      :description,
      :variables,
      :is_active,
      :organization_id,
      :created_by_id
    ])
    |> validate_required([:name, :subject, :html_content, :category, :organization_id])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_length(:subject, min: 1, max: 500)
    |> validate_inclusion(:category, @categories)
    |> validate_change(:variables, &validate_variables/2)
    |> unique_constraint([:organization_id, :name])
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:created_by_id)
  end

  defp validate_variables(:variables, variables) when is_map(variables) do
    case Jason.encode(variables) do
      {:ok, _} -> []
      {:error, _} -> [variables: "must be valid JSON"]
    end
  end

  defp validate_variables(:variables, _), do: [variables: "must be a map"]
end
