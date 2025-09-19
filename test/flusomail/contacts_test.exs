defmodule Flusomail.ContactsTest do
  use Flusomail.DataCase

  alias Flusomail.Contacts

  describe "contacts" do
    alias Flusomail.Contacts.Contact

    import Flusomail.AccountsFixtures
    import Flusomail.OrganizationsFixtures
    import Flusomail.ContactsFixtures

    @invalid_attrs %{email: nil}

    test "list_contacts/1 returns all contacts for organization" do
      scope1 = user_scope_fixture()
      scope2 = user_scope_fixture()
      organization1 = organization_fixture(scope1)
      organization2 = organization_fixture(scope2)

      contact1 = contact_fixture(%{organization_id: organization1.id})
      contact2 = contact_fixture(%{organization_id: organization2.id})

      assert Contacts.list_contacts(organization1.id) == [contact1]
      assert Contacts.list_contacts(organization2.id) == [contact2]
    end

    test "list_contacts/1 returns contacts for solo users (nil organization_id)" do
      user = user_fixture()
      contact1 = contact_fixture(%{organization_id: nil, created_by_id: user.id})
      contact2 = contact_fixture(%{organization_id: nil, created_by_id: user.id})

      # Create a contact for an organization to ensure it's not returned
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      _org_contact = contact_fixture(%{organization_id: organization.id})

      contacts = Contacts.list_contacts(nil)
      assert length(contacts) == 2
      assert contact1 in contacts
      assert contact2 in contacts
      assert Enum.all?(contacts, fn c -> c.organization_id == nil end)
    end

    test "get_contact!/1 returns the contact with given id" do
      contact = contact_fixture()
      assert Contacts.get_contact!(contact.id) == contact
    end

    test "get_contact!/2 returns the contact with given id for organization" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      organization = organization_fixture(scope)
      contact = contact_fixture(%{organization_id: organization.id})
      other_org = organization_fixture(other_scope)

      assert Contacts.get_contact!(organization.id, contact.id) == contact

      assert_raise Ecto.NoResultsError, fn ->
        Contacts.get_contact!(other_org.id, contact.id)
      end
    end

    test "get_contact!/2 returns the contact with given id for solo users (nil organization_id)" do
      user = user_fixture()
      contact = contact_fixture(%{organization_id: nil, created_by_id: user.id})

      # Create a contact for an organization to ensure it's not accessible
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      org_contact = contact_fixture(%{organization_id: organization.id})

      assert Contacts.get_contact!(nil, contact.id) == contact

      assert_raise Ecto.NoResultsError, fn ->
        Contacts.get_contact!(nil, org_contact.id)
      end
    end

    test "create_contact/1 with valid data creates a contact" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      user = user_fixture()

      valid_attrs = %{
        name: "John Doe",
        email: "john@example.com",
        organization_id: organization.id,
        created_by_id: user.id
      }

      assert {:ok, %Contact{} = contact} = Contacts.create_contact(valid_attrs)
      assert contact.name == "John Doe"
      assert contact.email == "john@example.com"
      assert contact.organization_id == organization.id
      assert contact.created_by_id == user.id
    end

    test "create_contact/1 with solo user (nil organization_id) creates a contact" do
      user = user_fixture()

      valid_attrs = %{
        name: "Jane Doe",
        email: "jane@example.com",
        organization_id: nil,
        created_by_id: user.id
      }

      assert {:ok, %Contact{} = contact} = Contacts.create_contact(valid_attrs)
      assert contact.name == "Jane Doe"
      assert contact.email == "jane@example.com"
      assert contact.organization_id == nil
      assert contact.created_by_id == user.id
    end

    test "create_contact/1 with only email (no name) creates a contact" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      user = user_fixture()

      valid_attrs = %{
        email: "emailonly@example.com",
        organization_id: organization.id,
        created_by_id: user.id
      }

      assert {:ok, %Contact{} = contact} = Contacts.create_contact(valid_attrs)
      assert contact.name == nil
      assert contact.email == "emailonly@example.com"
      assert contact.organization_id == organization.id
      assert contact.created_by_id == user.id
    end

    test "create_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contacts.create_contact(@invalid_attrs)
    end

    test "create_contact/1 enforces unique email per organization" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      user = user_fixture()

      attrs = %{
        name: "John Doe",
        email: "duplicate@example.com",
        organization_id: organization.id,
        created_by_id: user.id
      }

      assert {:ok, %Contact{}} = Contacts.create_contact(attrs)
      assert {:error, %Ecto.Changeset{}} = Contacts.create_contact(attrs)
    end

    test "create_contact/1 allows same email across different organizations" do
      scope1 = user_scope_fixture()
      scope2 = user_scope_fixture()
      organization1 = organization_fixture(scope1)
      organization2 = organization_fixture(scope2)
      user = user_fixture()

      attrs1 = %{
        name: "John Doe",
        email: "same@example.com",
        organization_id: organization1.id,
        created_by_id: user.id
      }

      attrs2 = %{
        name: "Jane Doe",
        email: "same@example.com",
        organization_id: organization2.id,
        created_by_id: user.id
      }

      assert {:ok, %Contact{}} = Contacts.create_contact(attrs1)
      assert {:ok, %Contact{}} = Contacts.create_contact(attrs2)
    end

    test "update_contact/2 with valid data updates the contact" do
      contact = contact_fixture()
      update_attrs = %{name: "Updated Name", email: "updated@example.com"}

      assert {:ok, %Contact{} = contact} = Contacts.update_contact(contact, update_attrs)
      assert contact.name == "Updated Name"
      assert contact.email == "updated@example.com"
    end

    test "update_contact/2 with invalid data returns error changeset" do
      contact = contact_fixture()
      assert {:error, %Ecto.Changeset{}} = Contacts.update_contact(contact, @invalid_attrs)
      assert contact == Contacts.get_contact!(contact.id)
    end

    test "delete_contact/1 deletes the contact" do
      contact = contact_fixture()
      assert {:ok, %Contact{}} = Contacts.delete_contact(contact)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(contact.id) end
    end

    test "change_contact/1 returns a contact changeset" do
      contact = contact_fixture()
      assert %Ecto.Changeset{} = Contacts.change_contact(contact)
    end

    test "count_contacts/1 returns the count of contacts for organization" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)

      assert Contacts.count_contacts(organization.id) == 0

      _contact1 = contact_fixture(%{organization_id: organization.id})
      _contact2 = contact_fixture(%{organization_id: organization.id})

      assert Contacts.count_contacts(organization.id) == 2
    end

    test "count_contacts/1 returns the count of contacts for solo users (nil organization_id)" do
      user = user_fixture()

      assert Contacts.count_contacts(nil) == 0

      _contact1 = contact_fixture(%{organization_id: nil, created_by_id: user.id})
      _contact2 = contact_fixture(%{organization_id: nil, created_by_id: user.id})

      assert Contacts.count_contacts(nil) == 2
    end
  end
end
