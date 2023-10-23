defmodule Terrible.Repo.Migrations.CreateBooksUsers do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE book_user_role AS ENUM ('admin', 'editor', 'viewer')"
    drop_query = "DROP TYPE IF EXISTS book_user_role"
    execute(create_query, drop_query)

    create table(:books_users) do
      add :role, :book_user_role, null: false, default: "viewer"
      add :book_id, references(:books, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:books_users, [:book_id, :user_id],
             name: :books_users_book_id_user_id_unique_index
           )

    create index(:books_users, [:user_id])
  end
end
