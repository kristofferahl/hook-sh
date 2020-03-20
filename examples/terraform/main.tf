resource "random_pet" "cat" {}

output "pet_name" {
  value = random_pet.cat.id
}
