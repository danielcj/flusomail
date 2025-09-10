defmodule FlusomailWeb.UserLive.RegistrationTest do
  use FlusomailWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Flusomail.AccountsFixtures

  describe "Registration page" do
    test "renders organization registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/register")

      assert html =~ "Create Your Organization"
      assert html =~ "Organization Details"
      assert html =~ "Admin User"
      assert html =~ "Log in"
    end

    test "redirects if already logged in", %{conn: conn} do
      user = unconfirmed_user_fixture() |> set_password()
      
      result =
        conn
        |> log_in_user(user)
        |> live(~p"/users/register")
        |> follow_redirect(conn, ~p"/home")

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(user: %{
          "org_name" => "",
          "org_domain" => "invalid domain",
          "name" => "",
          "email" => "with spaces",
          "password" => "short"
        })

      assert result =~ "Create Your Organization"
      assert result =~ "must be a valid email"
    end
  end

  describe "register organization and user" do
    test "creates organization and admin user but does not log in", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      email = unique_user_email()
      form = form(lv, "#registration_form", user: %{
        "org_name" => "Test Organization",
        "org_domain" => "test-org.com",
        "name" => "Test User",
        "email" => email,
        "password" => valid_user_password()
      })

      {:ok, _lv, html} =
        render_submit(form)
        |> follow_redirect(conn, ~p"/users/log-in")

      assert html =~ "Organization created!"
      assert html =~ "An email was sent to #{email} to confirm your account"
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      user = unconfirmed_user_fixture(%{email: "test@email.com"})

      result =
        lv
        |> form("#registration_form", user: %{
          "org_name" => "Test Organization",
          "org_domain" => "test-org.com", 
          "name" => "Test User",
          "email" => user.email,
          "password" => valid_user_password()
        })
        |> render_submit()

      assert result =~ "has already been taken"
    end
  end

  describe "registration navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      {:ok, _login_live, login_html} =
        lv
        |> element("main a", "Log in")
        |> render_click()
        |> follow_redirect(conn, ~p"/users/log-in")

      assert login_html =~ "Log in"
    end
  end
end
