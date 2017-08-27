# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     AppApi.Repo.insert!(%MyApp.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


alias AppApi.Models.Post
alias AppApi.Models.User
alias AppApi.Repo
 
# don't run unless you really want to mess up the database

for _ <- 1..10 do
  Repo.insert!(%Post{
    title: Faker.Lorem.sentence,
    body: Faker.Lorem.paragraph
  })
end

for _ <- 1..10 do
  Repo.insert!(%User{
    name: Faker.Name.name
  })
end

user_ids =
  User
  |> Repo.all()
  |> Enum.map(&(&1.id))

Repo.all(Post)
|> Enum.map(fn (post) ->
    [random_user_id] = user_ids |> Enum.take_random(1)
    post_changeset =
      Post.changeset(%{post | user_id: random_user_id })
    Repo.update!(post_changeset)
   end)

